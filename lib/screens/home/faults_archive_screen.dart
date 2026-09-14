import 'package:flutter/material.dart';

class FaultsArchiveScreen extends StatelessWidget {
  const FaultsArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const int emptyRowCount = 12;

    final List<String> columns = [
      'Device Name',
      'Fault Details',
      'Date Added',
      'Accountant',
      'Cost',
      'Access Number',
      'Maintenance Engineer',
      'Maintenance Time',
      'Accountant',
    ];

    final List<double> columnWidths = [
      150,
      220,
      120,
      120,
      90,
      120,
      170,
      140,
      120,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faults Archive'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section heading
              Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  color: Colors.grey.shade100,
                ),
                child: const Text(
                  'Faults Archive',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Excel-like table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultVerticalAlignment:
                  TableCellVerticalAlignment.middle,

                  border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),

                  columnWidths: {
                    for (int i = 0; i < columnWidths.length; i++)
                      i: FixedColumnWidth(columnWidths[i]),
                  },

                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      children: [
                        for (final column in columns)
                          _headerCell(column),
                      ],
                    ),

                    // Empty rows
                    for (int row = 0; row < emptyRowCount; row++)
                      TableRow(
                        children: [
                          for (int column = 0;
                          column < columns.length;
                          column++)
                            _emptyCell(),
                        ],
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

  static Widget _headerCell(String text) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _emptyCell() {
    return const SizedBox(
      height: 42,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Text(''),
      ),
    );
  }
}