import 'package:flutter/material.dart';

class ManagementInpatientTodayAccountsScreen
    extends StatefulWidget {
  const ManagementInpatientTodayAccountsScreen({
    super.key,
  });

  @override
  State<ManagementInpatientTodayAccountsScreen> createState() =>
      _ManagementInpatientTodayAccountsScreenState();
}

class _ManagementInpatientTodayAccountsScreenState
    extends State<ManagementInpatientTodayAccountsScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedIncomeRow;
  int? selectedExpenseRow;

  // Empty until the API/database is connected.
  final List<Map<String, String>> incomeData = [];
  final List<Map<String, String>> expenseData = [];

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  void _search() {
    // Database search will be connected through the API later.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching for ${_formatDate(selectedDate)}',
        ),
      ),
    );
  }

  void _deleteIncome() {
    if (selectedIncomeRow == null) {
      _showMessage('Please select an income row first.');
      return;
    }

    // Actual database deletion will be connected later.
    _showMessage(
      'Income row selected. Database deletion will be connected later.',
    );
  }

  void _deleteExpense() {
    if (selectedExpenseRow == null) {
      _showMessage('Please select an expense row first.');
      return;
    }

    // Actual database deletion will be connected later.
    _showMessage(
      'Expense row selected. Database deletion will be connected later.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _headerCell(
      String text,
      double width,
      ) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _dataCell(
      int row,
      String text,
      double width,
      bool isIncome,
      ) {
    final isSelected = isIncome
        ? selectedIncomeRow == row
        : selectedExpenseRow == row;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isIncome) {
            selectedIncomeRow = row;
          } else {
            selectedExpenseRow = row;
          }
        });
      },
      child: Container(
        width: width,
        height: 36,
        alignment: Alignment.center,
        color: isSelected
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

  Widget _buildTable({
    required bool isIncome,
  }) {
    const int emptyRows = 15;

    const double caseNameWidth = 180;
    const double typeWidth = 130;
    const double receiptWidth = 140;
    const double amountWidth = 110;
    const double accountantWidth = 130;
    const double notesWidth = 160;

    final data = isIncome ? incomeData : expenseData;

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
          0: FixedColumnWidth(caseNameWidth),
          1: FixedColumnWidth(typeWidth),
          2: FixedColumnWidth(receiptWidth),
          3: FixedColumnWidth(amountWidth),
          4: FixedColumnWidth(accountantWidth),
          5: FixedColumnWidth(notesWidth),
        },
        children: [
          TableRow(
            children: [
              _headerCell(
                'Case Name',
                caseNameWidth,
              ),
              _headerCell(
                'Type',
                typeWidth,
              ),
              _headerCell(
                'Receipt Number',
                receiptWidth,
              ),
              _headerCell(
                'Amount',
                amountWidth,
              ),
              _headerCell(
                'Accountant',
                accountantWidth,
              ),
              _headerCell(
                'Notes',
                notesWidth,
              ),
            ],
          ),

          for (int row = 0; row < emptyRows; row++)
            TableRow(
              children: [
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['caseName'] ?? ''
                      : '',
                  caseNameWidth,
                  isIncome,
                ),
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['type'] ?? ''
                      : '',
                  typeWidth,
                  isIncome,
                ),
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['receiptNumber'] ?? ''
                      : '',
                  receiptWidth,
                  isIncome,
                ),
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['amount'] ?? ''
                      : '',
                  amountWidth,
                  isIncome,
                ),
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['accountant'] ?? ''
                      : '',
                  accountantWidth,
                  isIncome,
                ),
                _dataCell(
                  row,
                  row < data.length
                      ? data[row]['notes'] ?? ''
                      : '',
                  notesWidth,
                  isIncome,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _accountSection({
    required String title,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(title),

          _buildTable(
            isIncome: isIncome,
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 110,
              height: 42,
              child: ElevatedButton(
                onPressed: isIncome
                    ? _deleteIncome
                    : _deleteExpense,
                child: const Text('Delete'),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            isIncome
                ? 'Total Income: 0'
                : 'Total Expenses: 0',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
          'Daily Inpatient Accounts',
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
              // SEARCH BY DATE
              // =========================

              const Text(
                'Search by Date',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: _selectDate,
                child: Container(
                  height: 52,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade500,
                    ),
                    borderRadius:
                    BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatDate(selectedDate),
                          style:
                          const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 46,
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

              const SizedBox(height: 12),

              const Text(
                'No operations for this day',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // INCOME
              // =========================

              _accountSection(
                title: 'Inpatient Income',
                isIncome: true,
              ),

              const SizedBox(height: 24),

              // =========================
              // EXPENSES
              // =========================

              _accountSection(
                title: 'Inpatient Expenses',
                isIncome: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}