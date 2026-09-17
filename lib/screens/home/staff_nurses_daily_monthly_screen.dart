import 'package:flutter/material.dart';
import '../../services/nurse_attendance_api_service.dart';

class StaffNursesDailyMonthlyScreen extends StatefulWidget {
  const StaffNursesDailyMonthlyScreen({super.key});

  @override
  State<StaffNursesDailyMonthlyScreen> createState() =>
      _StaffNursesDailyMonthlyScreenState();
}

class _StaffNursesDailyMonthlyScreenState
    extends State<StaffNursesDailyMonthlyScreen> {
  DateTime selectedDate = DateTime.now();

  // Nurses loaded from API
  List<Map<String, dynamic>> nurses = [];
  bool loadingNurses = false;

  // Attendance loading
  bool loadingAttendance = false;

  // Saving states
  bool savingShiftA = false;
  bool savingShiftB = false;
  bool savingShiftC = false;

  // Shift A
  String? selectedNurseA;
  final TextEditingController notesAController =
  TextEditingController();
  final List<NurseAttendanceRow> shiftARows = [];
  int? selectedRowA;

  // Shift B
  String? selectedNurseB;
  final TextEditingController notesBController =
  TextEditingController();
  final List<NurseAttendanceRow> shiftBRows = [];
  int? selectedRowB;

  // Shift C
  String? selectedNurseC;
  final TextEditingController notesCController =
  TextEditingController();
  final List<NurseAttendanceRow> shiftCRows = [];
  int? selectedRowC;

  @override
  void initState() {
    super.initState();
    _loadNurses();
  }

  @override
  void dispose() {
    notesAController.dispose();
    notesBController.dispose();
    notesCController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD NURSES
  // ============================================================
  Future<void> _loadNurses() async {
    setState(() {
      loadingNurses = true;
    });

    try {
      final result =
      await NurseAttendanceApiService.getNurses();

      if (!mounted) return;

      setState(() {
        nurses = result;
        loadingNurses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingNurses = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load nurses.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // SELECT DATE
  // ============================================================
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

  // ============================================================
  // SHOW DATA
  // ============================================================
  Future<void> _showData() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loadingAttendance = true;
    });

    try {
      final result =
      await NurseAttendanceApiService.getAttendance(
        selectedDate,
      );

      if (!mounted) return;

      final shiftAData =
      result['shiftA'] is List
          ? result['shiftA'] as List
          : [];

      final shiftBData =
      result['shiftB'] is List
          ? result['shiftB'] as List
          : [];

      final shiftCData =
      result['shiftC'] is List
          ? result['shiftC'] as List
          : [];

      setState(() {
        shiftARows.clear();
        shiftBRows.clear();
        shiftCRows.clear();

        selectedRowA = null;
        selectedRowB = null;
        selectedRowC = null;

        for (final item in shiftAData) {
          final data =
          Map<String, dynamic>.from(item);

          shiftARows.add(
            NurseAttendanceRow(
              id: data['id'],
              empId: data['emp_Id'],
              name: data['name']?.toString() ?? '',
              notes: data['notes']?.toString() ?? '',
              userId: data['user_id'],
              done: data['done']?.toString(),
            ),
          );
        }

        for (final item in shiftBData) {
          final data =
          Map<String, dynamic>.from(item);

          shiftBRows.add(
            NurseAttendanceRow(
              id: data['id'],
              empId: data['emp_Id'],
              name: data['name']?.toString() ?? '',
              notes: data['notes']?.toString() ?? '',
              userId: data['user_id'],
              done: data['done']?.toString(),
            ),
          );
        }

        for (final item in shiftCData) {
          final data =
          Map<String, dynamic>.from(item);

          shiftCRows.add(
            NurseAttendanceRow(
              id: data['id'],
              empId: data['emp_Id'],
              name: data['name']?.toString() ?? '',
              notes: data['notes']?.toString() ?? '',
              userId: data['user_id'],
              done: data['done']?.toString(),
            ),
          );
        }

        loadingAttendance = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance loaded for '
                '${_formatDate(selectedDate)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAttendance = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load attendance.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // GET NURSE NAME
  // ============================================================
  String _getNurseName(String? nurseId) {
    if (nurseId == null || nurseId == 'SELECT') {
      return '';
    }

    Map<String, dynamic>? nurse;

    for (final item in nurses) {
      if (item['id'].toString() == nurseId) {
        nurse = item;
        break;
      }
    }

    return nurse?['name']?.toString() ?? '';
  }

  // ============================================================
  // GET NURSE ID
  // ============================================================
  int? _getNurseId(String? nurseId) {
    if (nurseId == null || nurseId == 'SELECT') {
      return null;
    }

    return int.tryParse(nurseId);
  }

  // ============================================================
  // ADD SHIFT A
  // ============================================================
  Future<void> _addShiftA() async {
    final empId = _getNurseId(selectedNurseA);

    if (empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    setState(() {
      savingShiftA = true;
    });

    final notes = notesAController.text.trim();

    try {
      await NurseAttendanceApiService.addShiftA(
        empId: empId,
        date: selectedDate,
        notes: notes,
        userId: null,
      );

      if (!mounted) return;

      final nurseName =
      _getNurseName(selectedNurseA);

      setState(() {
        savingShiftA = false;
        notesAController.clear();
        selectedNurseA = 'SELECT';
      });

      await _showData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$nurseName added to Shift A.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingShiftA = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save Shift A.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD SHIFT B
  // ============================================================
  Future<void> _addShiftB() async {
    final empId = _getNurseId(selectedNurseB);

    if (empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    setState(() {
      savingShiftB = true;
    });

    final notes = notesBController.text.trim();

    try {
      await NurseAttendanceApiService.addShiftB(
        empId: empId,
        date: selectedDate,
        notes: notes,
        userId: null,
      );

      if (!mounted) return;

      final nurseName =
      _getNurseName(selectedNurseB);

      setState(() {
        savingShiftB = false;
        notesBController.clear();
        selectedNurseB = 'SELECT';
      });

      await _showData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$nurseName added to Shift B.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingShiftB = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save Shift B.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD SHIFT C
  // ============================================================
  Future<void> _addShiftC() async {
    final empId = _getNurseId(selectedNurseC);

    if (empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    setState(() {
      savingShiftC = true;
    });

    final notes = notesCController.text.trim();

    try {
      await NurseAttendanceApiService.addShiftC(
        empId: empId,
        date: selectedDate,
        notes: notes,
        userId: null,
      );

      if (!mounted) return;

      final nurseName =
      _getNurseName(selectedNurseC);

      setState(() {
        savingShiftC = false;
        notesCController.clear();
        selectedNurseC = 'SELECT';
      });

      await _showData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$nurseName added to Shift C.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingShiftC = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save Shift C.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // NURSE DROPDOWN
  // ============================================================
  Widget _nurseDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    if (loadingNurses) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Nurse',
          border: OutlineInputBorder(),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Nurse',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: 'SELECT',
          child: Text('Select'),
        ),
        ...nurses.map(
              (nurse) {
            final id = nurse['id'];
            final name =
                nurse['name']?.toString() ?? '';

            return DropdownMenuItem<String>(
              value: id.toString(),
              child: Text(name),
            );
          },
        ),
      ],
      onChanged: onChanged,
    );
  }

  // ============================================================
  // ADD PANEL
  // ============================================================
  Widget _addPanel({
    required String title,
    required String? nurse,
    required ValueChanged<String?> onNurseChanged,
    required TextEditingController notesController,
    required VoidCallback onAdd,
    required bool saving,
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
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
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
            onPressed: saving ? null : onAdd,
            icon: saving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.add),
            label: Text(
              saving ? 'Saving...' : 'Add',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHIFT TABLE
  // ============================================================
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
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
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
            scrollDirection:
            Axis.horizontal,
            child: Table(
              defaultColumnWidth:
              const FixedColumnWidth(135),
              border: TableBorder.all(
                color: Colors.black54,
                width: 0.7,
              ),
              children: [
                TableRow(
                  decoration:
                  const BoxDecoration(
                    color: Color(0xFF4D88B5),
                  ),
                  children: headers.map(
                        (header) {
                      return Container(
                        height: 48,
                        alignment:
                        Alignment.center,
                        padding:
                        const EdgeInsets.all(5),
                        child: Text(
                          header,
                          textAlign:
                          TextAlign.center,
                          style:
                          const TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),

                ...List.generate(
                  rows.isEmpty
                      ? 8
                      : rows.length,
                      (index) {
                    final hasData =
                        index < rows.length;

                    final row =
                    hasData
                        ? rows[index]
                        : null;

                    final isSelected =
                        selectedRow == index;

                    return TableRow(
                      children: [
                        _tableCell(
                          text:
                          '${index + 1}',
                          selected:
                          isSelected,
                          onTap: () =>
                              onRowSelected(
                                  index),
                        ),

                        _tableCell(
                          text:
                          row?.name ?? '',
                          selected:
                          isSelected,
                          onTap: () =>
                              onRowSelected(
                                  index),
                        ),

                        _tableCell(
                          text:
                          row?.notes ?? '',
                          selected:
                          isSelected,
                          onTap: () =>
                              onRowSelected(
                                  index),
                        ),

                        _tableCell(
                          text: '',
                          selected:
                          isSelected,
                          onTap: () =>
                              onRowSelected(
                                  index),
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

  // ============================================================
  // TABLE CELL
  // ============================================================
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

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nurses Daily Attendance',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            // DATE + SHOW
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(
                        labelText: 'Date',
                        border:
                        OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                        ),
                      ),
                      child: Text(
                        _formatDate(
                          selectedDate,
                        ),
                        textAlign:
                        TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed:
                  loadingAttendance
                      ? null
                      : _showData,
                  child: loadingAttendance
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Show'),
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
              notesController:
              notesAController,
              saving: savingShiftA,
              onAdd: _addShiftA,
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
              notesController:
              notesBController,
              saving: savingShiftB,
              onAdd: _addShiftB,
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
              notesController:
              notesCController,
              saving: savingShiftC,
              onAdd: _addShiftC,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// NURSE ATTENDANCE ROW
// ================================================================
class NurseAttendanceRow {
  final int? id;
  final int? empId;
  final String name;
  final String notes;
  final int? userId;
  final String? done;

  NurseAttendanceRow({
    this.id,
    this.empId,
    required this.name,
    required this.notes,
    this.userId,
    this.done,
  });
}