import 'package:flutter/material.dart';

class StatementsTodayAccountScreen extends StatefulWidget {
  const StatementsTodayAccountScreen({super.key});

  @override
  State<StatementsTodayAccountScreen> createState() =>
      _StatementsTodayAccountScreenState();
}

class _StatementsTodayAccountScreenState
    extends State<StatementsTodayAccountScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  final List<String> headers = [
    'No.',
    'Name',
    'Type',
    'Price',
    'Time',
    'Doctor',
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
            decoration: const BoxDecoration(
              color: Color(0xFF4D88B5),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
          ),

          // Empty rows. Real records will come from the API.
          ...List.generate(20, (index) {
            return TableRow(
              children: headers.map((header) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRow = index;
                    });
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: selectedRow == index
                        ? Colors.blue.withOpacity(0.12)
                        : const Color(0xFFD3DFE9),
                    child: Text(
                      header == 'No.' ? '${index + 1}' : '',
                    ),
                  ),
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
        title: const Text('Today\'s Account'),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Interactive date field
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

            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total Income',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}