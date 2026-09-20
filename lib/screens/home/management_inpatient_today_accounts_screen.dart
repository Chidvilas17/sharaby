import 'package:flutter/material.dart';
import '../../services/internal_accounts_api_service.dart';

class ManagementInpatientTodayAccountsScreen
    extends StatefulWidget {
  const ManagementInpatientTodayAccountsScreen({
    super.key,
  });

  @override
  State<ManagementInpatientTodayAccountsScreen>
  createState() =>
      _ManagementInpatientTodayAccountsScreenState();
}

class _ManagementInpatientTodayAccountsScreenState
    extends State<ManagementInpatientTodayAccountsScreen> {
  // =========================================================
  // DATE
  // =========================================================

  DateTime selectedDate = DateTime.now();

  // =========================================================
  // DATA
  // =========================================================

  List<Map<String, dynamic>> incomeData = [];

  List<Map<String, dynamic>> expenseData = [];

  // =========================================================
  // SELECTION
  // =========================================================

  int? selectedIncomeRow;

  int? selectedExpenseRow;

  // =========================================================
  // LOADING
  // =========================================================

  bool loading = false;

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day-$month-$year';
  }

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _search();
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Future<void> _search() async {
    setState(() {
      loading = true;
      selectedIncomeRow = null;
      selectedExpenseRow = null;
    });

    try {
      final result =
      await InternalAccountsApiService
          .getAccounts(selectedDate);

      if (!mounted) {
        return;
      }

      final income =
      result['income'];

      final expenses =
      result['expenses'];

      setState(() {
        incomeData =
        income is List
            ? income
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList()
            : [];

        expenseData =
        expenses is List
            ? expenses
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(
            item,
          ),
        )
            .toList()
            : [];

        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        incomeData = [];
        expenseData = [];
      });

      _showMessage(
        'Failed to load accounts.\n$e',
      );
    }
  }

  // =========================================================
  // TOTAL
  // =========================================================

  double _total(
      List<Map<String, dynamic>> data,
      ) {
    double total = 0;

    for (final row in data) {
      final value = row['amount'];

      if (value is num) {
        total += value.toDouble();
      } else {
        total +=
            double.tryParse(
              value?.toString() ?? '',
            ) ??
                0;
      }
    }

    return total;
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _headerCell(
      String text,
      double width,
      ) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // =========================================================
  // DATA CELL
  // =========================================================

  Widget _dataCell(
      int row,
      String text,
      double width,
      bool isIncome,
      ) {
    final isSelected = isIncome
        ? selectedIncomeRow == row
        : selectedExpenseRow == row;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isIncome) {
            selectedIncomeRow = row;
          } else {
            selectedExpenseRow = row;
          }
        });
      },
      child: Container(
        width: width,
        height: 36,
        alignment: Alignment.center,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        color: isSelected
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // =========================================================
  // VALUE
  // =========================================================

  String _value(
      Map<String, dynamic> row,
      String key,
      ) {
    final value = row[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable({
    required bool isIncome,
  }) {
    const int emptyRows = 15;

    const double caseNameWidth = 180;

    const double typeWidth = 130;

    const double receiptWidth = 140;

    const double amountWidth = 110;

    const double accountantWidth = 130;

    const double notesWidth = 160;

    final data =
    isIncome
        ? incomeData
        : expenseData;

    final rowCount =
    data.isEmpty
        ? emptyRows
        : data.length;

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,

      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          width: 1,
        ),

        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,

        columnWidths: const {
          0: FixedColumnWidth(
            caseNameWidth,
          ),
          1: FixedColumnWidth(
            typeWidth,
          ),
          2: FixedColumnWidth(
            receiptWidth,
          ),
          3: FixedColumnWidth(
            amountWidth,
          ),
          4: FixedColumnWidth(
            accountantWidth,
          ),
          5: FixedColumnWidth(
            notesWidth,
          ),
        },

        children: [
          // ===================================================
          // HEADER
          // ===================================================

          TableRow(
            children: [
              _headerCell(
                'Case Name',
                caseNameWidth,
              ),

              _headerCell(
                'Type',
                typeWidth,
              ),

              _headerCell(
                'Receipt Number',
                receiptWidth,
              ),

              _headerCell(
                'Amount',
                amountWidth,
              ),

              _headerCell(
                'Accountant',
                accountantWidth,
              ),

              _headerCell(
                'Notes',
                notesWidth,
              ),
            ],
          ),

          // ===================================================
          // ROWS
          // ===================================================

          for (
          int row = 0;
          row < rowCount;
          row++
          )
            TableRow(
              children: [
                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'caseName',
                  )
                      : '',
                  caseNameWidth,
                  isIncome,
                ),

                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'type',
                  )
                      : '',
                  typeWidth,
                  isIncome,
                ),

                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'receiptNumber',
                  )
                      : '',
                  receiptWidth,
                  isIncome,
                ),

                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'amount',
                  )
                      : '',
                  amountWidth,
                  isIncome,
                ),

                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'accountant',
                  )
                      : '',
                  accountantWidth,
                  isIncome,
                ),

                _dataCell(
                  row,
                  row < data.length
                      ? _value(
                    data[row],
                    'notes',
                  )
                      : '',
                  notesWidth,
                  isIncome,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================================================
  // DELETE INCOME
  // =========================================================

  Future<void> _deleteIncome() async {
    if (selectedIncomeRow == null) {
      _showMessage(
        'Please select an income row first.',
      );
      return;
    }

    final index =
    selectedIncomeRow!;

    if (index >= incomeData.length) {
      return;
    }

    final id =
    incomeData[index]['id'];

    if (id == null) {
      _showMessage(
        'Invalid income record.',
      );
      return;
    }

    final confirmed =
    await _confirmDelete();

    if (!confirmed) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await InternalAccountsApiService
          .deleteIncome(
        int.parse(id.toString()),
      );

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

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to delete income.\n$e',
      );
    }
  }

  // =========================================================
  // DELETE EXPENSE
  // =========================================================

  Future<void> _deleteExpense() async {
    if (selectedExpenseRow == null) {
      _showMessage(
        'Please select an expense row first.',
      );
      return;
    }

    final index =
    selectedExpenseRow!;

    if (index >= expenseData.length) {
      return;
    }

    final id =
    expenseData[index]['id'];

    if (id == null) {
      _showMessage(
        'Invalid expense record.',
      );
      return;
    }

    final confirmed =
    await _confirmDelete();

    if (!confirmed) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await InternalAccountsApiService
          .deleteExpense(
        int.parse(id.toString()),
      );

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

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to delete expense.\n$e',
      );
    }
  }

  // =========================================================
  // CONFIRM DELETE
  // =========================================================

  Future<bool> _confirmDelete() async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
          ),
          content: const Text(
            'Are you sure you want to delete '
                'this record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // =========================================================
  // ACCOUNT SECTION
  // =========================================================

  Widget _accountSection({
    required String title,
    required bool isIncome,
  }) {
    final data =
    isIncome
        ? incomeData
        : expenseData;

    final total =
    _total(data);

    return Container(
      padding:
      const EdgeInsets.all(12),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [
          _sectionTitle(title),

          _buildTable(
            isIncome: isIncome,
          ),

          const SizedBox(
            height: 12,
          ),

          Align(
            alignment:
            Alignment.center,

            child: SizedBox(
              width: 110,
              height: 42,

              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : isIncome
                    ? _deleteIncome
                    : _deleteExpense,

                child: const Text(
                  'Delete',
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            isIncome
                ? 'Total Income: ${total.toStringAsFixed(2)}'
                : 'Total Expenses: ${total.toStringAsFixed(2)}',

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Text(
        title,

        textAlign:
        TextAlign.center,

        style: const TextStyle(
          fontSize: 18,
          fontWeight:
          FontWeight.bold,
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
    final incomeTotal =
    _total(incomeData);

    final expenseTotal =
    _total(expenseData);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Inpatient Accounts',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              // =================================================
              // SEARCH BY DATE
              // =================================================

              const Text(
                'Search by Date',

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              InkWell(
                onTap:
                loading
                    ? null
                    : _selectDate,

                child: Container(
                  height: 52,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  decoration:
                  BoxDecoration(
                    border: Border.all(
                      color:
                      Colors.grey.shade500,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      4,
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          _formatDate(
                            selectedDate,
                          ),

                          style:
                          const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // SEARCH BUTTON
              // =================================================

              SizedBox(
                height: 46,

                child:
                ElevatedButton(
                  onPressed:
                  loading
                      ? null
                      : _search,

                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Search',
                    style:
                    TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // =================================================
              // NO OPERATIONS MESSAGE
              // =================================================

              if (!loading &&
                  incomeData.isEmpty &&
                  expenseData.isEmpty)
                const Text(
                  'No operations for this day',

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),

              // =================================================
              // INCOME
              // =================================================

              _accountSection(
                title:
                'Inpatient Income',

                isIncome: true,
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // EXPENSES
              // =================================================

              _accountSection(
                title:
                'Inpatient Expenses',

                isIncome: false,
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // SUMMARY
              // =================================================

              Container(
                padding:
                const EdgeInsets.all(14),

                decoration:
                BoxDecoration(
                  border: Border.all(
                    color:
                    Colors.grey.shade400,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    4,
                  ),
                ),

                child: Column(
                  children: [
                    Text(
                      'Total Income: '
                          '${incomeTotal.toStringAsFixed(2)}',

                      style:
                      const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Total Expenses: '
                          '${expenseTotal.toStringAsFixed(2)}',

                      style:
                      const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Net Total: '
                          '${(incomeTotal - expenseTotal).toStringAsFixed(2)}',

                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}