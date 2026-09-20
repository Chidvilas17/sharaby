import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/today_statements_api_service.dart';

class StatementsTodayAccountScreen
    extends StatefulWidget {
  const StatementsTodayAccountScreen({
    super.key,
  });

  @override
  State<StatementsTodayAccountScreen>
  createState() =>
      _StatementsTodayAccountScreenState();
}

class _StatementsTodayAccountScreenState
    extends State<StatementsTodayAccountScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  bool isLoading = false;

  List<Map<String, dynamic>> statements = [];

  final List<String> headers = [
    'م / No.',
    'الإسم / Name',
    'النوع / Type',
    'السعر / Price',
    'الوقت / Time',
    'الدكتور / Doctor',
  ];

  // =========================================================
  // INITIAL LOAD
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadStatements();
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // =========================================================
  // LOAD STATEMENTS
  // =========================================================

  Future<void> _loadStatements() async {
    setState(() {
      isLoading = true;
      selectedRow = null;
    });

    try {
      final result =
      await TodayStatementsApiService
          .getStatements(
        selectedDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        statements = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        statements = [];
        isLoading = false;
      });

      _showMessage(
        'Failed to load statements.\n$e',
      );
    }
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> _selectDate() async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;
    });

    await _loadStatements();
  }

  // =========================================================
  // TOTAL
  // =========================================================

  double _calculateTotalIncome() {
    double total = 0;

    for (final item in statements) {
      total +=
          double.tryParse(
            item['price']?.toString() ??
                item['Price']?.toString() ??
                '0',
          ) ??
              0;
    }

    return total;
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    final displayCount =
    statements.length < 10
        ? 10
        : statements.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(140),

        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),

        children: [
          // ===================================================
          // HEADER
          // ===================================================

          TableRow(
            decoration:
            const BoxDecoration(
              color: Color(0xFF4D88B5),
            ),

            children:
            headers.map((header) {
              return Container(
                height: 48,
                alignment:
                Alignment.center,

                padding:
                const EdgeInsets.all(6),

                child: Text(
                  header,
                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),

          // ===================================================
          // ROWS
          // ===================================================

          for (
          int index = 0;
          index < displayCount;
          index++
          )
            TableRow(
              children: [
                _dataCell(
                  index,
                  index <
                      statements.length
                      ? '${index + 1}'
                      : '',
                ),

                _dataCell(
                  index,
                  index <
                      statements.length
                      ? (
                      statements[index]
                      ['name'] ??
                          statements[index]
                          ['Name'] ??
                          ''
                  ).toString()
                      : '',
                ),

                _dataCell(
                  index,
                  index <
                      statements.length
                      ? (
                      statements[index]
                      ['type'] ??
                          statements[index]
                          ['Type'] ??
                          ''
                  ).toString()
                      : '',
                ),

                _dataCell(
                  index,
                  index <
                      statements.length
                      ? (
                      statements[index]
                      ['price'] ??
                          statements[index]
                          ['Price'] ??
                          ''
                  ).toString()
                      : '',
                ),

                _dataCell(
                  index,
                  index <
                      statements.length
                      ? (
                      statements[index]
                      ['time'] ??
                          statements[index]
                          ['Time'] ??
                          ''
                  ).toString()
                      : '',
                ),

                _dataCell(
                  index,
                  index <
                      statements.length
                      ? (
                      statements[index]
                      ['doctor'] ??
                          statements[index]
                          ['Doctor'] ??
                          ''
                  ).toString()
                      : '',
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================================================
  // DATA CELL
  // =========================================================

  Widget _dataCell(
      int index,
      String text,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = index;
        });
      },

      child: Container(
        height: 42,

        alignment:
        Alignment.center,

        color:
        selectedRow == index
            ? Colors.blue
            .withValues(alpha: 0.2)
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final totalIncome =
    _calculateTotalIncome();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr("Today's Total Statements / بيانات الكشف اليومية")),
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

            children: [
              // ===============================================
              // DATE
              // ===============================================

              Text(AppTranslations.tr('التاريخ / Date'),
                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              SizedBox(
                height: 8,
              ),

              InkWell(
                onTap:
                isLoading
                    ? null
                    : _selectDate,

                child: InputDecorator(
                  decoration:
                  InputDecoration(
                    border:
                    OutlineInputBorder(),
                    suffixIcon:
                    Icon(
                      Icons
                          .calendar_month,
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

              SizedBox(
                height: 12,
              ),

              // ===============================================
              // SEARCH
              // ===============================================

              SizedBox(
                height: 48,

                child:
                ElevatedButton.icon(
                  onPressed:
                  isLoading
                      ? null
                      : _loadStatements,

                  icon: const Icon(
                    Icons.search,
                  ),

                  label:
                  Text(AppTranslations.tr('Search / بحث'),

                    style:
                    TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // ===============================================
              // DATA
              // ===============================================

              Container(
                padding:
                const EdgeInsets.all(8),

                decoration:
                BoxDecoration(
                  border:
                  Border.all(
                    color: Colors.grey,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

                  children: [
                    Text(AppTranslations.tr('بيانات الكشف / Statement Data'),

                      textAlign:
                      TextAlign.right,

                      style:
                      TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    if (isLoading)
                      Padding(
                        padding:
                        EdgeInsets.all(
                          20,
                        ),

                        child:
                        Center(
                          child:
                          CircularProgressIndicator(),
                        ),
                      ),

                    _buildTable(),
                  ],
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // ===============================================
              // TOTAL
              // ===============================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [
                  Text(AppTranslations.tr('إجمالي الواردات / Total Income: '),

                    style:
                    TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    width: 12,
                  ),

                  Text(
                    totalIncome
                        .toStringAsFixed(0),

                    style:
                    const TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}