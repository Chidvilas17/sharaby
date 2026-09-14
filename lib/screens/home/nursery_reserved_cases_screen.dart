import 'package:flutter/material.dart';

class NurseryReservedCasesScreen extends StatefulWidget {
  const NurseryReservedCasesScreen({super.key});

  @override
  State<NurseryReservedCasesScreen> createState() =>
      _NurseryReservedCasesScreenState();
}

class _NurseryReservedCasesScreenState
    extends State<NurseryReservedCasesScreen> {
  int? selectedRow;

  final List<String> headers = [
    'No.',
    'Name',
    'Total Account',
  ];

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(150),
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
                height: 50,
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

          // Empty rows — real data will come from the API later.
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
                        : Colors.transparent,
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
        title: const Text('Reserved Cases'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reserved Cases',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}