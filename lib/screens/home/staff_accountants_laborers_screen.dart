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
                    initialValue: tempMonth,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      12,
                          (index) {
                        final month = index + 1;

                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                            month.toString().padLeft(2, '0'),
                          ),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        tempMonth = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    initialValue: tempYear,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      101,
                          (index) {
                        final year = 2000 + index;

                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        tempYear = value;
                      });
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

  void _showAccountant() {
    if (selectedAccountant == null) {
      _message('Please select an accountant.');
      return;
    }

    _message(
      'Showing $selectedAccountant for ${_monthText()}.',
    );
  }

  void _showLaborer() {
    if (selectedLaborer == null) {
      _message('Please select a laborer.');
      return;
    }

    _message(
      'Showing $selectedLaborer for ${_monthText()}.',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _personDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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
        DropdownMenuItem<String>(
          value: 'DATABASE',
          child: Text('Load from database'),
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

  Widget _employeeSection({
    required String title,
    required String? selectedPerson,
    required ValueChanged<String?> onChanged,
    required VoidCallback onShow,
  }) {
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
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _personDropdown(
            label: 'Select Name',
            value: selectedPerson,
            onChanged: onChanged,
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: onShow,
            child: const Text('Show'),
          ),

          const SizedBox(height: 12),

          const Text(
            '--',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MONTH
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

            const SizedBox(height: 20),

            // ACCOUNTANTS
            _employeeSection(
              title: 'Accountants',
              selectedPerson: selectedAccountant,
              onChanged: (value) {
                setState(() {
                  selectedAccountant = value;
                });
              },
              onShow: _showAccountant,
            ),

            const SizedBox(height: 20),

            // LABORERS
            _employeeSection(
              title: 'Laborers',
              selectedPerson: selectedLaborer,
              onChanged: (value) {
                setState(() {
                  selectedLaborer = value;
                });
              },
              onShow: _showLaborer,
            ),
          ],
        ),
      ),
    );
  }
}