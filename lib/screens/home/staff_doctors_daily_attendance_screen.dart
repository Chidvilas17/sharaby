import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/doctor_attendance_api_service.dart';

class StaffDoctorsDailyAttendanceScreen
    extends StatefulWidget {
  const StaffDoctorsDailyAttendanceScreen({
    super.key,
  });

  @override
  State<StaffDoctorsDailyAttendanceScreen>
  createState() =>
      _StaffDoctorsDailyAttendanceScreenState();
}

class _StaffDoctorsDailyAttendanceScreenState
    extends State<StaffDoctorsDailyAttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  // =========================
  // DOCTORS
  // =========================

  List<Map<String, dynamic>> doctors = [];

  bool loadingDoctors = false;
  bool loadingAttendance = false;

  // =========================
  // SHIFT A
  // =========================

  int? selectedDoctorA;
  bool specialDayA = false;

  final TextEditingController notesAController =
  TextEditingController();

  List<Map<String, dynamic>> shiftARows = [];

  int? selectedRowA;

  // =========================
  // SHIFT B
  // =========================

  int? selectedDoctorB;
  bool specialDayB = false;

  final TextEditingController notesBController =
  TextEditingController();

  List<Map<String, dynamic>> shiftBRows = [];

  int? selectedRowB;

  // =========================
  // SHIFT C
  // =========================

  int? selectedDoctorC;
  bool specialDayC = false;

  final TextEditingController notesCController =
  TextEditingController();

  List<Map<String, dynamic>> shiftCRows = [];

  int? selectedRowC;

  @override
  void initState() {
    super.initState();

    _loadDoctors();
    _loadAttendance();
  }

  @override
  void dispose() {
    notesAController.dispose();
    notesBController.dispose();
    notesCController.dispose();

    super.dispose();
  }

  // =========================
  // DATE
  // =========================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  Future<void> _pickDate() async {
    final picked =
    await showDatePicker(
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

  // =========================
  // LOAD DOCTORS
  // =========================

  Future<void> _loadDoctors() async {
    setState(() {
      loadingDoctors = true;
    });

    try {
      final data =
      await DoctorAttendanceApiService
          .getDoctors();

      if (!mounted) return;

      setState(() {
        doctors = data
            .map(
              (doctor) =>
          Map<String, dynamic>.from(
            doctor,
          ),
        )
            .where(
              (doctor) =>
          doctor['id'] != null &&
              doctor['name'] != null &&
              doctor['name']
                  .toString()
                  .trim()
                  .isNotEmpty,
        )
            .toList();

        loadingDoctors = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingDoctors = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // SHOW
  // =========================

  Future<void> _showData() async {
    await _loadAttendance();
  }

  // =========================
  // LOAD ATTENDANCE
  // =========================

  Future<void> _loadAttendance() async {
    setState(() {
      loadingAttendance = true;
    });

    try {
      final data =
      await DoctorAttendanceApiService
          .getAttendance(
        selectedDate,
      );

      if (!mounted) return;

      setState(() {
        shiftARows =
            _convertRows(data['shiftA']);

        shiftBRows =
            _convertRows(data['shiftB']);

        shiftCRows =
            _convertRows(data['shiftC']);

        selectedRowA = null;
        selectedRowB = null;
        selectedRowC = null;

        loadingAttendance = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAttendance = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  List<Map<String, dynamic>> _convertRows(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // =========================
  // ADD DOCTOR
  // =========================

  Future<void> _addDoctor({
    required int? doctor,
    required bool specialDay,
    required TextEditingController
    notesController,
    required String shift,
  }) async {
    if (doctor == null) {
      _showMessage(
        'Please select a doctor first.',
      );
      return;
    }

    try {
      await DoctorAttendanceApiService
          .addAttendance(
        shift: shift,
        doctorId: doctor,
        date: selectedDate,
        notes:
        notesController.text.trim(),
        specialDay: specialDay,
      );

      if (!mounted) return;

      notesController.clear();

      _showMessage(
        'Doctor added to Shift $shift.',
      );

      await _loadAttendance();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> _deleteRow({
    required List<Map<String, dynamic>> rows,
    required int? selectedRow,
    required String shift,
  }) async {
    if (selectedRow == null ||
        selectedRow < 0 ||
        selectedRow >= rows.length) {
      _showMessage(
        'Please select a row first.',
      );
      return;
    }

    final row = rows[selectedRow];

    final id = row['id'];

    if (id == null) {
      _showMessage(
        'Attendance record ID was not found.',
      );
      return;
    }

    try {
      await DoctorAttendanceApiService
          .deleteAttendance(
        shift: shift,
        id: id as int,
      );

      if (!mounted) return;

      _showMessage(
        'Attendance deleted.',
      );

      await _loadAttendance();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // DOCTOR DROPDOWN
  // =========================

  Widget _doctorDropdown({
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    if (loadingDoctors) {
      return SizedBox(
        height: 56,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (doctors.isEmpty) {
      return Container(
        height: 56,
        alignment: Alignment.centerLeft,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius:
          BorderRadius.circular(4),
        ),
        child: Text(AppTranslations.tr('No doctors found in EmpsData.'),
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration:
      InputDecoration(
        labelText: AppTranslations.tr('Doctor'),
        border:
        OutlineInputBorder(),
      ),
      items: doctors.map(
            (doctor) {
          final id =
          doctor['id'] as int;

          final name =
              doctor['name']
                  ?.toString() ??
                  '';

          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              name,
              overflow:
              TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: onChanged,
    );
  }

  // =========================
  // ADD PANEL
  // =========================

  Widget _addPanel({
    required String title,
    required int? doctor,
    required ValueChanged<int?>
    onDoctorChanged,
    required bool specialDay,
    required ValueChanged<bool?>
    onSpecialDayChanged,
    required TextEditingController
    notesController,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(12),
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),
      decoration:
      BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: Colors.red,
              fontSize: 17,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 10,
          ),

          _doctorDropdown(
            value: doctor,
            onChanged:
            onDoctorChanged,
          ),

          SizedBox(
            height: 8,
          ),

          Row(
            children: [
              Checkbox(
                value:
                specialDay,
                onChanged:
                onSpecialDayChanged,
              ),
              Expanded(
                child: Text(AppTranslations.tr('Special Day'),
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 8,
          ),

          TextField(
            controller:
            notesController,
            maxLines: 2,
            decoration:
            InputDecoration(
              labelText: AppTranslations.tr('Notes'),
              border:
              OutlineInputBorder(),
            ),
          ),

          SizedBox(
            height: 10,
          ),

          ElevatedButton.icon(
            onPressed:
            loadingAttendance
                ? null
                : onAdd,
            icon:
            const Icon(
              Icons.add,
            ),
            label:
            Text(AppTranslations.tr('Add')),
          ),
        ],
      ),
    );
  }

  // =========================
  // SHIFT TABLE
  // =========================

  Widget _buildShiftTable({
    required String shift,
    required String time,
    required List<Map<String, dynamic>>
    rows,
    required int? selectedRow,
    required ValueChanged<int>
    onRowSelected,
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Text(
          shift,
          textAlign:
          TextAlign.center,
          style:
          const TextStyle(
            fontSize: 24,
            fontWeight:
            FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        SizedBox(
          height: 4,
        ),

        Text(
          time,
          textAlign:
          TextAlign.center,
          style:
          const TextStyle(
            fontSize: 17,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        SizedBox(
          height: 10,
        ),

        if (loadingAttendance)
          Padding(
            padding:
            EdgeInsets.all(20),
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: Table(
              defaultColumnWidth:
              const FixedColumnWidth(
                135,
              ),
              border:
              TableBorder.all(
                color:
                Colors.black54,
                width: 0.7,
              ),
              children: [
                const TableRow(
                  children: [
                    _TableHeader(
                      'No.',
                    ),
                    _TableHeader(
                      'Name',
                    ),
                    _TableHeader(
                      'Notes',
                    ),
                    _TableHeader(
                      'Accountant',
                    ),
                  ],
                ),

                ...List.generate(
                  rows.isEmpty
                      ? 10
                      : rows.length,
                      (index) {
                    final hasData =
                        index <
                            rows.length;

                    final row =
                    hasData
                        ? rows[index]
                        : null;

                    final isSelected =
                        selectedRow ==
                            index;

                    return TableRow(
                      children: [
                        _tableCell(
                          text:
                          '${index + 1}',
                          selected:
                          isSelected,
                          onTap: () {
                            onRowSelected(
                              index,
                            );
                          },
                        ),

                        _tableCell(
                          text:
                          row?['name']
                              ?.toString() ??
                              '',
                          selected:
                          isSelected,
                          onTap: () {
                            onRowSelected(
                              index,
                            );
                          },
                        ),

                        _tableCell(
                          text:
                          row?['notes']
                              ?.toString() ??
                              '',
                          selected:
                          isSelected,
                          onTap: () {
                            onRowSelected(
                              index,
                            );
                          },
                        ),

                        _tableCell(
                          text:
                          row?['accountant']
                              ?.toString() ??
                              '',
                          selected:
                          isSelected,
                          onTap: () {
                            onRowSelected(
                              index,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

        SizedBox(
          height: 10,
        ),

        Align(
          alignment:
          Alignment.centerRight,
          child:
          ElevatedButton.icon(
            onPressed:
            loadingAttendance
                ? null
                : onDelete,
            icon:
            const Icon(
              Icons.delete_outline,
            ),
            label:
            Text(AppTranslations.tr('Delete'),
            ),
          ),
        ),

        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  // =========================
  // TABLE CELL
  // =========================

  static Widget _tableCell({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment:
        Alignment.center,
        padding:
        const EdgeInsets.all(5),
        color: selected
            ? Colors.blue
            .withValues(alpha: 0.15)
            : const Color(
          0xFFD3DFE9,
        ),
        child: Text(
          text,
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Doctors Attendance'),
        ),
      ),
      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            // DATE
            Row(
              children: [
                Expanded(
                  child:
                  InkWell(
                    onTap:
                    _pickDate,
                    child:
                    InputDecorator(
                      decoration:
                      InputDecoration(
                        labelText: AppTranslations.tr('Date'),
                        border:
                        OutlineInputBorder(),
                        suffixIcon:
                        Icon(
                          Icons
                              .calendar_month,
                        ),
                      ),
                      child:
                      Text(
                        _formatDate(
                          selectedDate,
                        ),
                        textAlign:
                        TextAlign
                            .center,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 10,
                ),

                ElevatedButton(
                  onPressed:
                  loadingAttendance
                      ? null
                      : _showData,
                  child:
                  Text(AppTranslations.tr('Show'),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 24,
            ),

            // =========================
            // SHIFT A
            // =========================

            _buildShiftTable(
              shift: 'Shift A',
              time:
              '9:00 AM to 3:00 PM',
              rows: shiftARows,
              selectedRow:
              selectedRowA,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedRowA =
                      index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows:
                  shiftARows,
                  selectedRow:
                  selectedRowA,
                  shift: 'A',
                );
              },
            ),

            _addPanel(
              title:
              'Add Doctor Shift A',
              doctor:
              selectedDoctorA,
              onDoctorChanged:
                  (value) {
                setState(() {
                  selectedDoctorA =
                      value;
                });
              },
              specialDay:
              specialDayA,
              onSpecialDayChanged:
                  (value) {
                setState(() {
                  specialDayA =
                      value ?? false;
                });
              },
              notesController:
              notesAController,
              onAdd: () {
                _addDoctor(
                  doctor:
                  selectedDoctorA,
                  specialDay:
                  specialDayA,
                  notesController:
                  notesAController,
                  shift: 'A',
                );
              },
            ),

            // =========================
            // SHIFT B
            // =========================

            _buildShiftTable(
              shift: 'Shift B',
              time:
              '3:00 PM to 9:00 PM',
              rows: shiftBRows,
              selectedRow:
              selectedRowB,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedRowB =
                      index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows:
                  shiftBRows,
                  selectedRow:
                  selectedRowB,
                  shift: 'B',
                );
              },
            ),

            _addPanel(
              title:
              'Add Doctor Shift B',
              doctor:
              selectedDoctorB,
              onDoctorChanged:
                  (value) {
                setState(() {
                  selectedDoctorB =
                      value;
                });
              },
              specialDay:
              specialDayB,
              onSpecialDayChanged:
                  (value) {
                setState(() {
                  specialDayB =
                      value ?? false;
                });
              },
              notesController:
              notesBController,
              onAdd: () {
                _addDoctor(
                  doctor:
                  selectedDoctorB,
                  specialDay:
                  specialDayB,
                  notesController:
                  notesBController,
                  shift: 'B',
                );
              },
            ),

            // =========================
            // SHIFT C
            // =========================

            _buildShiftTable(
              shift: 'Shift C',
              time:
              '9:00 PM to 9:00 AM',
              rows: shiftCRows,
              selectedRow:
              selectedRowC,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedRowC =
                      index;
                });
              },
              onDelete: () {
                _deleteRow(
                  rows:
                  shiftCRows,
                  selectedRow:
                  selectedRowC,
                  shift: 'C',
                );
              },
            ),

            _addPanel(
              title:
              'Add Doctor Shift C',
              doctor:
              selectedDoctorC,
              onDoctorChanged:
                  (value) {
                setState(() {
                  selectedDoctorC =
                      value;
                });
              },
              specialDay:
              specialDayC,
              onSpecialDayChanged:
                  (value) {
                setState(() {
                  specialDayC =
                      value ?? false;
                });
              },
              notesController:
              notesCController,
              onAdd: () {
                _addDoctor(
                  doctor:
                  selectedDoctorC,
                  specialDay:
                  specialDayC,
                  notesController:
                  notesCController,
                  shift: 'C',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// TABLE HEADER
// =========================

class _TableHeader
    extends StatelessWidget {
  final String text;

  const _TableHeader(
      this.text,
      );

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 48,
      alignment:
      Alignment.center,
      padding:
      const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}