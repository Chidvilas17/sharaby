import 'package:flutter/material.dart';

class StaffDoctorsMonthlyNetScreen extends StatefulWidget {
  const StaffDoctorsMonthlyNetScreen({super.key});

  @override
  State<StaffDoctorsMonthlyNetScreen> createState() =>
      _StaffDoctorsMonthlyNetScreenState();
}

class _StaffDoctorsMonthlyNetScreenState
    extends State<StaffDoctorsMonthlyNetScreen> {
  String? selectedDoctor;

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
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int tempMonth = selectedMonth;
        int tempYear = selectedYear;

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
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;

                      return DropdownMenuItem(
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
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(101, (index) {
                      final year = 2000 + index;

                      return DropdownMenuItem(
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
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
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

    if (picked == null) return;

    setState(() {
      selectedMonth = picked.month;
      selectedYear = picked.year;
    });
  }

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  void _show() {
    if (selectedDoctor == null || selectedDoctor == 'SELECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a doctor.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Showing $selectedDoctor for ${_monthText()}. '
              'Database data will be loaded after API connection.',
        ),
      ),
    );
  }

  Widget _doctorDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDoctor,
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
          selectedDoctor = value;
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Monthly Net'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor
            _doctorDropdown(),

            const SizedBox(height: 12),

            // Month
            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
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
              icon: const Icon(Icons.visibility_outlined),
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
              time: '9:00 AM to 3:00 PM',
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
              time: '3:00 PM to 9:00 PM',
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
              time: '9:00 PM to 9:00 AM',
              selectedRow: selectedShiftCRow,
              onRowSelected: (index) {
                setState(() {
                  selectedShiftCRow = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}