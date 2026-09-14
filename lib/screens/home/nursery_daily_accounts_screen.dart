import 'package:flutter/material.dart';

class NurseryDailyAccountsScreen extends StatefulWidget {
  const NurseryDailyAccountsScreen({super.key});

  @override
  State<NurseryDailyAccountsScreen> createState() =>
      _NurseryDailyAccountsScreenState();
}

class _NurseryDailyAccountsScreenState
    extends State<NurseryDailyAccountsScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedIncomeRow;
  int? selectedExpenseRow;

  final List<String> headers = [
    'Case Name',
    'Type',
    'Receipt Number',
    'Amount',
    'Accountant',
    'Notes',
  ];

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching nursery accounts for ${_formatDate(selectedDate)}. '
              'Database connection will be added later.',
        ),
      ),
    );
  }

  void _deleteIncome() {
    if (selectedIncomeRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an income row first.'),
        ),
      );
      return;
    }

    setState(() {
      selectedIncomeRow = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected income operation will be deleted after API connection.'),
      ),
    );
  }

  void _deleteExpense() {
    if (selectedExpenseRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expense row first.'),
        ),
      );
      return;
    }

    setState(() {
      selectedExpenseRow = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected expense operation will be deleted after API connection.'),
      ),
    );
  }

  Widget _buildTable({
    required bool income,
  }) {
    final selectedRow = income ? selectedIncomeRow : selectedExpenseRow;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(130),
        border: TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
            ),
            children: headers.map((header) {
              return Container(
                height: 48,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          ...List.generate(15, (index) {
            return TableRow(
              children: headers.map((header) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (income) {
                        selectedIncomeRow = index;
                      } else {
                        selectedExpenseRow = index;
                      }
                    });
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: selectedRow == index
                        ? Colors.blue.withOpacity(0.12)
                        : Colors.transparent,
                    child: const Text(''),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccountSection({
    required String title,
    required bool income,
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'No operations This day',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildTable(income: income),
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: onDelete,
            child: const Text('Delete'),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          income ? 'Total Income: 0' : 'Total Expenses: 0',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Nursery Accounts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Search by Date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(_formatDate(selectedDate)),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),

            const SizedBox(height: 24),

            _buildAccountSection(
              title: 'Nursery Income',
              income: true,
              onDelete: _deleteIncome,
            ),

            const SizedBox(height: 35),

            _buildAccountSection(
              title: 'Nursery Expenses',
              income: false,
              onDelete: _deleteExpense,
            ),
          ],
        ),
      ),
    );
  }
}