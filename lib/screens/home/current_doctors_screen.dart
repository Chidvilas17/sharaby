import 'package:flutter/material.dart';

import '../../services/doctor_monthly_net_api_service.dart';

class CurrentDoctorsScreen extends StatefulWidget {
  const CurrentDoctorsScreen({super.key});

  @override
  State<CurrentDoctorsScreen> createState() =>
      _CurrentDoctorsScreenState();
}

class _CurrentDoctorsScreenState
    extends State<CurrentDoctorsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController monthController =
  TextEditingController();

  // ============================================================
  // DOCTORS
  // ============================================================

  List<dynamic> doctors = [];

  int? selectedDoctorId;
  String? selectedDoctorName;

  // ============================================================
  // MONTH
  // ============================================================

  late int selectedMonth;
  late int selectedYear;

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> shiftARecords = [];
  List<Map<String, dynamic>> shiftBRecords = [];
  List<Map<String, dynamic>> shiftCRecords = [];

  int shiftACount = 0;
  int shiftBCount = 0;
  int shiftCCount = 0;

  double shiftASalary = 0;
  double shiftBSalary = 0;
  double shiftCSalary = 0;
  double totalSalary = 0;

  // ============================================================
  // STATE
  // ============================================================

  bool loadingDoctors = false;
  bool loadingSalary = false;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedMonth = now.month;
    selectedYear = now.year;

    monthController.text =
    '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';

    _loadDoctors();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    monthController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DOCTORS
  // ============================================================

  Future<void> _loadDoctors() async {
    setState(() {
      loadingDoctors = true;
      errorMessage = null;
    });

    try {
      final result =
      await DoctorMonthlyNetApiService.getDoctors();

      if (!mounted) return;

      setState(() {
        doctors = result;

        loadingDoctors = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingDoctors = false;
        errorMessage =
        'Failed to load doctors: $e';
      });
    }
  }

  // ============================================================
  // SHOW SALARY
  // ============================================================

  Future<void> _showSalary() async {
    if (selectedDoctorId == null) {
      _showMessage(
        'Please select a doctor.',
      );
      return;
    }

    if (!_parseMonth()) {
      _showMessage(
        'Please enter the month as MM/YYYY.',
      );
      return;
    }

    setState(() {
      loadingSalary = true;
      errorMessage = null;

      shiftARecords = [];
      shiftBRecords = [];
      shiftCRecords = [];

      shiftACount = 0;
      shiftBCount = 0;
      shiftCCount = 0;

      shiftASalary = 0;
      shiftBSalary = 0;
      shiftCSalary = 0;
      totalSalary = 0;
    });

    try {
      final result =
      await DoctorMonthlyNetApiService
          .getMonthlyAttendance(
        doctorId: selectedDoctorId!,
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      final shiftA =
      _convertList(result['shiftA']);

      final shiftB =
      _convertList(result['shiftB']);

      final shiftC =
      _convertList(result['shiftC']);

      final counts =
      result['counts'] as Map<String, dynamic>?;

      final salary =
      result['salary'] as Map<String, dynamic>?;

      setState(() {
        shiftARecords = shiftA;
        shiftBRecords = shiftB;
        shiftCRecords = shiftC;

        shiftACount =
            _toInt(counts?['shiftA']) ??
                shiftA.length;

        shiftBCount =
            _toInt(counts?['shiftB']) ??
                shiftB.length;

        shiftCCount =
            _toInt(counts?['shiftC']) ??
                shiftC.length;

        shiftASalary =
            _toDouble(salary?['shiftA']);

        shiftBSalary =
            _toDouble(salary?['shiftB']);

        shiftCSalary =
            _toDouble(salary?['shiftC']);

        totalSalary =
            _toDouble(salary?['total']);

        loadingSalary = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSalary = false;
        errorMessage =
        'Failed to load monthly salary: $e';
      });

      _showMessage(
        'Failed to load monthly salary.',
      );
    }
  }

  // ============================================================
  // PARSE MONTH
  // ============================================================

  bool _parseMonth() {
    final value =
    monthController.text.trim();

    final parts = value.split('/');

    if (parts.length != 2) {
      return false;
    }

    final month =
    int.tryParse(parts[0]);

    final year =
    int.tryParse(parts[1]);

    if (month == null ||
        year == null ||
        month < 1 ||
        month > 12 ||
        year < 2000 ||
        year > 2100) {
      return false;
    }

    selectedMonth = month;
    selectedYear = year;

    monthController.text =
    '${month.toString().padLeft(2, '0')}/$year';

    return true;
  }

  // ============================================================
  // CONVERT LIST
  // ============================================================

  List<Map<String, dynamic>> _convertList(
      dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(
        item as Map,
      ),
    )
        .toList();
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
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
          "Total Doctors' Salaries",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // SELECT AND SHOW
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select and Show',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Select the name',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  loadingDoctors
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      : DropdownButtonFormField<int>(
                    value:
                    selectedDoctorId,
                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                    hint: const Text(
                      'Select doctor',
                    ),
                    isExpanded: true,
                    items: doctors.map<
                        DropdownMenuItem<int>>(
                          (doctor) {
                        final id =
                        _toInt(
                          doctor['id'],
                        );

                        final name =
                            doctor['name']
                                ?.toString() ??
                                '';

                        return DropdownMenuItem<
                            int>(
                          value: id,
                          child:
                          Text(name),
                        );
                      },
                    ).toList(),
                    onChanged:
                        (value) {
                      setState(() {
                        selectedDoctorId =
                            value;

                        final doctor =
                        doctors
                            .where(
                              (d) =>
                          _toInt(
                            d[
                            'id'],
                          ) ==
                              value,
                        )
                            .toList();

                        selectedDoctorName =
                        doctor.isNotEmpty
                            ? doctor.first[
                        'name']
                            ?.toString()
                            : null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                    monthController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                      hintText: 'MM/YYYY',
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child:
                      ElevatedButton(
                        onPressed:
                        loadingSalary
                            ? null
                            : _showSalary,
                        child:
                        loadingSalary
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                          ),
                        )
                            : const Text(
                          'Show',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // ERROR
            // ==================================================

            if (errorMessage != null) ...[
              const SizedBox(height: 12),

              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ==================================================
            // SHIFT A
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift A',
              time:
              'From 9:00 AM to 3:00 PM',
              records: shiftARecords,
              count: shiftACount,
              salary: shiftASalary,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // SHIFT B
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift B',
              time:
              'From 3:00 PM to 9:00 PM',
              records: shiftBRecords,
              count: shiftBCount,
              salary: shiftBSalary,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // SHIFT C
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift C',
              time:
              'From 9:00 PM to 9:00 AM',
              records: shiftCRecords,
              count: shiftCCount,
              salary: shiftCSalary,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // SALARY SUMMARY
            // ==================================================

            _buildSalarySummary(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHIFT SECTION
  // ============================================================

  Widget _buildShiftSection({
    required String shiftName,
    required String time,
    required List<Map<String, dynamic>>
    records,
    required int count,
    required double salary,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              shiftName,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
                color:
                _getShiftColor(
                  shiftName,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '($count)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 220,
          decoration:
          BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius:
            BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // ==============================================
              // HEADER
              // ==============================================

              Container(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.grey.shade100,
                  border: Border(
                    bottom:
                    BorderSide(
                      color: Colors
                          .grey.shade400,
                    ),
                  ),
                ),
                child:
                const Row(
                  children: [
                    SizedBox(
                      width: 45,
                      child: Text(
                        'No.',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Notes',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Accountant',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================
              // DATA
              // ==============================================

              Expanded(
                child: records.isEmpty
                    ? const Center(
                  child: Text(
                    'No data',
                    style:
                    TextStyle(
                      color:
                      Colors
                          .grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount:
                  records.length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final record =
                    records[
                    index];

                    return Container(
                      height: 42,
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        10,
                      ),
                      decoration:
                      BoxDecoration(
                        border:
                        Border(
                          bottom:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),
                      ),
                      child:
                      Row(
                        children: [
                          SizedBox(
                            width: 45,
                            child:
                            Text(
                              '${index + 1}',
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child:
                            Text(
                              record[
                              'notes']
                                  ?.toString() ??
                                  '',
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child:
                            Text(
                              record[
                              'accountant']
                                  ?.toString() ??
                                  '',
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ),

                          Expanded(
                            child:
                            Text(
                              _formatDate(
                                record[
                                'date'],
                              ),
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment:
          Alignment.centerRight,
          child: Text(
            'Shift Salary: ${_formatMoney(salary)}',
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),
      ],
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
          color: Colors.grey.shade300,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Align(
            alignment:
            Alignment.centerLeft,
            child: Text(
              'Salary Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              const Text(
                'Shift A',
              ),
              Text(
                '$shiftACount',
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              const Text(
                'Shift B',
              ),
              Text(
                '$shiftBCount',
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              const Text(
                'Shift C',
              ),
              Text(
                '$shiftCCount',
              ),
            ],
          ),

          const Divider(
            height: 24,
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              const Text(
                'Total Salary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              Text(
                _formatMoney(
                  totalSalary,
                ),
                style:
                const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final date =
    DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(2);
  }

  // ============================================================
  // SHIFT COLORS
  // ============================================================

  Color _getShiftColor(
      String shiftName) {
    switch (shiftName) {
      case 'Shift A':
        return Colors.red;

      case 'Shift B':
        return Colors.blue;

      case 'Shift C':
        return Colors.green;

      default:
        return Colors.black;
    }
  }
}