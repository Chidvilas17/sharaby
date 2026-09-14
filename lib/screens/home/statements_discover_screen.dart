import 'package:flutter/material.dart';

class StatementsDiscoverScreen extends StatefulWidget {
  const StatementsDiscoverScreen({super.key});

  @override
  State<StatementsDiscoverScreen> createState() =>
      _StatementsDiscoverScreenState();
}

class _StatementsDiscoverScreenState
    extends State<StatementsDiscoverScreen> {
  final TextEditingController childNameController =
  TextEditingController();

  int? selectedTable;
  int? selectedRow;

  @override
  void dispose() {
    childNameController.dispose();
    super.dispose();
  }

  void _update() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Data will be updated from the database after API connection.',
        ),
      ),
    );
  }

  Widget _buildTable({
    required int tableIndex,
    required String title,
    required List<String> columns,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(115),
              border: TableBorder.all(
                color: Colors.black54,
                width: 0.7,
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4D88B5),
                  ),
                  children: columns.map((column) {
                    return Container(
                      height: 48,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        column,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                ...List.generate(12, (rowIndex) {
                  final isSelected =
                      selectedTable == tableIndex &&
                          selectedRow == rowIndex;

                  return TableRow(
                    children: columns.map((column) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTable = tableIndex;
                            selectedRow = rowIndex;
                          });
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          color: isSelected
                              ? Colors.blue.withOpacity(0.12)
                              : const Color(0xFFD3DFE9),
                          child: Text(
                            column == 'No.'
                                ? '${rowIndex + 1}'
                                : '',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Child Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: childNameController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'Child Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _update,
              icon: const Icon(Icons.refresh),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildTable(
              tableIndex: 0,
              title: 'Delayed Booking',
              columns: [
                'No.',
                'Booking',
                'Name',
                'Type',
                'Attendance',
                'Delete',
              ],
            ),

            _buildTable(
              tableIndex: 1,
              title: 'Current Morning Booking',
              columns: [
                'No.',
                'Booking',
                'Name',
                'Type',
                'Arrival',
                'Entry',
                'Delay',
              ],
            ),

            _buildTable(
              tableIndex: 2,
              title: 'Morning Phone Booking',
              columns: [
                'No.',
                'Name',
                'Type',
                'Entry',
                'Confirmation',
              ],
            ),

            _buildTable(
              tableIndex: 3,
              title: 'Current Evening Booking',
              columns: [
                'No.',
                'Booking',
                'Name',
                'Type',
                'Arrival',
                'Entry',
                'Delay',
              ],
            ),

            _buildTable(
              tableIndex: 4,
              title: 'Evening Phone Booking',
              columns: [
                'No.',
                'Name',
                'Type',
                'Entry',
                'Confirmation',
              ],
            ),

            _buildTable(
              tableIndex: 5,
              title: 'Phone Booking for Coming Days',
              columns: [
                'No.',
                'Name',
                'Type',
                'Date',
                'Entry',
              ],
            ),
          ],
        ),
      ),
    );
  }
}