import 'package:flutter/material.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  String selectedType = 'Nurses';

  final TextEditingController monthController =
  TextEditingController(text: '09/2026');

  @override
  void dispose() {
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deductions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // MONTH
            // =========================
            const Text(
              'Month',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: monthController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'MM/YYYY',
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // EMPLOYEE TYPE
            // =========================
            const Text(
              'Select Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            RadioListTile<String>(
              title: const Text('Nurses'),
              value: 'Nurses',
              groupValue: selectedType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Accountants'),
              value: 'Accountants',
              groupValue: selectedType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Workers'),
              value: 'Workers',
              groupValue: selectedType,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // DATA TABLE
            // =========================
            const Text(
              'Salary Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Deductions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Advances',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Bonuses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Empty database area
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No data',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}