import 'package:flutter/material.dart';
import '../../services/staff_rates_api_service.dart';

class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  // ============================================================
  // DATA
  // ============================================================

  List<dynamic> doctors = [];
  List<dynamic> nurses = [];
  List<dynamic> accountantsAndWorkers = [];

  bool loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadRates() async {
    setState(() {
      loading = true;
    });

    try {
      final employees =
      await StaffRatesApiService.getEmployees();

      if (!mounted) return;

      setState(() {
        // --------------------------------------------------------
        // DOCTORS
        // Cat_Id = 1
        // --------------------------------------------------------

        doctors = employees
            .where((e) => e['catId'] == 1)
            .toList();

        // --------------------------------------------------------
        // NURSES
        // Cat_Id = 3
        // --------------------------------------------------------

        nurses = employees
            .where((e) => e['catId'] == 3)
            .toList();

        // --------------------------------------------------------
        // ACCOUNTANTS + WORKERS
        // Cat_Id = 2 or 4
        // --------------------------------------------------------

        accountantsAndWorkers = employees
            .where(
              (e) =>
          e['catId'] == 2 ||
              e['catId'] == 4,
        )
            .toList();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load employee rates.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // NUMBER FORMAT
  // ============================================================

  String _value(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees Rates'),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadRates,

        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // DOCTORS
              // ==================================================

              _buildDoctorsSection(),

              const SizedBox(height: 24),

              // ==================================================
              // NURSING
              // ==================================================

              _buildNursingSection(),

              const SizedBox(height: 24),

              // ==================================================
              // ACCOUNTANTS & WORKERS
              // ==================================================

              _buildAccountantsWorkersSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DOCTORS SECTION
  // ============================================================

  Widget _buildDoctorsSection() {
    return _buildTableSection(
      title: 'Doctors',

      columns: const [
        'Name',
        'Rate',
        'Rate In Special Days',
      ],

      rows: doctors.map((employee) {
        return [
          _value(employee['name']),
          _value(employee['rate']),
          _value(employee['rateForSpecial']),
        ];
      }).toList(),

      columnWidths: const [
        200,
        100,
        180,
      ],
    );
  }

  // ============================================================
  // NURSING SECTION
  // ============================================================

  Widget _buildNursingSection() {
    return _buildTableSection(
      title: 'Nursing',

      columns: const [
        'Name',
        'A',
        'B',
        'C',
      ],

      rows: nurses.map((employee) {
        return [
          _value(employee['name']),
          _value(employee['rateForA']),
          _value(employee['rateForB']),
          _value(employee['rateForC']),
        ];
      }).toList(),

      columnWidths: const [
        220,
        100,
        100,
        100,
      ],
    );
  }

  // ============================================================
  // ACCOUNTANTS + WORKERS SECTION
  // ============================================================

  Widget _buildAccountantsWorkersSection() {
    return _buildTableSection(
      title: 'Accountants - and - Workers',

      columns: const [
        'Name',
        'Salary',
      ],

      rows: accountantsAndWorkers.map((employee) {
        return [
          _value(employee['name']),
          _value(employee['rate']),
        ];
      }).toList(),

      columnWidths: const [
        250,
        120,
      ],
    );
  }

  // ============================================================
  // GENERIC TABLE
  // ============================================================

  Widget _buildTableSection({
    required String title,
    required List<String> columns,
    required List<List<String>> rows,
    required List<double> columnWidths,
  }) {
    final double totalWidth = columnWidths.fold(
      0,
          (sum, width) => sum + width,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        // --------------------------------------------------------
        // SECTION TITLE
        // --------------------------------------------------------

        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // --------------------------------------------------------
        // TABLE
        // --------------------------------------------------------

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius:
            BorderRadius.circular(8),
          ),

          child: SingleChildScrollView(
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
                    height: 52,

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.grey.shade100,

                      border: Border(
                        bottom: BorderSide(
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
                            columnWidths[i],

                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 10,
                              ),

                              child: Align(
                                alignment:
                                Alignment.centerLeft,

                                child: Text(
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
                  // DATA ROWS
                  // ==================================================

                  if (rows.isEmpty)
                    const SizedBox(
                      height: 100,

                      child: Center(
                        child: Text(
                          'No data',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...rows.map(
                          (row) {
                        return Container(
                          height: 48,

                          decoration:
                          BoxDecoration(
                            border: Border(
                              bottom:
                              BorderSide(
                                color:
                                Colors.grey.shade300,
                              ),
                            ),
                          ),

                          child: Row(
                            children: [
                              for (
                              int i = 0;
                              i < row.length;
                              i++
                              )
                                SizedBox(
                                  width:
                                  columnWidths[i],

                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 10,
                                    ),

                                    child: Text(
                                      row[i],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}