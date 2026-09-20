import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/nursery_daily_accounts_api_service.dart';

class NurseryTodayAccountsScreen extends StatefulWidget {
  const NurseryTodayAccountsScreen({super.key});

  @override
  State<NurseryTodayAccountsScreen> createState() =>
      _NurseryTodayAccountsScreenState();
}

class _NurseryTodayAccountsScreenState
    extends State<NurseryTodayAccountsScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedIncomeRow;
  int? selectedExpenseRow;

  bool loading = false;
  bool deletingIncome = false;
  bool deletingExpense = false;

  List<Map<String, dynamic>> incomeRecords = [];
  List<Map<String, dynamic>> expenseRecords = [];

  final List<String> headers = [
    'Case Name',
    'Type',
    'Receipt Number',
    'Amount',
    'Accountant',
    'Notes',
  ];

  @override
  void initState() {
    super.initState();

    _search();
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedIncomeRow = null;
        selectedExpenseRow = null;
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
      selectedIncomeRow = null;
      selectedExpenseRow = null;
    });

    try {
      final result =
      await NurseryDailyAccountsApiService
          .getDailyAccounts(
        selectedDate,
      );

      final income =
      result['income'];

      final expenses =
      result['expenses'];

      if (!mounted) {
        return;
      }

      setState(() {
        incomeRecords = income is List
            ? income
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList()
            : [];

        expenseRecords = expenses is List
            ? expenses
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList()
            : [];
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to load accounts: $e',
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // DELETE INCOME
  // ============================================================

  Future<void> _deleteIncome() async {
    if (selectedIncomeRow == null) {
      _showMessage(
        'Please select an income row first.',
      );
      return;
    }

    final index =
    selectedIncomeRow!;

    if (index < 0 ||
        index >= incomeRecords.length) {
      _showMessage(
        'Invalid income selection.',
      );
      return;
    }

    final record =
    incomeRecords[index];

    final id =
    record['id'];

    if (id == null) {
      _showMessage(
        'Income record ID was not found.',
      );
      return;
    }

    setState(() {
      deletingIncome = true;
    });

    try {
      await NurseryDailyAccountsApiService
          .deleteIncome(
        int.parse(
          id.toString(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        selectedIncomeRow = null;
      });

      await _search();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Income deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to delete income: $e',
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        deletingIncome = false;
      });
    }
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> _deleteExpense() async {
    if (selectedExpenseRow == null) {
      _showMessage(
        'Please select an expense row first.',
      );
      return;
    }

    final index =
    selectedExpenseRow!;

    if (index < 0 ||
        index >= expenseRecords.length) {
      _showMessage(
        'Invalid expense selection.',
      );
      return;
    }

    final record =
    expenseRecords[index];

    final id =
    record['id'];

    if (id == null) {
      _showMessage(
        'Expense record ID was not found.',
      );
      return;
    }

    setState(() {
      deletingExpense = true;
    });

    try {
      await NurseryDailyAccountsApiService
          .deleteExpense(
        int.parse(
          id.toString(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        selectedExpenseRow = null;
      });

      await _search();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Expense deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to delete expense: $e',
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        deletingExpense = false;
      });
    }
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double _calculateTotal(
      List<Map<String, dynamic>> records,
      ) {
    double total = 0;

    for (final record in records) {
      final amount =
          double.tryParse(
            record['amount']?.toString() ?? '',
          ) ??
              0;

      total += amount;
    }

    return total;
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable({
    required bool income,
  }) {
    final records =
    income
        ? incomeRecords
        : expenseRecords;

    final selectedRow =
    income
        ? selectedIncomeRow
        : selectedExpenseRow;

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(125),
        border:
        TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          // ======================================================
          // HEADER
          // ======================================================

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
                    6,
                  ),
                  child: Text(
                    header,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          // ======================================================
          // 15 ROWS
          // ======================================================

          ...List.generate(
            15,
                (index) {
              final hasData =
                  index < records.length;

              final record =
              hasData
                  ? records[index]
                  : null;

              String getValue(
                  String header,
                  ) {
                if (record == null) {
                  return '';
                }

                switch (header) {
                  case 'Case Name':
                    return record[
                    'patientName']
                        ?.toString() ??
                        '';

                  case 'Type':
                    return record[
                    'type']
                        ?.toString() ??
                        '';

                  case 'Receipt Number':
                    return record[
                    'receiptNumber']
                        ?.toString() ??
                        '';

                  case 'Amount':
                    return record[
                    'amount']
                        ?.toString() ??
                        '';

                  case 'Accountant':
                    return record[
                    'accountant']
                        ?.toString() ??
                        '';

                  case 'Notes':
                    return record[
                    'notes']
                        ?.toString() ??
                        '';

                  default:
                    return '';
                }
              }

              return TableRow(
                children:
                headers.map(
                      (header) {
                    return GestureDetector(
                      onTap: hasData
                          ? () {
                        setState(() {
                          if (income) {
                            selectedIncomeRow =
                                index;
                          } else {
                            selectedExpenseRow =
                                index;
                          }
                        });
                      }
                          : null,
                      child:
                      Container(
                        height: 42,
                        alignment:
                        Alignment.center,
                        padding:
                        const EdgeInsets.all(
                          4,
                        ),
                        color:
                        selectedRow ==
                            index
                            ? Colors
                            .blue
                            .withValues(
                          alpha: 0.12,
                        )
                            : Colors
                            .transparent,
                        child: Text(
                          getValue(
                            header,
                          ),
                          textAlign:
                          TextAlign.center,
                          style:
                          const TextStyle(
                            fontSize: 12,
                          ),
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
    );
  }

  // ============================================================
  // ACCOUNT SECTION
  // ============================================================

  Widget _buildAccountSection({
    required String title,
    required bool income,
    required VoidCallback onDelete,
  }) {
    final records =
    income
        ? incomeRecords
        : expenseRecords;

    final total =
    _calculateTotal(
      records,
    );

    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration:
      BoxDecoration(
        border:
        Border.all(
          color: Colors.grey,
        ),
        borderRadius:
        BorderRadius.circular(
          4,
        ),
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
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 8,
          ),

          Text(
            records.isEmpty
                ? 'No operations This day'
                : '${records.length} operation(s)',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              color:
              records.isEmpty
                  ? Colors.red
                  : Colors.green,
              fontSize: 16,
            ),
          ),

          SizedBox(
            height: 8,
          ),

          _buildTable(
            income: income,
          ),

          SizedBox(
            height: 10,
          ),

          Align(
            alignment:
            Alignment.center,
            child:
            ElevatedButton(
              onPressed:
              income
                  ? (deletingIncome
                  ? null
                  : onDelete)
                  : (deletingExpense
                  ? null
                  : onDelete),
              child:
              Text(
                income
                    ? (deletingIncome
                    ? 'Deleting...'
                    : 'Delete')
                    : (deletingExpense
                    ? 'Deleting...'
                    : 'Delete'),
              ),
            ),
          ),

          SizedBox(
            height: 8,
          ),

          Text(
            income
                ? 'Total Income: ${total.toStringAsFixed(0)}'
                : 'Total Expenses: ${total.toStringAsFixed(0)}',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(AppTranslations.tr("Today's Account"),
        ),
      ),
      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          12,
        ),
        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            Text(AppTranslations.tr('Search by Date'),
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 12,
            ),

            InkWell(
              onTap:
              _selectDate,
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
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            ElevatedButton.icon(
              onPressed:
              loading
                  ? null
                  : _search,
              icon:
              loading
                  ? SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                ),
              )
                  : const Icon(
                Icons.search,
              ),
              label:
              Text(
                loading
                    ? 'Loading...'
                    : 'Search',
              ),
            ),

            SizedBox(
              height: 24,
            ),

            // ====================================================
            // INCOME
            // ====================================================

            _buildAccountSection(
              title:
              'Nursery Income',
              income: true,
              onDelete:
              _deleteIncome,
            ),

            SizedBox(
              height: 30,
            ),

            // ====================================================
            // EXPENSES
            // ====================================================

            _buildAccountSection(
              title:
              'Nursery Expenses',
              income: false,
              onDelete:
              _deleteExpense,
            ),
          ],
        ),
      ),
    );
  }
}