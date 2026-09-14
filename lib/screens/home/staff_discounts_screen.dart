import 'package:flutter/material.dart';

class StaffDiscountsScreen extends StatefulWidget {
  const StaffDiscountsScreen({super.key});

  @override
  State<StaffDiscountsScreen> createState() =>
      _StaffDiscountsScreenState();
}

class _StaffDiscountsScreenState extends State<StaffDiscountsScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String selectedType = 'Nurses';
  int? selectedRow;

  final List<String> headers = [
    'Name',
    'Deductions',
    'Advances',
    'Bonuses',
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
      selectedRow = null;
    });
  }

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  Widget _typeRadio(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedType = title;
          selectedRow = null;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: title,
            groupValue: selectedType,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedType = value;
                selectedRow = null;
              });
            },
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCell({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        color: selected
            ? Colors.blue.withOpacity(0.12)
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(145),
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
                  height: 50,
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

            ...List.generate(18, (index) {
              final isSelected = selectedRow == index;

              return TableRow(
                children: [
                  _tableCell(
                    text: '',
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedRow = index;
                      });
                    },
                  ),
                  _tableCell(
                    text: '',
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedRow = index;
                      });
                    },
                  ),
                  _tableCell(
                    text: '',
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedRow = index;
                      });
                    },
                  ),
                  _tableCell(
                    text: '',
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedRow = index;
                      });
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discounts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MONTH
            Row(
              children: [
                const Text(
                  'Month:',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    onTap: _selectMonth,
                    child: InputDecorator(
                      decoration: const InputDecoration(
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
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TYPE SELECTION
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 5,
              children: [
                _typeRadio('Nurses'),
                _typeRadio('Accountants'),
                _typeRadio('Laborers'),
              ],
            ),

            const SizedBox(height: 25),

            // CURRENT SELECTION
            Text(
              '$selectedType - ${_monthText()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // TABLE
            _buildTable(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}