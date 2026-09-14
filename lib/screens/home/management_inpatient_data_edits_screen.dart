import 'package:flutter/material.dart';

class ManagementInpatientDataEditsScreen extends StatefulWidget {
  const ManagementInpatientDataEditsScreen({super.key});

  @override
  State<ManagementInpatientDataEditsScreen> createState() =>
      _ManagementInpatientDataEditsScreenState();
}

class _ManagementInpatientDataEditsScreenState
    extends State<ManagementInpatientDataEditsScreen> {
  int? selectedRow;

  // Empty until the API/database is connected.
  final List<Map<String, String>> inpatientData = [];

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
            ? Theme.of(context).colorScheme.primaryContainer
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
    const double dobWidth = 180;

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
          2: FixedColumnWidth(dobWidth),
        },
        children: [
          // =========================
          // HEADER
          // =========================

          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
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
                'Date of Birth',
                dobWidth,
              ),
            ],
          ),

          // =========================
          // EMPTY DATABASE ROWS
          // =========================

          for (int row = 0; row < emptyRows; row++)
            TableRow(
              children: [
                _dataCell(
                  row,
                  row < inpatientData.length
                      ? inpatientData[row]['name'] ?? ''
                      : '',
                  nameWidth,
                ),
                _dataCell(
                  row,
                  row < inpatientData.length
                      ? inpatientData[row]['phone'] ?? ''
                      : '',
                  phoneWidth,
                ),
                _dataCell(
                  row,
                  row < inpatientData.length
                      ? inpatientData[row]['dateOfBirth'] ?? ''
                      : '',
                  dobWidth,
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
          'Edit Inpatient Data',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildTable(),
        ),
      ),
    );
  }
}