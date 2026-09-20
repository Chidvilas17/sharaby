import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/staff_salary_api_service.dart';

class TotalSalariesScreen extends StatefulWidget {
  const TotalSalariesScreen({super.key});

  @override
  State<TotalSalariesScreen> createState() =>
      _TotalSalariesScreenState();
}

class _TotalSalariesScreenState
    extends State<TotalSalariesScreen> {
  final TextEditingController monthController =
  TextEditingController(
    text: '09/2026',
  );

  final TextEditingController untilDateController =
  TextEditingController(
    text: '18-09-2026',
  );

  bool loading = false;

  List<dynamic> doctors = [];
  List<dynamic> nurses = [];
  List<dynamic> staff = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Automatically load the initial month.
    _showSalaries();
  }

  @override
  void dispose() {
    monthController.dispose();
    untilDateController.dispose();
    super.dispose();
  }

  // ============================================================
  // PARSE MONTH
  // ============================================================

  Map<String, int>? _parseMonth() {
    final value = monthController.text.trim();

    final parts = value.split('/');

    if (parts.length != 2) {
      return null;
    }

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null ||
        year == null ||
        month < 1 ||
        month > 12 ||
        year < 2000) {
      return null;
    }

    return {
      'month': month,
      'year': year,
    };
  }

  // ============================================================
  // PARSE UNTIL DATE
  //
  // Converts DD-MM-YYYY → YYYY-MM-DD
  // ============================================================

  String? _parseUntilDate() {
    final value =
    untilDateController.text.trim();

    if (value.isEmpty) {
      return null;
    }

    final parts = value.split('-');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null ||
        month == null ||
        year == null) {
      return null;
    }

    if (day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 2000) {
      return null;
    }

    return '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // SHOW
  // ============================================================

  Future<void> _showSalaries() async {
    final parsed = _parseMonth();

    if (parsed == null) {
      _showMessage(
        'Please enter month as MM/YYYY.',
      );
      return;
    }

    await _loadData(
      month: parsed['month']!,
      year: parsed['year']!,
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _filter() async {
    final parsed = _parseMonth();

    if (parsed == null) {
      _showMessage(
        'Please enter month as MM/YYYY.',
      );
      return;
    }

    final untilDate = _parseUntilDate();

    if (untilDateController.text
        .trim()
        .isNotEmpty &&
        untilDate == null) {
      _showMessage(
        'Please enter date as DD-MM-YYYY.',
      );
      return;
    }

    await _loadData(
      month: parsed['month']!,
      year: parsed['year']!,
      untilDate: untilDate,
    );
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData({
    required int month,
    required int year,
    String? untilDate,
  }) async {
    setState(() {
      loading = true;
    });

    try {
      final data =
      await StaffSalaryApiService
          .getMonthlySalaries(
        month: month,
        year: year,
        untilDate: untilDate,
      );

      if (!mounted) return;

      setState(() {
        doctors =
            (data['doctors'] as List?) ?? [];

        nurses =
            (data['nurses'] as List?) ?? [];

        staff =
            (data['staff'] as List?) ?? [];

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load salaries.\n$e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
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
        title: Text(AppTranslations.tr('Total Salaries'),
        ),
      ),

      body: loading
          ? Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _showSalaries,

        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // CONTROLS
              // ==================================================

              _buildControls(),

              SizedBox(height: 24),

              // ==================================================
              // DOCTORS SUMMARY
              // ==================================================

              _buildSectionTitle(
                'Doctors',
              ),

              _buildDoctorsTable(),

              SizedBox(height: 24),

              // ==================================================
              // SHIFT A
              // ==================================================

              _buildShiftSection(
                'Shift A',
                _allDoctorShiftRows(
                  'shiftA',
                ),
              ),

              SizedBox(height: 20),

              // ==================================================
              // SHIFT B
              // ==================================================

              _buildShiftSection(
                'Shift B',
                _allDoctorShiftRows(
                  'shiftB',
                ),
              ),

              SizedBox(height: 20),

              // ==================================================
              // SHIFT C
              // ==================================================

              _buildShiftSection(
                'Shift C',
                _allDoctorShiftRows(
                  'shiftC',
                ),
              ),

              SizedBox(height: 24),

              // ==================================================
              // NURSING
              // ==================================================

              _buildSectionTitle(
                'Nursing',
              ),

              _buildNursesTable(),

              SizedBox(height: 24),

              // ==================================================
              // ACCOUNTANTS + WORKERS
              // ==================================================

              _buildSectionTitle(
                'Accountants and Workers',
              ),

              _buildStaffTable(),

              SizedBox(height: 24),

              // ==================================================
              // TOTAL
              // ==================================================

              Container(
                padding:
                const EdgeInsets.all(20),

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

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Text(AppTranslations.tr('Total : '),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ==================================================
              // UNTIL DATE
              // ==================================================

              Text(AppTranslations.tr('Until Date'),
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              SizedBox(height: 8),

              TextField(
                controller:
                untilDateController,

                decoration:
                InputDecoration(
                  border:
                  OutlineInputBorder(),
                  hintText: AppTranslations.tr('DD-MM-YYYY'),
                ),
              ),

              SizedBox(height: 16),

              // ==================================================
              // FILTER
              // ==================================================

              SizedBox(
                height: 45,

                child: ElevatedButton(
                  onPressed: _filter,

                  child:
                  Text(AppTranslations.tr('Filter')),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),

        borderRadius:
        BorderRadius.circular(8),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [
          Text(AppTranslations.tr('Month'),
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w500,
            ),
          ),

          SizedBox(height: 8),

          TextField(
            controller:
            monthController,

            decoration:
            InputDecoration(
              border:
              OutlineInputBorder(),
              hintText: AppTranslations.tr('MM/YYYY'),
            ),
          ),

          SizedBox(height: 16),

          SizedBox(
            height: 45,

            child: ElevatedButton(
              onPressed:
              _showSalaries,

              child:
              Text(AppTranslations.tr('Show')),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),

      child: Text(
        title,

        style: const TextStyle(
          fontSize: 20,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // DOCTORS TABLE
  // ============================================================

  Widget _buildDoctorsTable() {
    return _buildDataTable(
      columns: [
        'Name',
        'Shift Count',
        'Special Shift',
        'Total',
      ],

      rows: doctors.map((doctor) {
        return [
          _stringValue(
            doctor['name'],
          ),
          _stringValue(
            doctor['shiftCount'],
          ),
          _stringValue(
            doctor['specialShift'],
          ),
          _stringValue(
            doctor['total'],
          ),
        ];
      }).toList(),

      height: 240,

      widths: const [
        200,
        120,
        120,
        100,
      ],
    );
  }

  // ============================================================
  // NURSES TABLE
  // ============================================================

  Widget _buildNursesTable() {
    return _buildDataTable(
      columns: [
        'No.',
        'Name',
        'A',
        'B',
        'C',
        'Total',
      ],

      rows: List.generate(
        nurses.length,
            (index) {
          final nurse =
          nurses[index];

          return [
            '${index + 1}',
            _stringValue(
              nurse['name'],
            ),
            _stringValue(
              nurse['a'],
            ),
            _stringValue(
              nurse['b'],
            ),
            _stringValue(
              nurse['c'],
            ),
            _stringValue(
              nurse['total'],
            ),
          ];
        },
      ),

      height: 280,

      widths: const [
        60,
        220,
        80,
        80,
        80,
        100,
      ],
    );
  }

  // ============================================================
  // STAFF TABLE
  // ============================================================

  Widget _buildStaffTable() {
    return _buildDataTable(
      columns: [
        'No.',
        'Name',
        'Salary',
      ],

      rows: List.generate(
        staff.length,
            (index) {
          final employee =
          staff[index];

          return [
            '${index + 1}',
            _stringValue(
              employee['name'],
            ),
            _stringValue(
              employee['salary'],
            ),
          ];
        },
      ),

      height: 220,

      widths: const [
        60,
        250,
        120,
      ],
    );
  }

  // ============================================================
  // DOCTOR SHIFT SECTION
  // ============================================================

  Widget _buildShiftSection(
      String shiftName,
      List<List<String>> rows,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        Text(
          shiftName,

          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,

            color: shiftName ==
                'Shift A'
                ? Colors.red
                : shiftName ==
                'Shift B'
                ? Colors.blue
                : Colors.green,
          ),
        ),

        SizedBox(height: 8),

        _buildDataTable(
          columns: [
            'No.',
            'Date',
            'Notes',
            'Type',
          ],

          rows: rows,

          height: 220,

          widths: const [
            60,
            140,
            220,
            100,
          ],
        ),
      ],
    );
  }

  // ============================================================
  // COLLECT SHIFT ROWS
  // ============================================================

  List<List<String>> _allDoctorShiftRows(
      String key,
      ) {
    final result =
    <List<String>>[];

    int number = 1;

    for (final doctor
    in doctors) {
      final rows =
          (doctor[key] as List?) ??
              [];

      for (final row
      in rows) {
        final date =
        row['date'];

        String dateText = '';

        if (date != null) {
          final parsed =
          DateTime.tryParse(
            date.toString(),
          );

          if (parsed != null) {
            dateText =
            '${parsed.day.toString().padLeft(2, '0')}-'
                '${parsed.month.toString().padLeft(2, '0')}-'
                '${parsed.year}';
          }
        }

        result.add([
          '$number',
          dateText,
          _stringValue(
            row['notes'],
          ),
          _stringValue(
            row['type'],
          ),
        ]);

        number++;
      }
    }

    return result;
  }

  // ============================================================
  // GENERIC DATA TABLE
  // ============================================================

  Widget _buildDataTable({
    required List<String> columns,
    required List<List<String>> rows,
    required double height,
    required List<double> widths,
  }) {
    final totalWidth =
    widths.fold<double>(
      0,
          (sum, width) =>
      sum + width,
    );

    return SizedBox(
      height: height,

      child: Container(
        decoration:
        BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),

          borderRadius:
          BorderRadius.circular(8),
        ),

        child:
        SingleChildScrollView(
          scrollDirection:
          Axis.horizontal,

          child: SizedBox(
            width: totalWidth,

            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  height: 50,

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade100,

                    border: Border(
                      bottom:
                      BorderSide(
                        color:
                        Colors.grey.shade400,
                      ),
                    ),
                  ),

                  child: Row(
                    children: [
                      for (
                      int i = 0;
                      i < columns.length;
                      i++
                      )
                        SizedBox(
                          width:
                          widths[i],

                          child:
                          Padding(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal:
                              8,
                            ),

                            child:
                            Align(
                              alignment:
                              Alignment.centerLeft,

                              child:
                              Text(
                                columns[i],

                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ==================================================
                // ROWS
                // ==================================================

                if (rows.isEmpty)
                  Expanded(
                    child:
                    Center(
                      child:
                      Text(AppTranslations.tr('No data'),

                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child:
                    ListView.builder(
                      itemCount:
                      rows.length,

                      itemBuilder:
                          (
                          context,
                          rowIndex,
                          ) {
                        final row =
                        rows[rowIndex];

                        return Container(
                          height: 45,

                          decoration:
                          BoxDecoration(
                            border:
                            Border(
                              bottom:
                              BorderSide(
                                color:
                                Colors.grey.shade300,
                              ),
                            ),
                          ),

                          child:
                          Row(
                            children: [
                              for (
                              int i = 0;
                              i < row.length;
                              i++
                              )
                                SizedBox(
                                  width:
                                  widths[i],

                                  child:
                                  Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      8,
                                    ),

                                    child:
                                    Text(
                                      row[i],
                                    ),
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
        ),
      ),
    );
  }

  // ============================================================
  // STRING VALUE
  // ============================================================

  String _stringValue(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }
}