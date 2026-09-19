import 'package:flutter/material.dart';

import '../../services/indoor_view_history_api_service.dart';

class IndoorViewHistoryScreen extends StatefulWidget {
  const IndoorViewHistoryScreen({super.key});

  @override
  State<IndoorViewHistoryScreen> createState() =>
      _IndoorViewHistoryScreenState();
}

class _IndoorViewHistoryScreenState
    extends State<IndoorViewHistoryScreen> {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
  TextEditingController();

  // ============================================================
  // DATABASE DATA
  // ============================================================

  List<Map<String, dynamic>> patients = [];

  bool isLoading = true;

  String? errorMessage;

  String? message;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD HISTORY
  //
  // No search text = load all history.
  // ============================================================

  Future<void> _loadHistory({
    String name = '',
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      message = null;
    });

    try {
      final data =
      await IndoorViewHistoryApiService.getHistory(
        name: name,
      );

      if (!mounted) return;

      setState(() {
        patients = data;
        isLoading = false;

        if (name.trim().isNotEmpty &&
            data.isEmpty) {
          message = 'Not found';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    final name = _searchController.text.trim();

    if (name.isEmpty) {
      setState(() {
        message = 'Enter Name to search';
      });

      return;
    }

    await _loadHistory(
      name: name,
    );
  }

  // ============================================================
  // CLEAR
  //
  // Clears the search box and returns all history.
  // ============================================================

  Future<void> _clear() async {
    _searchController.clear();

    await _loadHistory();
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Internal History',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // SEARCH SECTION
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius:
                  BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Search By Name',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==========================================
                    // NAME INPUT
                    // ==========================================

                    TextField(
                      controller:
                      _searchController,
                      textInputAction:
                      TextInputAction.search,
                      onSubmitted: (_) {
                        _search();
                      },
                      decoration:
                      const InputDecoration(
                        labelText: 'Name',
                        border:
                        OutlineInputBorder(),
                        prefixIcon:
                        Icon(Icons.search),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // SEARCH BUTTON
                    // ==========================================

                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed:
                        isLoading
                            ? null
                            : _search,
                        icon: const Icon(
                          Icons.search,
                        ),
                        label: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==========================================
                    // CLEAR BUTTON
                    // ==========================================

                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed:
                        isLoading
                            ? null
                            : _clear,
                        icon: const Icon(
                          Icons.clear,
                        ),
                        label: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MESSAGE
              // ==================================================

              if (message != null)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),

              // ==================================================
              // HISTORY TABLE
              // ==================================================

              Container(
                padding:
                const EdgeInsets.fromLTRB(
                  12,
                  18,
                  12,
                  12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius:
                  BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // TABLE
                    // ==========================================

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                          Colors.grey.shade500,
                        ),
                      ),
                      child:
                      SingleChildScrollView(
                        scrollDirection:
                        Axis.horizontal,
                        child: SizedBox(
                          width: 520,
                          child: Column(
                            children: [
                              // ==================================
                              // TABLE HEADER
                              // ==================================

                              Container(
                                height: 52,
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.grey.shade100,
                                  border: Border(
                                    bottom:
                                    BorderSide(
                                      color: Colors
                                          .grey
                                          .shade400,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    _HeaderCell(
                                      title: 'Name',
                                      flex: 3,
                                    ),
                                    _HeaderCell(
                                      title: 'Phone',
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),

                              // ==================================
                              // LOADING
                              // ==================================

                              if (isLoading)
                                const SizedBox(
                                  height: 576,
                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                )

                              // ==================================
                              // ERROR
                              // ==================================

                              else if (
                              errorMessage !=
                                  null)
                                SizedBox(
                                  height: 576,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .all(
                                      20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      children: [
                                        const Text(
                                          'Failed to load history.',
                                          textAlign:
                                          TextAlign
                                              .center,
                                          style:
                                          TextStyle(
                                            fontSize:
                                            16,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          errorMessage!,
                                          textAlign:
                                          TextAlign
                                              .center,
                                        ),

                                        const SizedBox(
                                          height: 16,
                                        ),

                                        ElevatedButton(
                                          onPressed:
                                              () {
                                            _loadHistory();
                                          },
                                          child:
                                          const Text(
                                            'Retry',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )

                              // ==================================
                              // NO DATA
                              // ==================================

                              else if (patients
                                    .isEmpty)
                                  _buildEmptyRows()

                                // ==================================
                                // DATA
                                // ==================================

                                else
                                  ...patients
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) {
                                      return _buildPatientRow(
                                        entry.key,
                                        entry.value,
                                      );
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY TABLE
  // ============================================================

  Widget _buildEmptyRows() {
    return Column(
      children: List.generate(
        18,
            (index) {
          return Container(
            height: 32,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                  Colors.grey.shade200,
                ),
              ),
            ),
            child: const Row(
              children: [
                _EmptyCell(flex: 3),
                _EmptyCell(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PATIENT ROW
  // ============================================================

  Widget _buildPatientRow(
      int index,
      Map<String, dynamic> patient,
      ) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          _DataCell(
            text:
            patient['patientName']
                ?.toString() ??
                '',
            flex: 3,
          ),

          _DataCell(
            text:
            patient['phone']
                ?.toString() ??
                '',
            flex: 2,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HEADER CELL
// ================================================================

class _HeaderCell extends StatelessWidget {
  final String title;

  final int flex;

  const _HeaderCell({
    required this.title,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY CELL
// ================================================================

class _EmptyCell extends StatelessWidget {
  final int flex;

  const _EmptyCell({
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade200,
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DATA CELL
// ================================================================

class _DataCell extends StatelessWidget {
  final String text;

  final int flex;

  const _DataCell({
    required this.text,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade200,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}