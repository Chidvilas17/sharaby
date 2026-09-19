import 'package:flutter/material.dart';
import '../../services/incubator_view_history_api_service.dart';

class IncubatorViewHistoryScreen extends StatefulWidget {
  const IncubatorViewHistoryScreen({super.key});

  @override
  State<IncubatorViewHistoryScreen> createState() =>
      _IncubatorViewHistoryScreenState();
}

class _IncubatorViewHistoryScreenState
    extends State<IncubatorViewHistoryScreen> {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
  TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> patients = [];

  String? message;

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load ALL history immediately.
    _loadAllHistory();
  }

  // ============================================================
  // LOAD ALL HISTORY
  // ============================================================

  Future<void> _loadAllHistory() async {
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      final results =
      await IncubatorViewHistoryApiService.getHistory();

      if (!mounted) return;

      setState(() {
        patients = results;
        isLoading = false;

        if (results.isEmpty) {
          message = 'No history found';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        patients = [];
        message = e.toString();
      });
    }
  }

  // ============================================================
  // SEARCH HISTORY
  // ============================================================

  Future<void> _searchPatients() async {
    final name = _searchController.text.trim();

    // Empty search:
    // show ALL history again.
    if (name.isEmpty) {
      await _loadAllHistory();
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
      patients = [];
    });

    try {
      final results =
      await IncubatorViewHistoryApiService.getHistory(
        name: name,
      );

      if (!mounted) return;

      setState(() {
        patients = results;
        isLoading = false;

        if (results.isEmpty) {
          message = 'Not found';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        patients = [];
        message = e.toString();
      });
    }
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View History'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // SEARCH BY NAME
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

                    TextField(
                      controller: _searchController,
                      textInputAction:
                      TextInputAction.search,
                      onSubmitted: (_) {
                        _searchPatients();
                      },
                      decoration:
                      const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                        'Enter patient name',
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                        isLoading
                            ? null
                            : _searchPatients,
                        child: const Text(
                          'Search',
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
                    bottom: 12,
                  ),
                  child: Text(
                    message!,
                    textAlign: TextAlign.left,
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                ),
                child:
                SingleChildScrollView(
                  scrollDirection:
                  Axis.horizontal,
                  child: SizedBox(
                    width: 700,
                    child: Column(
                      children: [
                        // ==========================================
                        // HEADER
                        // ==========================================

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
                                    .grey.shade400,
                              ),
                            ),
                          ),
                          child: const Row(
                            children: [
                              _HeaderCell(
                                title: 'No.',
                                flex: 1,
                              ),
                              _HeaderCell(
                                title: 'Name',
                                flex: 3,
                              ),
                              _HeaderCell(
                                title: 'Phone',
                                flex: 2,
                              ),
                              _HeaderCell(
                                title:
                                'Discharge Date',
                                flex: 2,
                              ),
                              _HeaderCell(
                                title:
                                'Transferred To',
                                flex: 2,
                              ),
                            ],
                          ),
                        ),

                        // ==========================================
                        // LOADING
                        // ==========================================

                        if (isLoading)
                          const SizedBox(
                            height: 480,
                            child: Center(
                              child:
                              CircularProgressIndicator(),
                            ),
                          )

                        // ==========================================
                        // DATA
                        // ==========================================

                        else if (patients.isNotEmpty)
                          ...patients
                              .asMap()
                              .entries
                              .map(
                                (entry) {
                              final index =
                                  entry.key;

                              final patient =
                                  entry.value;

                              return _buildPatientRow(
                                index,
                                patient,
                              );
                            },
                          )

                        // ==========================================
                        // EMPTY
                        // ==========================================

                        else
                          _buildEmptyRows(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY ROWS
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
                _EmptyCell(flex: 1),
                _EmptyCell(flex: 3),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DATA ROW
  // ============================================================

  Widget _buildPatientRow(
      int index,
      Map<String, dynamic> patient,
      ) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          _DataCell(
            text: '${index + 1}',
            flex: 1,
          ),

          _DataCell(
            text:
            patient['name']?.toString() ??
                '',
            flex: 3,
          ),

          _DataCell(
            text:
            patient['phone']?.toString() ??
                '',
            flex: 2,
          ),

          _DataCell(
            text:
            patient['dischargeDate']
                ?.toString() ??
                '',
            flex: 2,
          ),

          _DataCell(
            text:
            patient['transferredTo']
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
            bottom: BorderSide(
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