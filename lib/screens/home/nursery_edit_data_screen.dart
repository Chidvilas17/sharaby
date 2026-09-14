import 'package:flutter/material.dart';

class NurseryEditDataScreen extends StatefulWidget {
  const NurseryEditDataScreen({super.key});

  @override
  State<NurseryEditDataScreen> createState() =>
      _NurseryEditDataScreenState();
}

class _NurseryEditDataScreenState
    extends State<NurseryEditDataScreen> {
  int? selectedRow;

  final List<String> headers = [
    'Name',
    'Phone',
    'Date of Birth',
  ];

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(170),
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

          // Empty rows. Real data will come from the API later.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Nursery Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Nursery Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}