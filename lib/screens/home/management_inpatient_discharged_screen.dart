import 'package:flutter/material.dart';

class ManagementInpatientDischargedScreen extends StatefulWidget {
  const ManagementInpatientDischargedScreen({super.key});

  @override
  State<ManagementInpatientDischargedScreen> createState() =>
      _ManagementInpatientDischargedScreenState();
}

class _ManagementInpatientDischargedScreenState
    extends State<ManagementInpatientDischargedScreen> {
  final TextEditingController searchController =
  TextEditingController();

  int? selectedRow;

  // Empty until the API/database is connected.
  final List<Map<String, String>> dischargedPatients = [];

  void _search() {
    final name = searchController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter a name to search.');
      return;
    }

    // Real database search will be connected through the API later.
    _showMessage('Searching for: $name');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(
      int row,
      String text,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = row;
        });
      },
      child: Container(
        width: width,
        height: 38,
        alignment: Alignment.center,
        color: selectedRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTable() {
    const int emptyRows = 20;

    const double nameWidth = 220;
    const double phoneWidth = 160;
    const double transferredWidth = 200;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          width: 1,
        ),
        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(nameWidth),
          1: FixedColumnWidth(phoneWidth),
          2: FixedColumnWidth(transferredWidth),
        },
        children: [
          // =========================
          // HEADER
          // =========================

          TableRow(
            children: [
              _headerCell(
                'Name',
                nameWidth,
              ),
              _headerCell(
                'Phone',
                phoneWidth,
              ),
              _headerCell(
                'Transferred To',
                transferredWidth,
              ),
            ],
          ),

          // =========================
          // EMPTY ROWS
          // =========================

          for (int row = 0; row < emptyRows; row++)
            TableRow(
              children: [
                _dataCell(
                  row,
                  row < dischargedPatients.length
                      ? dischargedPatients[row]['name'] ?? ''
                      : '',
                  nameWidth,
                ),
                _dataCell(
                  row,
                  row < dischargedPatients.length
                      ? dischargedPatients[row]['phone'] ?? ''
                      : '',
                  phoneWidth,
                ),
                _dataCell(
                  row,
                  row < dischargedPatients.length
                      ? dischargedPatients[row]['transferredTo'] ?? ''
                      : '',
                  transferredWidth,
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discharged Cases',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // =========================
              // SEARCH BY NAME
              // =========================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius:
                  BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Search by Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: searchController,
                      textInputAction:
                      TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration:
                      const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _search,
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

              const SizedBox(height: 24),

              // =========================
              // TABLE
              // =========================

              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }
}