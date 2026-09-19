import 'package:flutter/material.dart';
import '../../services/other_expenses_api_service.dart';

class OtherExpensesScreen extends StatefulWidget {
  const OtherExpensesScreen({super.key});

  @override
  State<OtherExpensesScreen> createState() => _OtherExpensesScreenState();
}

class _OtherExpensesScreenState extends State<OtherExpensesScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedRow;
  bool isLoading = false;
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  Future<void> _loadExpenses() async {
    setState(() {
      isLoading = true;
      selectedRow = null;
    });

    try {
      final results = await OtherExpensesApiService.getByDate(selectedDate);
      if (mounted) {
        setState(() {
          expenses = results;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
      _loadExpenses();
    }
  }

  void _search() {
    _loadExpenses();
  }

  Future<void> _deleteExpense() async {
    if (selectedRow == null || selectedRow! < 0 || selectedRow! >= expenses.length) {
      _showMessage('Please select an expense row first.');
      return;
    }

    final record = expenses[selectedRow!];
    final id = record['id'];

    if (id != null) {
      try {
        await OtherExpensesApiService.deleteExpense(int.parse(id.toString()));
      } catch (_) {}
    }

    setState(() {
      expenses.removeAt(selectedRow!);
      selectedRow = null;
    });
    _showMessage('Expense deleted.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatDate(selectedDate),
                style: const TextStyle(fontSize: 16),
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
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _dataCell(int row, String text, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = row;
        });
      },
      child: Container(
        width: width,
        height: 42,
        color: selectedRow == row ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTable() {
    const double noWidth = 60;
    const double typeWidth = 140;
    const double receiptWidth = 130;
    const double costWidth = 100;
    const double notesWidth = 160;
    const double timeWidth = 110;
    const double accountantWidth = 130;

    final displayRows = expenses.length < 8 ? 8 : expenses.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey, width: 1),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
            decoration: BoxDecoration(color: Colors.grey.shade200),
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
          for (int i = 0; i < displayRows; i++)
            TableRow(
              children: [
                _dataCell(i, i < expenses.length ? '${i + 1}' : '', noWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['type']?.toString() ?? '') : '', typeWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['receiptNumber']?.toString() ?? expenses[i]['receipt_number']?.toString() ?? '') : '', receiptWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['cost']?.toString() ?? '') : '', costWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['notes']?.toString() ?? '') : '', notesWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['time']?.toString() ?? '') : '', timeWidth),
                _dataCell(i, i < expenses.length ? (expenses[i]['accountant']?.toString() ?? expenses[i]['user_id']?.toString() ?? '') : '', accountantWidth),
              ],
            ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (final expense in expenses) {
      total += double.tryParse(expense['cost']?.toString() ?? '') ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Expenses / مصروفات اخرى'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Text(
                    'Current User / محاسب: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('admin'),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Search by Date / بحث بالتاريخ'),
              const SizedBox(height: 12),
              _dateField(),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Search / بحث',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (expenses.isEmpty && !isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'لا يوجد عمليات لهذا اليوم / No operations this day',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _sectionTitle('Expense Data / بيانات المصروفات'),
              const SizedBox(height: 10),
              _buildTable(),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _deleteExpense,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'Delete / حذف',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'إجمالي المصروفات / Total Expenses: ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _calculateTotal().toStringAsFixed(0),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
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