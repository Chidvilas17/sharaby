import 'package:flutter/material.dart';

import '../../services/current_nurses_api_service.dart';

class CurrentNursesScreen extends StatefulWidget {
  const CurrentNursesScreen({super.key});

  @override
  State<CurrentNursesScreen> createState() =>
      _CurrentNursesScreenState();
}

class _CurrentNursesScreenState
    extends State<CurrentNursesScreen> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController monthController =
  TextEditingController();

  // ============================================================
  // NURSES
  // ============================================================

  List<dynamic> nurses = [];

  int? selectedNurseId;

  // ============================================================
  // MONTH
  // ============================================================

  late int selectedMonth;
  late int selectedYear;

  // ============================================================
  // SHIFT DATA
  // ============================================================

  List<Map<String, dynamic>> shiftARecords = [];
  List<Map<String, dynamic>> shiftBRecords = [];
  List<Map<String, dynamic>> shiftCRecords = [];

  int shiftACount = 0;
  int shiftBCount = 0;
  int shiftCCount = 0;

  // ============================================================
  // SALARY
  // ============================================================

  double totalSalary = 0;
  double deductions = 0;
  double advances = 0;
  double bonuses = 0;
  double netSalary = 0;

  // ============================================================
  // STATE
  // ============================================================

  bool loadingNurses = false;
  bool loadingData = false;

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

    _loadNurses();
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
  // LOAD NURSES
  // ============================================================

  Future<void> _loadNurses() async {
    setState(() {
      loadingNurses = true;
      errorMessage = null;
    });

    try {
      final result =
      await CurrentNursesApiService
          .getNurses();

      if (!mounted) return;

      setState(() {
        nurses = result;
        loadingNurses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingNurses = false;
        errorMessage =
        'Failed to load nurses.';
      });
    }
  }

  // ============================================================
  // SHOW
  // ============================================================

  Future<void> _showSalary() async {
    if (selectedNurseId == null) {
      _showMessage(
        'Please select a nurse.',
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
      loadingData = true;
      errorMessage = null;

      shiftARecords = [];
      shiftBRecords = [];
      shiftCRecords = [];

      shiftACount = 0;
      shiftBCount = 0;
      shiftCCount = 0;

      totalSalary = 0;
      deductions = 0;
      advances = 0;
      bonuses = 0;
      netSalary = 0;
    });

    try {
      final result =
      await CurrentNursesApiService
          .getMonthlyAttendance(
        nurseId: selectedNurseId!,
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      final counts =
      result['counts']
      as Map<String, dynamic>?;

      final salary =
      result['salary']
      as Map<String, dynamic>?;

      setState(() {
        shiftARecords =
            _convertList(
              result['shiftA'],
            );

        shiftBRecords =
            _convertList(
              result['shiftB'],
            );

        shiftCRecords =
            _convertList(
              result['shiftC'],
            );

        shiftACount =
            _toInt(
              counts?['shiftA'],
            ) ??
                shiftARecords.length;

        shiftBCount =
            _toInt(
              counts?['shiftB'],
            ) ??
                shiftBRecords.length;

        shiftCCount =
            _toInt(
              counts?['shiftC'],
            ) ??
                shiftCRecords.length;

        totalSalary =
            _toDouble(
              salary?['total'],
            );

        deductions =
            _toDouble(
              salary?['deductions'],
            );

        advances =
            _toDouble(
              salary?['advances'],
            );

        bonuses =
            _toDouble(
              salary?['bonuses'],
            );

        netSalary =
            _toDouble(
              salary?['net'],
            );

        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
        errorMessage =
        'Failed to load monthly data.';
      });

      _showMessage(
        'Failed to load monthly data.',
      );
    }
  }

  // ============================================================
  // MONTH PARSER
  // ============================================================

  bool _parseMonth() {
    final value =
    monthController.text.trim();

    final parts =
    value.split('/');

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
  // LIST CONVERSION
  // ============================================================

  List<Map<String, dynamic>> _convertList(
      dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(
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

  void _showMessage(
      String message) {
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
          "Total Nurses' Salaries",
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // SELECT NURSE
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration:
              BoxDecoration(
                border: Border.all(
                  color:
                  Colors.grey.shade300,
                ),
                borderRadius:
                BorderRadius.circular(
                  8,
                ),
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

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Select the name',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  loadingNurses
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      : DropdownButtonFormField<
                      int>(
                    value:
                    selectedNurseId,
                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                    hint:
                    const Text(
                      'Select nurse',
                    ),
                    isExpanded: true,
                    items: nurses
                        .map<
                        DropdownMenuItem<
                            int>>(
                          (nurse) {
                        final id =
                        _toInt(
                          nurse['id'],
                        );

                        final name =
                            nurse['name']
                                ?.toString() ??
                                '';

                        return DropdownMenuItem<
                            int>(
                          value: id,
                          child:
                          Text(
                            name,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged:
                        (value) {
                      setState(() {
                        selectedNurseId =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    monthController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                      hintText:
                      'MM/YYYY',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child:
                      ElevatedButton(
                        onPressed:
                        loadingData
                            ? null
                            : _showSalary,
                        child:
                        loadingData
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

            if (errorMessage != null) ...[
              const SizedBox(
                height: 12,
              ),
              Text(
                errorMessage!,
                style:
                const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SHIFT A
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift A',
              time:
              'From 12:00 AM to 8:00 AM',
              records:
              shiftARecords,
              count:
              shiftACount,
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SHIFT B
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift B',
              time:
              'From 8:00 AM to 4:00 PM',
              records:
              shiftBRecords,
              count:
              shiftBCount,
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SHIFT C
            // ==================================================

            _buildShiftSection(
              shiftName: 'Shift C',
              time:
              'From 4:00 PM to 12:00 AM',
              records:
              shiftCRecords,
              count:
              shiftCCount,
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SUMMARY
            // ==================================================

            _buildSalarySummary(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHIFT TABLE
  // ============================================================

  Widget _buildShiftSection({
    required String shiftName,
    required String time,
    required List<Map<String, dynamic>>
    records,
    required int count,
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

            const SizedBox(
              width: 12,
            ),

            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          time,
          style:
          const TextStyle(
            fontSize: 14,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Container(
          height: 220,
          decoration:
          BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius:
            BorderRadius.circular(
              8,
            ),
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding:
                const EdgeInsets
                    .symmetric(
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
                child: const Row(
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

              // DATA
              Expanded(
                child: records.isEmpty
                    ? const Center(
                  child: Text(
                    'No data',
                    style:
                    TextStyle(
                      color:
                      Colors.grey,
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
      ],
    );
  }

  // ============================================================
  // SALARY SUMMARY
  // ============================================================

  Widget _buildSalarySummary() {
    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration:
      BoxDecoration(
        border: Border.all(
          color:
          Colors.grey.shade300,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Shift A',
            shiftACount.toString(),
            Colors.red,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Shift B',
            shiftBCount.toString(),
            Colors.blue,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Shift C',
            shiftCCount.toString(),
            Colors.green,
          ),

          const SizedBox(
            height: 24,
          ),

          _summaryRow(
            'Total Salary',
            _formatMoney(
              totalSalary,
            ),
            Colors.black,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Deductions',
            _formatMoney(
              deductions,
            ),
            Colors.red,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Advances',
            _formatMoney(
              advances,
            ),
            Colors.red,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Bonuses',
            _formatMoney(
              bonuses,
            ),
            Colors.green,
          ),

          const Divider(
            height: 28,
          ),

          _summaryRow(
            'Net Salary',
            _formatMoney(
              netSalary,
            ),
            Colors.blue,
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      String label,
      String value,
      Color valueColor, {
        bool bold = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:
            bold ? 18 : 16,
            fontWeight:
            bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:
            bold ? 18 : 16,
            fontWeight:
            bold
                ? FontWeight.bold
                : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
      dynamic value) {
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
  // MONEY
  // ============================================================

  String _formatMoney(
      double value) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }

  // ============================================================
  // COLORS
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