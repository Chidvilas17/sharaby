import 'package:flutter/material.dart';

class StaffNursesNetAttendanceScreen extends StatefulWidget {
  const StaffNursesNetAttendanceScreen({super.key});

  @override
  State<StaffNursesNetAttendanceScreen> createState() =>
      _StaffNursesNetAttendanceScreenState();
}

class _StaffNursesNetAttendanceScreenState
    extends State<StaffNursesNetAttendanceScreen> {
  String? selectedNurse;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  int? selectedShiftARow;
  int? selectedShiftBRow;
  int? selectedShiftCRow;

  final List<String> headers = [
    'No.',
    'Notes',
    'Accountant',
    'Date',
  ];

  Future<void> _selectMonth() async {
    int tempMonth = selectedMonth;
    int tempYear = selectedYear;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Select Month',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: tempMonth,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;

                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(
                          month.toString().padLeft(2, '0'),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempMonth = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: tempYear,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(101, (index) {
                      final year = 2000 + index;

                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempYear = value;
                        });
                      }
                    },
                  ),
                ],
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
                    Navigator.pop(
                      dialogContext,
                      DateTime(tempYear, tempMonth),
                    );
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      selectedMonth = result.month;
      selectedYear = result.year;
    });
  }

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  void _show() {
    if (selectedNurse == null || selectedNurse == 'SELECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Showing $selectedNurse for $_monthText(). '
              'Database data will be loaded after API connection.',
        ),
      ),
    );
  }

  Widget _nurseDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedNurse,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Select Name',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem<String>(
          value: 'SELECT',
          child: Text('Select'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedNurse = value;
        });
      },
    );
  }

  Widget _buildShiftTable({
    required String shift,
    required String time,
    required int? selectedRow,
    required ValueChanged<int> onRowSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          shift,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          time,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(135),
              border: TableBorder.all(
                color: Colors.black54,
                width: 0.7,
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEFEF),
                  ),
                  children: headers.map((header) {
                    return Container(
                      height: 48,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
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

                ...List.generate(15, (index) {
                  final isSelected = selectedRow == index;

                  return TableRow(
                    children: headers.map((header) {
                      return GestureDetector(
                        onTap: () {
                          onRowSelected(index);
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          color: isSelected
                              ? Colors.blue.withOpacity(0.12)
                              : Colors.transparent,
                          child: Text(
                            header == 'No.'
                                ? '${index + 1}'
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
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  Widget _summaryRow({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Net Salary',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            title: 'Shift A',
            value: '0',
            valueColor: Colors.red,
          ),

          _summaryRow(
            title: 'Shift B',
            value: '0',
            valueColor: Colors.blue,
          ),

          _summaryRow(
            title: 'Shift C',
            value: '0',
            valueColor: Colors.green,
          ),

          const Divider(),

          _summaryRow(
            title: 'Total Salary',
            value: '0',
            valueColor: Colors.black,
          ),

          _summaryRow(
            title: 'Deductions',
            value: '0',
            valueColor: Colors.red,
          ),

          _summaryRow(
            title: 'Advances',
            value: '0',
            valueColor: Colors.red,
          ),

          _summaryRow(
            title: 'Bonuses',
            value: '0',
            valueColor: Colors.green,
          ),

          _summaryRow(
            title: 'Net Salary',
            value: '0',
            valueColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurses Net Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nurse
            _nurseDropdown(),

            const SizedBox(height: 12),

            // Month
            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_month,
                  ),
                ),
                child: Text(
                  _monthText(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Show
            ElevatedButton.icon(
              onPressed: _show,
              icon: const Icon(
                Icons.visibility_outlined,
              ),
              label: const Text('Show'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Shift A
            _buildShiftTable(
              shift: 'Shift A',
              time: '12:00 AM to 8:00 AM',
              selectedRow: selectedShiftARow,
              onRowSelected: (index) {
                setState(() {
                  selectedShiftARow = index;
                });
              },
            ),

            // Shift B
            _buildShiftTable(
              shift: 'Shift B',
              time: '8:00 AM to 4:00 PM',
              selectedRow: selectedShiftBRow,
              onRowSelected: (index) {
                setState(() {
                  selectedShiftBRow = index;
                });
              },
            ),

            // Shift C
            _buildShiftTable(
              shift: 'Shift C',
              time: '4:00 PM to 12:00 AM',
              selectedRow: selectedShiftCRow,
              onRowSelected: (index) {
                setState(() {
                  selectedShiftCRow = index;
                });
              },
            ),

            // Salary summary
            _buildSalarySummary(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}