import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/doctor_monthly_net_api_service.dart';

class StaffDoctorsMonthlyNetScreen
    extends StatefulWidget {
  const StaffDoctorsMonthlyNetScreen({
    super.key,
  });

  @override
  State<StaffDoctorsMonthlyNetScreen>
  createState() =>
      _StaffDoctorsMonthlyNetScreenState();
}

class _StaffDoctorsMonthlyNetScreenState
    extends State<StaffDoctorsMonthlyNetScreen> {
  // ==========================================
  // DOCTOR
  // ==========================================

  int? selectedDoctorId;
  String? selectedDoctorName;

  List<Map<String, dynamic>> doctors = [];

  bool loadingDoctors = false;
  bool loadingData = false;

  // ==========================================
  // MONTH
  // ==========================================

  int selectedMonth =
      DateTime.now().month;

  int selectedYear =
      DateTime.now().year;

  // ==========================================
  // DATA
  // ==========================================

  List<Map<String, dynamic>>
  shiftARows = [];

  List<Map<String, dynamic>>
  shiftBRows = [];

  List<Map<String, dynamic>>
  shiftCRows = [];

  int? selectedShiftARow;
  int? selectedShiftBRow;
  int? selectedShiftCRow;

  // ==========================================
  // HEADERS
  // ==========================================

  final List<String> headers = [
    'No.',
    'Notes',
    'Accountant',
    'Date',
  ];

  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();

    _loadDoctors();
  }

  // ==========================================
  // LOAD DOCTORS
  // ==========================================

  Future<void> _loadDoctors() async {
    setState(() {
      loadingDoctors = true;
    });

    try {
      final data =
      await DoctorMonthlyNetApiService
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

  // ==========================================
  // SELECT MONTH
  // ==========================================

  Future<void> _selectMonth() async {
    int tempMonth =
        selectedMonth;

    int tempYear =
        selectedYear;

    final picked =
    await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: Text(AppTranslations.tr('Select Month'),
                textAlign:
                TextAlign.center,
              ),
              content: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  DropdownButtonFormField<
                      int>(
                    initialValue: tempMonth,
                    decoration:
                    InputDecoration(
                      labelText: AppTranslations.tr('Month'),
                      border:
                      OutlineInputBorder(),
                    ),
                    items:
                    List.generate(
                      12,
                          (index) {
                        final month =
                            index + 1;

                        return DropdownMenuItem<
                            int>(
                          value: month,
                          child: Text(
                            month
                                .toString()
                                .padLeft(
                              2,
                              '0',
                            ),
                          ),
                        );
                      },
                    ),
                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setDialogState(() {
                        tempMonth =
                            value;
                      });
                    },
                  ),

                  SizedBox(
                    height: 12,
                  ),

                  DropdownButtonFormField<
                      int>(
                    initialValue: tempYear,
                    decoration:
                    InputDecoration(
                      labelText: AppTranslations.tr('Year'),
                      border:
                      OutlineInputBorder(),
                    ),
                    items:
                    List.generate(
                      101,
                          (index) {
                        final year =
                            2000 +
                                index;

                        return DropdownMenuItem<
                            int>(
                          value: year,
                          child: Text(
                            '$year',
                          ),
                        );
                      },
                    ),
                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setDialogState(() {
                        tempYear =
                            value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                  Text(AppTranslations.tr('Cancel'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(
                        tempYear,
                        tempMonth,
                      ),
                    );
                  },
                  child:
                  Text(AppTranslations.tr('Select'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedMonth =
          picked.month;

      selectedYear =
          picked.year;
    });
  }

  // ==========================================
  // MONTH TEXT
  // ==========================================

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  // ==========================================
  // SHOW
  // ==========================================

  Future<void> _show() async {
    if (selectedDoctorId == null) {
      _showMessage(
        'Please select a doctor.',
      );
      return;
    }

    setState(() {
      loadingData = true;

      shiftARows = [];
      shiftBRows = [];
      shiftCRows = [];

      selectedShiftARow = null;
      selectedShiftBRow = null;
      selectedShiftCRow = null;
    });

    try {
      final data =
      await DoctorMonthlyNetApiService
          .getMonthlyAttendance(
        doctorId:
        selectedDoctorId!,
        month:
        selectedMonth,
        year:
        selectedYear,
      );

      if (!mounted) return;

      setState(() {
        shiftARows =
            _convertRows(
              data['shiftA'],
            );

        shiftBRows =
            _convertRows(
              data['shiftB'],
            );

        shiftCRows =
            _convertRows(
              data['shiftC'],
            );

        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================
  // CONVERT ROWS
  // ==========================================

  List<Map<String, dynamic>> _convertRows(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  // ==========================================
  // DOCTOR DROPDOWN
  // ==========================================

  Widget _doctorDropdown() {
    if (loadingDoctors) {
      return SizedBox(
        height: 56,
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (doctors.isEmpty) {
      return Container(
        height: 56,
        alignment:
        Alignment.centerLeft,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration:
        BoxDecoration(
          border:
          Border.all(
            color: Colors.red,
          ),
          borderRadius:
          BorderRadius.circular(
            4,
          ),
        ),
        child: Text(AppTranslations.tr('No doctors found in EmpsData.'),
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedDoctorId,
      isExpanded: true,
      decoration:
      InputDecoration(
        labelText: AppTranslations.tr('Select Name'),
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
      onChanged: (value) {
        if (value == null) {
          return;
        }

        final selected =
        doctors.firstWhere(
              (doctor) =>
          doctor['id'] == value,
        );

        setState(() {
          selectedDoctorId =
              value;

          selectedDoctorName =
              selected['name']
                  ?.toString();
        });
      },
    );
  }

  // ==========================================
  // SHIFT TABLE
  // ==========================================

  Widget _buildShiftTable({
    required String shift,
    required String time,
    required List<Map<String, dynamic>>
    rows,
    required int? selectedRow,
    required ValueChanged<int>
    onRowSelected,
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

        Container(
          decoration:
          BoxDecoration(
            border:
            Border.all(
              color: Colors.grey,
            ),
          ),
          child:
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
                TableRow(
                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFFEFEFEF),
                  ),
                  children:
                  headers.map(
                        (header) {
                      return Container(
                        height: 48,
                        alignment:
                        Alignment.center,
                        padding:
                        const EdgeInsets.all(
                          5,
                        ),
                        child:
                        Text(
                          header,
                          textAlign:
                          TextAlign
                              .center,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),

                if (loadingData)
                  TableRow(
                    children: List
                        .generate(
                      headers.length,
                          (_) =>
                      SizedBox(
                        height: 42,
                        child:
                        Center(
                          child:
                          SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (rows.isEmpty)
                  ...List.generate(
                    8,
                        (index) {
                      return TableRow(
                        children:
                        headers.map(
                              (header) {
                            return Container(
                              height: 42,
                              alignment:
                              Alignment
                                  .center,
                              child:
                              Text(
                                header ==
                                    'No.'
                                    ? '${index + 1}'
                                    : '',
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
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
                        children:
                        headers.map(
                              (header) {
                            String text =
                                '';

                            if (header ==
                                'No.') {
                              text =
                              '${index + 1}';
                            } else if (header ==
                                'Notes') {
                              text =
                                  row['notes']
                                      ?.toString() ??
                                      '';
                            } else if (header ==
                                'Accountant') {
                              text =
                                  row['accountant']
                                      ?.toString() ??
                                      '';
                            } else if (header ==
                                'Date') {
                              text =
                                  _formatDatabaseDate(
                                    row['date'],
                                  );
                            }

                            return GestureDetector(
                              onTap: () {
                                onRowSelected(
                                  index,
                                );
                              },
                              child:
                              Container(
                                height:
                                42,
                                alignment:
                                Alignment.center,
                                padding:
                                const EdgeInsets.all(
                                  5,
                                ),
                                color:
                                isSelected
                                    ? Colors
                                    .blue
                                    .withValues(
                                  alpha: 0.12,
                                )
                                    : Colors
                                    .transparent,
                                child:
                                Text(
                                  text,
                                  textAlign:
                                  TextAlign
                                      .center,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        SizedBox(
          height: 24,
        ),
      ],
    );
  }

  // ==========================================
  // DATE FORMAT
  // ==========================================

  String _formatDatabaseDate(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final parsed =
    DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return value.toString();
    }

    final day =
    parsed.day.toString().padLeft(
      2,
      '0',
    );

    final month =
    parsed.month.toString().padLeft(
      2,
      '0',
    );

    return '$day-$month-${parsed.year}';
  }

  // ==========================================
  // MESSAGE
  // ==========================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Doctors Monthly Net'),
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
            // =========================
            // DOCTOR
            // =========================

            _doctorDropdown(),

            SizedBox(
              height: 12,
            ),

            // =========================
            // MONTH
            // =========================

            InkWell(
              onTap:
              _selectMonth,
              child:
              InputDecorator(
                decoration:
                InputDecoration(
                  labelText: AppTranslations.tr('Month'),
                  border:
                  OutlineInputBorder(),
                  suffixIcon:
                  Icon(
                    Icons
                        .calendar_month,
                  ),
                ),
                child: Text(
                  _monthText(),
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),

            SizedBox(
              height: 12,
            ),

            // =========================
            // SHOW
            // =========================

            ElevatedButton.icon(
              onPressed:
              loadingData
                  ? null
                  : _show,
              icon:
              const Icon(
                Icons
                    .visibility_outlined,
              ),
              label:
              Text(AppTranslations.tr('Show'),
              ),
              style:
              ElevatedButton
                  .styleFrom(
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 14,
                ),
              ),
            ),

            SizedBox(
              height: 28,
            ),

            // =========================
            // SHIFT A
            // =========================

            _buildShiftTable(
              shift:
              'Shift A',
              time:
              '9:00 AM to 3:00 PM',
              rows:
              shiftARows,
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

            // =========================
            // SHIFT B
            // =========================

            _buildShiftTable(
              shift:
              'Shift B',
              time:
              '3:00 PM to 9:00 PM',
              rows:
              shiftBRows,
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

            // =========================
            // SHIFT C
            // =========================

            _buildShiftTable(
              shift:
              'Shift C',
              time:
              '9:00 PM to 9:00 AM',
              rows:
              shiftCRows,
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
          ],
        ),
      ),
    );
  }
}