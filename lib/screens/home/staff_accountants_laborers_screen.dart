import 'package:flutter/material.dart';

class StaffAccountantsLaborersScreen extends StatefulWidget {
  const StaffAccountantsLaborersScreen({super.key});

  @override
  State<StaffAccountantsLaborersScreen> createState() =>
      _StaffAccountantsLaborersScreenState();
}

class _StaffAccountantsLaborersScreenState
    extends State<StaffAccountantsLaborersScreen> {
  String? selectedAccountant;
  String? selectedLaborer;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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

  Widget _personDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem<String>(
          value: 'SELECT',
          child: Text('Select'),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSection({
    required String title,
    required String? selectedPerson,
    required ValueChanged<String?> onPersonChanged,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _personDropdown(
              label: 'Select Name',
              value: selectedPerson,
              onChanged: onPersonChanged,
            ),

            const SizedBox(height: 20),

            const Text(
              '--',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 15),

            _summaryRow(
              label: 'Total Salary',
              value: '0',
              valueColor: Colors.black,
            ),

            _summaryRow(
              label: 'Deductions',
              value: '0',
              valueColor: Colors.red,
            ),

            _summaryRow(
              label: 'Advances',
              value: '0',
              valueColor: Colors.red,
            ),

            _summaryRow(
              label: 'Bonuses',
              value: '0',
              valueColor: Colors.green,
            ),

            _summaryRow(
              label: 'Net Salary',
              value: '0',
              valueColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountants and Laborers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Month',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  _monthText(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 650) {
                  return Column(
                    children: [
                      _buildEmployeeSection(
                        title: 'Accountants',
                        selectedPerson: selectedAccountant,
                        onPersonChanged: (value) {
                          setState(() {
                            selectedAccountant = value;
                          });
                        },
                      ),
                      const Divider(thickness: 1),
                      _buildEmployeeSection(
                        title: 'Laborers',
                        selectedPerson: selectedLaborer,
                        onPersonChanged: (value) {
                          setState(() {
                            selectedLaborer = value;
                          });
                        },
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmployeeSection(
                      title: 'Accountants',
                      selectedPerson: selectedAccountant,
                      onPersonChanged: (value) {
                        setState(() {
                          selectedAccountant = value;
                        });
                      },
                    ),
                    _buildEmployeeSection(
                      title: 'Laborers',
                      selectedPerson: selectedLaborer,
                      onPersonChanged: (value) {
                        setState(() {
                          selectedLaborer = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}