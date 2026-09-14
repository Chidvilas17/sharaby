import 'package:flutter/material.dart';

class StaffDoctorsDailyAttendanceScreen extends StatefulWidget {
  const StaffDoctorsDailyAttendanceScreen({super.key});

  @override
  State<StaffDoctorsDailyAttendanceScreen> createState() =>
      _StaffDoctorsDailyAttendanceScreenState();
}

class _StaffDoctorsDailyAttendanceScreenState
    extends State<StaffDoctorsDailyAttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  // Shift A
  String? selectedDoctorA;
  bool specialDayA = false;
  final TextEditingController notesAController = TextEditingController();
  final List<AttendanceRow> shiftARows = [];
  int? selectedRowA;

  // Shift B
  String? selectedDoctorB;
  bool specialDayB = false;
  final TextEditingController notesBController = TextEditingController();
  final List<AttendanceRow> shiftBRows = [];
  int? selectedRowB;

  // Shift C
  String? selectedDoctorC;
  bool specialDayC = false;
  final TextEditingController notesCController = TextEditingController();
  final List<AttendanceRow> shiftCRows = [];
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

  Future<void> _pickDate() async {
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
          'Showing attendance for ${_formatDate(selectedDate)}. '
              'Database data will be loaded after API connection.',
        ),
      ),
    );
  }

  void _addDoctor({
    required String? doctor,
    required bool specialDay,
    required TextEditingController notesController,
    required List<AttendanceRow> rows,
    required String shift,
  }) {
    if (doctor == null || doctor == 'SELECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a doctor.'),
        ),
      );
      return;
    }

    setState(() {
      rows.add(
        AttendanceRow(
          name: doctor,
          notes: notesController.text.trim(),
          specialDay: specialDay,
        ),
      );

      notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$doctor added to $shift.'),
      ),
    );
  }

  void _deleteRow({
    required List<AttendanceRow> rows,
    required int? selectedRow,
    required VoidCallback clearSelection,
    required String shift,
  }) {
    if (selectedRow == null ||
        selectedRow < 0 ||
        selectedRow >= rows.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a row first.'),
        ),
      );
      return;
    }

    setState(() {
      rows.removeAt(selectedRow);
      clearSelection();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected $shift attendance row deleted.'),
      ),
    );
  }

  Widget _doctorDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Doctor',
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
    required String? doctor,
    required ValueChanged<String?> onDoctorChanged,
    required bool specialDay,
    required ValueChanged<bool?> onSpecialDayChanged,
    required TextEditingController notesController,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
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
              color: Colors.red,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _doctorDropdown(
            value: doctor,
            onChanged: onDoctorChanged,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Checkbox(
                value: specialDay,
                onChanged: onSpecialDayChanged,
              ),
              const Expanded(
                child: Text(
                  'Special Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

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
    required List<AttendanceRow> rows,
    required int? selectedRow,
    required ValueChanged<int> onRowSelected,
    required VoidCallback onDelete,
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

        SingleChildScrollView(
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
                children: const [
                  _TableHeader('No.'),
                  _TableHeader('Name'),
                  _TableHeader('Notes'),
                  _TableHeader('Accountant'),
                ],
              ),

              ...List.generate(
                rows.isEmpty ? 10 : rows.length,
                    (index) {
                  final hasData = index < rows.length;
                  final row = hasData ? rows[index] : null;
                  final isSelected = selectedRow == index;

                  return TableRow(
                    children: [
                      _tableCell(
                        text: '${index + 1}',
                        index: index,
                        selected: isSelected,
                        onTap: () => onRowSelected(index),
                      ),

                      _tableCell(
                        text: row?.name ?? '',
                        index: index,
                        selected: isSelected,
                        onTap: () => onRowSelected(index),
                      ),

                      _tableCell(
                        text: row?.notes ?? '',
                        index: index,
                        selected: isSelected,
                        onTap: () => onRowSelected(index),
                      ),

                      _tableCell(
                        text: '',
                        index: index,
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

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  static Widget _tableCell({
    required String text,
    required int index,
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
            ? Colors.blue.withOpacity(0.15)
            : const Color(0xFFD3DFE9),
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
        title: const Text('Doctors Attendance'),
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
                    onTap: _pickDate,
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

            const SizedBox(height: 24),

            // SHIFT A
            _buildShiftTable(
              shift: 'Shift A',
              time: '9:00 AM to 3:00 PM',
              rows: shiftARows,
              selectedRow: selectedRowA,
              onRowSelected: (index) {
                setState(() {
                  selectedRowA = index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows: shiftARows,
                  selectedRow: selectedRowA,
                  clearSelection: () {
                    selectedRowA = null;
                  },
                  shift: 'Shift A',
                );
              },
            ),

            _addPanel(
              title: 'Add Doctor Shift A',
              doctor: selectedDoctorA,
              onDoctorChanged: (value) {
                setState(() {
                  selectedDoctorA = value;
                });
              },
              specialDay: specialDayA,
              onSpecialDayChanged: (value) {
                setState(() {
                  specialDayA = value ?? false;
                });
              },
              notesController: notesAController,
              onAdd: () {
                _addDoctor(
                  doctor: selectedDoctorA,
                  specialDay: specialDayA,
                  notesController: notesAController,
                  rows: shiftARows,
                  shift: 'Shift A',
                );
              },
            ),

            // SHIFT B
            _buildShiftTable(
              shift: 'Shift B',
              time: '3:00 PM to 9:00 PM',
              rows: shiftBRows,
              selectedRow: selectedRowB,
              onRowSelected: (index) {
                setState(() {
                  selectedRowB = index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows: shiftBRows,
                  selectedRow: selectedRowB,
                  clearSelection: () {
                    selectedRowB = null;
                  },
                  shift: 'Shift B',
                );
              },
            ),

            _addPanel(
              title: 'Add Doctor Shift B',
              doctor: selectedDoctorB,
              onDoctorChanged: (value) {
                setState(() {
                  selectedDoctorB = value;
                });
              },
              specialDay: specialDayB,
              onSpecialDayChanged: (value) {
                setState(() {
                  specialDayB = value ?? false;
                });
              },
              notesController: notesBController,
              onAdd: () {
                _addDoctor(
                  doctor: selectedDoctorB,
                  specialDay: specialDayB,
                  notesController: notesBController,
                  rows: shiftBRows,
                  shift: 'Shift B',
                );
              },
            ),

            // SHIFT C
            _buildShiftTable(
              shift: 'Shift C',
              time: '9:00 PM to 9:00 AM',
              rows: shiftCRows,
              selectedRow: selectedRowC,
              onRowSelected: (index) {
                setState(() {
                  selectedRowC = index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows: shiftCRows,
                  selectedRow: selectedRowC,
                  clearSelection: () {
                    selectedRowC = null;
                  },
                  shift: 'Shift C',
                );
              },
            ),

            _addPanel(
              title: 'Add Doctor Shift C',
              doctor: selectedDoctorC,
              onDoctorChanged: (value) {
                setState(() {
                  selectedDoctorC = value;
                });
              },
              specialDay: specialDayC,
              onSpecialDayChanged: (value) {
                setState(() {
                  specialDayC = value ?? false;
                });
              },
              notesController: notesCController,
              onAdd: () {
                _addDoctor(
                  doctor: selectedDoctorC,
                  specialDay: specialDayC,
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

class AttendanceRow {
  final String name;
  final String notes;
  final bool specialDay;

  AttendanceRow({
    required this.name,
    required this.notes,
    required this.specialDay,
  });
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}