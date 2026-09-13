import 'package:flutter/material.dart';

class TotalSalariesScreen extends StatefulWidget {
  const TotalSalariesScreen({super.key});

  @override
  State<TotalSalariesScreen> createState() =>
      _TotalSalariesScreenState();
}

class _TotalSalariesScreenState
    extends State<TotalSalariesScreen> {
  final TextEditingController monthController =
  TextEditingController(text: '09/2026');

  final TextEditingController untilDateController =
  TextEditingController(text: '13-09-2026');

  @override
  void dispose() {
    monthController.dispose();
    untilDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Salaries'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // MONTH + SHOW
            // =========================
            _buildControls(),

            const SizedBox(height: 24),

            // =========================
            // DOCTORS SUMMARY
            // =========================
            _buildSectionTitle('Doctors'),

            _buildTable(
              columns: const [
                'Name',
                'Shift Count',
                'Special Shift',
                'Total',
              ],
              height: 240,
            ),

            const SizedBox(height: 24),

            // =========================
            // SHIFT A
            // =========================
            _buildShiftSection(
              'Shift A',
            ),

            const SizedBox(height: 20),

            // =========================
            // SHIFT B
            // =========================
            _buildShiftSection(
              'Shift B',
            ),

            const SizedBox(height: 20),

            // =========================
            // SHIFT C
            // =========================
            _buildShiftSection(
              'Shift C',
            ),

            const SizedBox(height: 24),

            // =========================
            // NURSES
            // =========================
            _buildSectionTitle('Nursing'),

            _buildTable(
              columns: const [
                'No.',
                'Name',
                'A',
                'B',
                'C',
                'Total',
              ],
              height: 280,
            ),

            const SizedBox(height: 24),

            // =========================
            // ACCOUNTANTS & WORKERS
            // =========================
            _buildSectionTitle(
              'Accountants and Workers',
            ),

            _buildTable(
              columns: const [
                'No.',
                'Name',
                'Salary',
              ],
              height: 220,
            ),

            const SizedBox(height: 24),

            // =========================
            // TOTAL
            // =========================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    'Total : ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // UNTIL DATE
            // =========================
            const Text(
              'Until Date',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: untilDateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DD-MM-YYYY',
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // FILTER BUTTON
            // =========================
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _filter,
                child: const Text('Filter'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // CONTROLS
  // =========================

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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

          const SizedBox(height: 16),

          SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: _showSalaries,
              child: const Text('Show'),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // SHIFT SECTION
  // =========================

  Widget _buildShiftSection(String shiftName) {
    Color color;

    switch (shiftName) {
      case 'Shift A':
        color = Colors.red;
        break;
      case 'Shift B':
        color = Colors.blue;
        break;
      default:
        color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          shiftName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 8),

        _buildTable(
          columns: const [
            'No.',
            'Date',
            'Notes',
            'Type',
          ],
          height: 220,
        ),
      ],
    );
  }

  // =========================
  // TABLE
  // =========================

  Widget _buildTable({
    required List<String> columns,
    required double height,
  }) {
    return SizedBox(
      height: height,
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
            width: _tableWidth(columns.length),
            child: Column(
              children: [
                // Header
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
                      for (final column in columns)
                        Expanded(
                          child: Text(
                            column,
                            style: const TextStyle(
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
        ),
      ),
    );
  }

  double _tableWidth(int columnCount) {
    if (columnCount == 6) {
      return 650;
    }

    if (columnCount == 4) {
      return 500;
    }

    if (columnCount == 3) {
      return 400;
    }

    return 500;
  }

  // =========================
  // BUTTON ACTIONS
  // =========================

  void _showSalaries() {
    // Database/API functionality will be added later.
  }

  void _filter() {
    // Database/API functionality will be added later.
  }
}