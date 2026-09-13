import 'package:flutter/material.dart';

class CurrentDoctorsScreen extends StatefulWidget {
  const CurrentDoctorsScreen({super.key});

  @override
  State<CurrentDoctorsScreen> createState() =>
      _CurrentDoctorsScreenState();
}

class _CurrentDoctorsScreenState
    extends State<CurrentDoctorsScreen> {
  String? selectedDoctor;

  final TextEditingController monthController =
  TextEditingController(text: '08/2025');

  @override
  void dispose() {
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Doctors' Salaries"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =====================================
            // SELECT AND SHOW SECTION
            // =====================================

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
                    value: selectedDoctor,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text(
                      'Select doctor',
                    ),
                    items: const [],
                    onChanged: (value) {
                      setState(() {
                        selectedDoctor = value;
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

            // =====================================
            // SHIFT A
            // =====================================

            _buildShiftSection(
              shiftName: 'Shift A',
              time: 'From 9:00 AM to 3:00 PM',
            ),

            const SizedBox(height: 24),

            // =====================================
            // SHIFT B
            // =====================================

            _buildShiftSection(
              shiftName: 'Shift B',
              time: 'From 3:00 PM to 9:00 PM',
            ),

            const SizedBox(height: 24),

            // =====================================
            // SHIFT C
            // =====================================

            _buildShiftSection(
              shiftName: 'Shift C',
              time: 'From 9:00 PM to 9:00 AM',
            ),
          ],
        ),
      ),
    );
  }

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
    // Database functionality will be connected later.
    //
    // Later this button will:
    // 1. Send selected doctor and month to the API.
    // 2. Get the salary records from SQL Server.
    // 3. Fill Shift A, Shift B and Shift C tables.
  }
}