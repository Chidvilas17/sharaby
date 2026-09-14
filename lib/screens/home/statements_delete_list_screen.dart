import 'package:flutter/material.dart';

class StatementsDeleteListScreen extends StatefulWidget {
  const StatementsDeleteListScreen({super.key});

  @override
  State<StatementsDeleteListScreen> createState() =>
      _StatementsDeleteListScreenState();
}

class _StatementsDeleteListScreenState
    extends State<StatementsDeleteListScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  final List<String> headers = [
    'No.',
    'Name',
    'Type',
    'Date',
    'Time',
    'User',
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

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  void _deleteSelectedRow() {
    if (selectedRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a row first.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text(
            'This operation will be connected to the database later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Delete will be completed after API connection.',
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _headerCell(String text) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      color: const Color(0xFF4D88B5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _dataCell({
    required int rowIndex,
    required String header,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = rowIndex;
        });
      },
      child: Container(
        height: 42,
        alignment: Alignment.center,
        color: selectedRow == rowIndex
            ? Colors.blue.withOpacity(0.12)
            : const Color(0xFFD3DFE9),
        child: Text(
          header == 'No.' ? '${rowIndex + 1}' : '',
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(140),
        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),
        children: [
          TableRow(
            children: headers.map(_headerCell).toList(),
          ),
          ...List.generate(20, (index) {
            return TableRow(
              children: headers.map((header) {
                return _dataCell(
                  rowIndex: index,
                  header: header,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete List'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  _formatDate(selectedDate),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Screening Data',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildTable(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _deleteSelectedRow,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}