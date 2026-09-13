import 'package:flutter/material.dart';

class CurrentNursesScreen extends StatefulWidget {
  const CurrentNursesScreen({super.key});

  @override
  State<CurrentNursesScreen> createState() =>
      _CurrentNursesScreenState();
}

class _CurrentNursesScreenState
    extends State<CurrentNursesScreen> {
  String? selectedNurse;

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
        title: const Text("Total Nurses' Salaries"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // SELECT AND SHOW
            // =========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select and Show',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Select the name',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedNurse,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select nurse'),
                    items: const [],
                    onChanged: (value) {
                      setState(() {
                        selectedNurse = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 15,
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

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _showSalary,
                        child: const Text('Show'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SHIFT A
            _buildShiftSection(
              shiftName: 'Shift A',
              time: 'From 12:00 AM to 8:00 AM',
            ),

            const SizedBox(height: 24),

            // SHIFT B
            _buildShiftSection(
              shiftName: 'Shift B',
              time: 'From 8:00 AM to 4:00 PM',
            ),

            const SizedBox(height: 24),

            // SHIFT C
            _buildShiftSection(
              shiftName: 'Shift C',
              time: 'From 4:00 PM to 12:00 AM',
            ),

            const SizedBox(height: 24),

            // =========================
            // SUMMARY
            // =========================
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  // =========================
  // SHIFT SECTION
  // =========================

  Widget _buildShiftSection({
    required String shiftName,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          shiftName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getShiftColor(shiftName),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
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
                    SizedBox(
                      width: 45,
                      child: Text(
                        'No.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Accountant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Database data will appear here later.
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
    );
  }

  // =========================
  // SUMMARY
  // =========================

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _summaryRow(
            'Shift A',
            '0',
            Colors.red,
          ),

          _summaryRow(
            'Shift B',
            '0',
            Colors.blue,
          ),

          _summaryRow(
            'Shift C',
            '0',
            Colors.green,
          ),

          const Divider(height: 24),

          _summaryRow(
            'Total Salaries',
            '0',
            Colors.black,
          ),

          _summaryRow(
            'Deductions',
            '0',
            Colors.red,
          ),

          _summaryRow(
            'Net',
            '0',
            Colors.red,
          ),

          _summaryRow(
            'Allowances',
            '0',
            Colors.green,
          ),

          _summaryRow(
            'Net Payable',
            '0',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value,
      Color valueColor,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getShiftColor(String shiftName) {
    switch (shiftName) {
      case 'Shift A':
        return Colors.red;
      case 'Shift B':
        return Colors.blue;
      case 'Shift C':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  void _showSalary() {
    // Database/API functionality will be added later.
  }
}