import 'package:flutter/material.dart';

class IndoorViewHistoryScreen extends StatefulWidget {
  const IndoorViewHistoryScreen({super.key});

  @override
  State<IndoorViewHistoryScreen> createState() =>
      _IndoorViewHistoryScreenState();
}

class _IndoorViewHistoryScreenState
    extends State<IndoorViewHistoryScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  // Will come from the API later.
  // Keep empty for now.
  final List<Map<String, String>> patients = [];

  List<Map<String, String>> searchResults = [];

  String? message;

  @override
  void initState() {
    super.initState();
    searchResults = List.from(patients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _search() {
    final name = _searchController.text.trim();

    setState(() {
      if (name.isEmpty) {
        message = 'Enter Name to search';
        searchResults = [];
        return;
      }

      final results = patients.where((patient) {
        final patientName =
        (patient['name'] ?? '').toLowerCase();

        return patientName.contains(name.toLowerCase());
      }).toList();

      searchResults = results;

      if (results.isEmpty) {
        message = 'Not found';
      } else {
        message = null;
      }
    });
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clear() {
    setState(() {
      _searchController.clear();
      searchResults = List.from(patients);
      message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal History'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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

                    // Name input
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        _search();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Search button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _search,
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

                    // Clear button
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _clear,
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
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: Text(
                    message!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // ==================================================
              // HISTORY TABLE
              // ==================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  18,
                  12,
                  12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 520,
                          child: Column(
                            children: [

                              // ==============================
                              // TABLE HEADER
                              // ==============================

                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade400,
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

                              // ==============================
                              // DATA
                              // ==============================

                              if (searchResults.isEmpty)
                                _buildEmptyRows()
                              else
                                ...searchResults.asMap().entries.map(
                                      (entry) {
                                    return _buildPatientRow(
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
                  color: Colors.grey.shade200,
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
      Map<String, String> patient,
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
            text: patient['name'] ?? '',
            flex: 3,
          ),
          _DataCell(
            text: patient['phone'] ?? '',
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
              color: Colors.grey.shade200,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
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