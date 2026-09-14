import 'package:flutter/material.dart';

class ManagementInpatientAdmissionAccountsScreen
    extends StatefulWidget {
  const ManagementInpatientAdmissionAccountsScreen({
    super.key,
  });

  @override
  State<ManagementInpatientAdmissionAccountsScreen>
  createState() =>
      _ManagementInpatientAdmissionAccountsScreenState();
}

class _ManagementInpatientAdmissionAccountsScreenState
    extends State<ManagementInpatientAdmissionAccountsScreen> {
  int? selectedRow;

  // Empty until the API/database is connected.
  final List<Map<String, String>> patients = [];

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
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
    const double addressWidth = 180;
    const double phone1Width = 140;
    const double phone2Width = 140;
    const double cardNumberWidth = 150;

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
          1: FixedColumnWidth(addressWidth),
          2: FixedColumnWidth(phone1Width),
          3: FixedColumnWidth(phone2Width),
          4: FixedColumnWidth(cardNumberWidth),
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
                'Address',
                addressWidth,
              ),
              _headerCell(
                'Phone 1',
                phone1Width,
              ),
              _headerCell(
                'Phone 2',
                phone2Width,
              ),
              _headerCell(
                'Card Number',
                cardNumberWidth,
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
                  row < patients.length
                      ? patients[row]['name'] ?? ''
                      : '',
                  nameWidth,
                ),
                _dataCell(
                  row,
                  row < patients.length
                      ? patients[row]['address'] ?? ''
                      : '',
                  addressWidth,
                ),
                _dataCell(
                  row,
                  row < patients.length
                      ? patients[row]['phone1'] ?? ''
                      : '',
                  phone1Width,
                ),
                _dataCell(
                  row,
                  row < patients.length
                      ? patients[row]['phone2'] ?? ''
                      : '',
                  phone2Width,
                ),
                _dataCell(
                  row,
                  row < patients.length
                      ? patients[row]['cardNumber'] ?? ''
                      : '',
                  cardNumberWidth,
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
          'Current Inpatient Cases',
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