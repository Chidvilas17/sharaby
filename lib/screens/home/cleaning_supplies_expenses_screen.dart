import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

class CleaningSuppliesExpensesScreen extends StatefulWidget {
  const CleaningSuppliesExpensesScreen({super.key});

  @override
  State<CleaningSuppliesExpensesScreen> createState() =>
      _CleaningSuppliesExpensesScreenState();
}

class _CleaningSuppliesExpensesScreenState
    extends State<CleaningSuppliesExpensesScreen> {
  final TextEditingController receiptNumberController =
  TextEditingController();

  final TextEditingController costController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  // Empty until the database/API is connected.
  final List<Map<String, String>> expenses = [];

  @override
  void dispose() {
    receiptNumberController.dispose();
    costController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _search() {
    setState(() {
      selectedRow = null;
    });

    _showMessage(
      'Search date: ${_formatDate(selectedDate)}',
    );
  }

  void _saveExpense() {
    final receiptNumber = receiptNumberController.text.trim();
    final cost = costController.text.trim();

    if (receiptNumber.isEmpty) {
      _showMessage('Please enter the receipt number.');
      return;
    }

    if (cost.isEmpty) {
      _showMessage('Please enter the cost.');
      return;
    }

    final parsedCost = double.tryParse(cost);

    if (parsedCost == null) {
      _showMessage('Please enter a valid cost.');
      return;
    }

    // Database insertion will be connected later.
    _showMessage('Expense information is valid.');
  }

  void _deleteExpense() {
    if (selectedRow == null) {
      _showMessage('Please select an expense first.');
      return;
    }

    // Database deletion will be connected later.
    _showMessage('Selected expense is ready for deletion.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Text(
        AppTranslations.tr(title),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatDate(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      height: 52,
      child: Center(
        child: Text(
          AppTranslations.tr(text),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
        height: 42,
        color: selectedRow == row
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          AppTranslations.tr(text),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTable() {
    const int emptyRows = 12;

    const double noWidth = 60;
    const double typeWidth = 150;
    const double receiptWidth = 130;
    const double costWidth = 100;
    const double notesWidth = 180;
    const double timeWidth = 120;
    const double accountantWidth = 130;

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
          0: FixedColumnWidth(noWidth),
          1: FixedColumnWidth(typeWidth),
          2: FixedColumnWidth(receiptWidth),
          3: FixedColumnWidth(costWidth),
          4: FixedColumnWidth(notesWidth),
          5: FixedColumnWidth(timeWidth),
          6: FixedColumnWidth(accountantWidth),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              _headerCell('No.', noWidth),
              _headerCell('Type', typeWidth),
              _headerCell('Receipt Number', receiptWidth),
              _headerCell('Cost', costWidth),
              _headerCell('Notes', notesWidth),
              _headerCell('Time', timeWidth),
              _headerCell('Accountant', accountantWidth),
            ],
          ),

          // Empty rows ready for database records.
          for (int i = 0; i < emptyRows; i++)
            TableRow(
              children: [
                _dataCell(
                  i,
                  i < expenses.length ? '${i + 1}' : '',
                  noWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['type'] ?? ''
                      : '',
                  typeWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['receiptNumber'] ?? ''
                      : '',
                  receiptWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['cost'] ?? ''
                      : '',
                  costWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['notes'] ?? ''
                      : '',
                  notesWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['time'] ?? ''
                      : '',
                  timeWidth,
                ),
                _dataCell(
                  i,
                  i < expenses.length
                      ? expenses[i]['accountant'] ?? ''
                      : '',
                  accountantWidth,
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;

    for (final expense in expenses) {
      total += double.tryParse(expense['cost'] ?? '') ?? 0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Cleaning Supplies Expenses')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current User
              Row(
                children: [
                  Text(AppTranslations.tr('Current User: '),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('1234567'),
                ],
              ),

              SizedBox(height: 20),

              // Search by Date
              _sectionTitle('Search by Date'),

              SizedBox(height: 14),

              _dateField(),

              SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _search,
                  child: Text(AppTranslations.tr('Search'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              Center(
                child: Text(AppTranslations.tr('No operations this day'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Add Expense
              _sectionTitle('Add Expense'),

              SizedBox(height: 16),

              _textField(
                controller: receiptNumberController,
                label: 'Receipt Number',
              ),

              SizedBox(height: 14),

              _textField(
                controller: costController,
                label: 'Cost',
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              SizedBox(height: 14),

              _textField(
                controller: notesController,
                label: 'Notes',
              ),

              SizedBox(height: 14),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: Text(AppTranslations.tr('Save'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Expense Data
              _sectionTitle('Expense Data'),

              _buildTable(),

              SizedBox(height: 16),

              // Delete
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _deleteExpense,
                  child: Text(AppTranslations.tr('Delete'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.tr('Total Expenses: '),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal().toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}