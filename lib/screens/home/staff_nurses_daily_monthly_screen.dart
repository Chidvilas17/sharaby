import 'package:flutter/material.dart';

class StaffNursesDailyMonthlyScreen extends StatefulWidget {
  const StaffNursesDailyMonthlyScreen({super.key});

  @override
  State<StaffNursesDailyMonthlyScreen> createState() =>
      _StaffNursesDailyMonthlyScreenState();
}

class _StaffNursesDailyMonthlyScreenState
    extends State<StaffNursesDailyMonthlyScreen> {
  DateTime selectedDate = DateTime.now();

  // Shift A
  String? selectedNurseA;
  final TextEditingController notesAController = TextEditingController();
  final List<NurseAttendanceRow> shiftARows = [];
  int? selectedRowA;

  // Shift B
  String? selectedNurseB;
  final TextEditingController notesBController = TextEditingController();
  final List<NurseAttendanceRow> shiftBRows = [];
  int? selectedRowB;

  // Shift C
  String? selectedNurseC;
  final TextEditingController notesCController = TextEditingController();
  final List<NurseAttendanceRow> shiftCRows = [];
  int? selectedRowC;

  @override
  void dispose() {
    notesAController.dispose();
    notesBController.dispose();
    notesCController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  void _showData() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Showing nurse attendance for ${_formatDate(selectedDate)}. '
              'Database data will be loaded after API connection.',
        ),
      ),
    );
  }

  void _addNurse({
    required String? nurse,
    required TextEditingController notesController,
    required List<NurseAttendanceRow> rows,
    required String shift,
  }) {
    if (nurse == null || nurse == 'SELECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    setState(() {
      rows.add(
        NurseAttendanceRow(
          name: nurse,
          notes: notesController.text.trim(),
        ),
      );

      notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nurse added to $shift.'),
      ),
    );
  }

  Widget _nurseDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Nurse',
        border: OutlineInputBorder(),
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

  Widget _addPanel({
    required String title,
    required String? nurse,
    required ValueChanged<String?> onNurseChanged,
    required TextEditingController notesController,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
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
              color: Colors.blue,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _nurseDropdown(
            value: nurse,
            onChanged: onNurseChanged,
          ),

          const SizedBox(height: 10),

          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTable({
    required String shift,
    required String time,
    required List<NurseAttendanceRow> rows,
    required int? selectedRow,
    required ValueChanged<int> onRowSelected,
  }) {
    const headers = [
      'No.',
      'Name',
      'Notes',
      'Accountant',
    ];

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
                    color: Color(0xFF4D88B5),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                ...List.generate(
                  rows.isEmpty ? 8 : rows.length,
                      (index) {
                    final hasData = index < rows.length;
                    final row = hasData ? rows[index] : null;
                    final isSelected = selectedRow == index;

                    return TableRow(
                      children: [
                        _tableCell(
                          text: '${index + 1}',
                          selected: isSelected,
                          onTap: () => onRowSelected(index),
                        ),
                        _tableCell(
                          text: row?.name ?? '',
                          selected: isSelected,
                          onTap: () => onRowSelected(index),
                        ),
                        _tableCell(
                          text: row?.notes ?? '',
                          selected: isSelected,
                          onTap: () => onRowSelected(index),
                        ),
                        _tableCell(
                          text: '',
                          selected: isSelected,
                          onTap: () => onRowSelected(index),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurses Daily Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DATE + SHOW
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                        ),
                      ),
                      child: Text(
                        _formatDate(selectedDate),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: _showData,
                  child: const Text('Show'),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // SHIFT A
            _buildShiftTable(
              shift: 'Shift A',
              time: '8:00 AM to 2:00 PM',
              rows: shiftARows,
              selectedRow: selectedRowA,
              onRowSelected: (index) {
                setState(() {
                  selectedRowA = index;
                });
              },
            ),

            _addPanel(
              title: 'Add Nurse Shift A',
              nurse: selectedNurseA,
              onNurseChanged: (value) {
                setState(() {
                  selectedNurseA = value;
                });
              },
              notesController: notesAController,
              onAdd: () {
                _addNurse(
                  nurse: selectedNurseA,
                  notesController: notesAController,
                  rows: shiftARows,
                  shift: 'Shift A',
                );
              },
            ),

            // SHIFT B
            _buildShiftTable(
              shift: 'Shift B',
              time: '2:00 PM to 8:00 PM',
              rows: shiftBRows,
              selectedRow: selectedRowB,
              onRowSelected: (index) {
                setState(() {
                  selectedRowB = index;
                });
              },
            ),

            _addPanel(
              title: 'Add Nurse Shift B',
              nurse: selectedNurseB,
              onNurseChanged: (value) {
                setState(() {
                  selectedNurseB = value;
                });
              },
              notesController: notesBController,
              onAdd: () {
                _addNurse(
                  nurse: selectedNurseB,
                  notesController: notesBController,
                  rows: shiftBRows,
                  shift: 'Shift B',
                );
              },
            ),

            // SHIFT C
            _buildShiftTable(
              shift: 'Shift C',
              time: '8:00 PM to 8:00 AM',
              rows: shiftCRows,
              selectedRow: selectedRowC,
              onRowSelected: (index) {
                setState(() {
                  selectedRowC = index;
                });
              },
            ),

            _addPanel(
              title: 'Add Nurse Shift C',
              nurse: selectedNurseC,
              onNurseChanged: (value) {
                setState(() {
                  selectedNurseC = value;
                });
              },
              notesController: notesCController,
              onAdd: () {
                _addNurse(
                  nurse: selectedNurseC,
                  notesController: notesCController,
                  rows: shiftCRows,
                  shift: 'Shift C',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NurseAttendanceRow {
  final String name;
  final String notes;

  NurseAttendanceRow({
    required this.name,
    required this.notes,
  });
}