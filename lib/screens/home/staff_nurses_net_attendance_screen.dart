import 'package:flutter/material.dart';
import '../../services/nurse_attendance_api_service.dart';

class StaffNursesNetAttendanceScreen extends StatefulWidget {
  const StaffNursesNetAttendanceScreen({super.key});

  @override
  State<StaffNursesNetAttendanceScreen> createState() =>
      _StaffNursesNetAttendanceScreenState();
}

class _StaffNursesNetAttendanceScreenState
    extends State<StaffNursesNetAttendanceScreen> {
  // ============================================================
  // NURSES
  // ============================================================
  List<Map<String, dynamic>> nurses = [];
  bool loadingNurses = false;

  String? selectedNurse;

  // ============================================================
  // MONTH
  // ============================================================
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // ============================================================
  // ATTENDANCE
  // ============================================================
  bool loadingAttendance = false;

  List<NetAttendanceRow> shiftARows = [];
  List<NetAttendanceRow> shiftBRows = [];
  List<NetAttendanceRow> shiftCRows = [];

  int? selectedShiftARow;
  int? selectedShiftBRow;
  int? selectedShiftCRow;

  // ============================================================
  // HEADERS
  // ============================================================
  final List<String> headers = [
    'No.',
    'Notes',
    'Accountant',
    'Date',
  ];

  @override
  void initState() {
    super.initState();
    _loadNurses();
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
  // SELECT MONTH
  // ============================================================
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
                    items: List.generate(
                      12,
                          (index) {
                        final month = index + 1;

                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                            month
                                .toString()
                                .padLeft(2, '0'),
                          ),
                        );
                      },
                    ),
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
                      DateTime(
                        tempYear,
                        tempMonth,
                      ),
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

  // ============================================================
  // MONTH TEXT
  // ============================================================
  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  // ============================================================
  // GET NURSE ID
  // ============================================================
  int? _getSelectedNurseId() {
    if (selectedNurse == null ||
        selectedNurse == 'SELECT') {
      return null;
    }

    return int.tryParse(selectedNurse!);
  }

  // ============================================================
  // GET NURSE NAME
  // ============================================================
  String _getSelectedNurseName() {
    final id = _getSelectedNurseId();

    if (id == null) {
      return '';
    }

    for (final nurse in nurses) {
      if (nurse['id'].toString() == id.toString()) {
        return nurse['name']?.toString() ?? '';
      }
    }

    return '';
  }

  // ============================================================
  // SHOW / LOAD DATA
  // ============================================================
  Future<void> _show() async {
    final empId = _getSelectedNurseId();

    if (empId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nurse.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loadingAttendance = true;
    });

    try {
      final result =
      await NurseAttendanceApiService
          .getNetAttendance(
        empId: empId,
        month: selectedMonth,
        year: selectedYear,
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

      final newShiftA =
      <NetAttendanceRow>[];

      final newShiftB =
      <NetAttendanceRow>[];

      final newShiftC =
      <NetAttendanceRow>[];

      for (final item in shiftAData) {
        final data =
        Map<String, dynamic>.from(item);

        newShiftA.add(
          NetAttendanceRow(
            id: data['id'],
            notes:
            data['notes']?.toString() ?? '',
            accountant:
            data['done']?.toString() ?? '',
            date: _formatApiDate(
              data['date'],
            ),
          ),
        );
      }

      for (final item in shiftBData) {
        final data =
        Map<String, dynamic>.from(item);

        newShiftB.add(
          NetAttendanceRow(
            id: data['id'],
            notes:
            data['notes']?.toString() ?? '',
            accountant:
            data['done']?.toString() ?? '',
            date: _formatApiDate(
              data['date'],
            ),
          ),
        );
      }

      for (final item in shiftCData) {
        final data =
        Map<String, dynamic>.from(item);

        newShiftC.add(
          NetAttendanceRow(
            id: data['id'],
            notes:
            data['notes']?.toString() ?? '',
            accountant:
            data['done']?.toString() ?? '',
            date: _formatApiDate(
              data['date'],
            ),
          ),
        );
      }

      setState(() {
        shiftARows = newShiftA;
        shiftBRows = newShiftB;
        shiftCRows = newShiftC;

        selectedShiftARow = null;
        selectedShiftBRow = null;
        selectedShiftCRow = null;

        loadingAttendance = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance loaded for '
                '${_getSelectedNurseName()} '
                'for $_monthText().',
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
  // FORMAT API DATE
  // ============================================================
  String _formatApiDate(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      final day =
      date.day.toString().padLeft(2, '0');

      final month =
      date.month.toString().padLeft(2, '0');

      return '$day-$month-${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  // ============================================================
  // NURSE DROPDOWN
  // ============================================================
  Widget _nurseDropdown() {
    if (loadingNurses) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Name',
          border: OutlineInputBorder(),
        ),
        child: Center(
          child: Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 8,
            ),
            child:
            CircularProgressIndicator(),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedNurse,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Select Name',
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
                nurse['name']?.toString() ??
                    '';

            return DropdownMenuItem<String>(
              value: id.toString(),
              child: Text(name),
            );
          },
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedNurse = value;
        });
      },
    );
  }

  // ============================================================
  // SHIFT TABLE
  // ============================================================
  Widget _buildShiftTable({
    required String shift,
    required String time,
    required List<NetAttendanceRow> rows,
    required int? selectedRow,
    required ValueChanged<int> onRowSelected,
  }) {
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
                    color: Color(0xFFEFEFEF),
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
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),

                if (rows.isEmpty)
                  ...List.generate(
                    8,
                        (index) =>
                        _emptyTableRow(
                          index,
                        ),
                  )
                else
                  ...List.generate(
                    rows.length,
                        (index) {
                      final row =
                      rows[index];

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
                            onTap: () =>
                                onRowSelected(
                                  index,
                                ),
                          ),

                          _tableCell(
                            text: row.notes,
                            selected:
                            isSelected,
                            onTap: () =>
                                onRowSelected(
                                  index,
                                ),
                          ),

                          _tableCell(
                            text:
                            row.accountant,
                            selected:
                            isSelected,
                            onTap: () =>
                                onRowSelected(
                                  index,
                                ),
                          ),

                          _tableCell(
                            text: row.date,
                            selected:
                            isSelected,
                            onTap: () =>
                                onRowSelected(
                                  index,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  // ============================================================
  // EMPTY TABLE ROW
  // ============================================================
  TableRow _emptyTableRow(int index) {
    return TableRow(
      children: headers.map(
            (header) {
          return Container(
            height: 42,
            alignment: Alignment.center,
            child: Text(
              header == 'No.'
                  ? '${index + 1}'
                  : '',
            ),
          );
        },
      ).toList(),
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
        padding:
        const EdgeInsets.all(5),
        color: selected
            ? Colors.blue.withOpacity(
          0.12,
        )
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================
  Widget _summaryRow({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign:
              TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          SizedBox(
            width: 80,
            child: Text(
              value,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SALARY SUMMARY
  // ============================================================
  Widget _buildSalarySummary() {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
          const Text(
            'Net Salary',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
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

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nurses Net Attendance',
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            // NURSE
            _nurseDropdown(),

            const SizedBox(height: 12),

            // MONTH
            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration:
                const InputDecoration(
                  labelText: 'Month',
                  border:
                  OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_month,
                  ),
                ),
                child: Text(
                  _monthText(),
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SHOW
            ElevatedButton.icon(
              onPressed:
              loadingAttendance
                  ? null
                  : _show,
              icon: loadingAttendance
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons
                    .visibility_outlined,
              ),
              label: Text(
                loadingAttendance
                    ? 'Loading...'
                    : 'Show',
              ),
              style:
              ElevatedButton.styleFrom(
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // SHIFT A
            _buildShiftTable(
              shift: 'Shift A',
              time:
              '12:00 AM to 8:00 AM',
              rows: shiftARows,
              selectedRow:
              selectedShiftARow,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedShiftARow =
                      index;
                });
              },
            ),

            // SHIFT B
            _buildShiftTable(
              shift: 'Shift B',
              time:
              '8:00 AM to 4:00 PM',
              rows: shiftBRows,
              selectedRow:
              selectedShiftBRow,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedShiftBRow =
                      index;
                });
              },
            ),

            // SHIFT C
            _buildShiftTable(
              shift: 'Shift C',
              time:
              '4:00 PM to 12:00 AM',
              rows: shiftCRows,
              selectedRow:
              selectedShiftCRow,
              onRowSelected:
                  (index) {
                setState(() {
                  selectedShiftCRow =
                      index;
                });
              },
            ),

            // SALARY SUMMARY
            _buildSalarySummary(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// NET ATTENDANCE ROW
// ================================================================
class NetAttendanceRow {
  final int? id;
  final String notes;
  final String accountant;
  final String date;

  NetAttendanceRow({
    this.id,
    required this.notes,
    required this.accountant,
    required this.date,
  });
}