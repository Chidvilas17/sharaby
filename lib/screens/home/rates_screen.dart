import 'package:flutter/material.dart';

class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees Rates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // DOCTORS
            // =========================
            _buildSection(
              title: 'Doctors',
              columns: const [
                'Name',
                'Rate',
                'Rate In Special Days',
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // NURSING
            // =========================
            _buildSection(
              title: 'Nursing',
              columns: const [
                'Name',
                'A',
                'B',
                'C',
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // ACCOUNTANTS & WORKERS
            // =========================
            _buildSection(
              title: 'Accountants - and - Workers',
              columns: const [
                'Name',
                'Salary',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> columns,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal scrolling allows the table to fit
        // on smaller mobile screens.
        SizedBox(
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: columns.length == 3
                    ? 500
                    : columns.length == 4
                    ? 500
                    : 350,
                child: Column(
                  children: [
                    // =========================
                    // TABLE HEADER
                    // =========================
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
                      child: Row(
                        children: [
                          for (int i = 0; i < columns.length; i++)
                            Expanded(
                              child: Text(
                                columns[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // =========================
                    // EMPTY DATABASE AREA
                    // =========================
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
            ),
          ),
        ),
      ],
    );
  }
}