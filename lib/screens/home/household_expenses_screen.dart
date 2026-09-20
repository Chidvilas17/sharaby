import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/household_expenses_api_service.dart';

class HouseholdExpensesScreen extends StatefulWidget {
  const HouseholdExpensesScreen({super.key});

  @override
  State<HouseholdExpensesScreen> createState() =>
      _HouseholdExpensesScreenState();
}

class _HouseholdExpensesScreenState
    extends State<HouseholdExpensesScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController receiptNumberController =
  TextEditingController();

  final TextEditingController costController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  // ============================================================
  // DATE
  // ============================================================

  DateTime selectedDate = DateTime.now();

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> expenses = [];

  int? selectedExpenseId;
  int? selectedRow;

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool loadingExpenses = false;
  bool saving = false;
  bool deleting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load expenses for today's date when the screen opens.
    _search();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    receiptNumberController.dispose();
    costController.dispose();
    notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(value.toString());

      final hour = dateTime.hour == 0
          ? 12
          : dateTime.hour > 12
          ? dateTime.hour - 12
          : dateTime.hour;

      final minute =
      dateTime.minute.toString().padLeft(2, '0');

      final period =
      dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedRow = null;
        selectedExpenseId = null;
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loadingExpenses = true;
      selectedRow = null;
      selectedExpenseId = null;
    });

    try {
      final result =
      await HouseholdExpensesApiService.getExpensesByDate(
        selectedDate,
      );

      if (!mounted) return;

      setState(() {
        expenses = result;
        loadingExpenses = false;
      });

      if (expenses.isEmpty) {
        _showMessage(
          'No operations this day.',
        );
      } else {
        _showMessage(
          '${expenses.length} expense(s) found.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        expenses = [];
        loadingExpenses = false;
      });

      _showMessage(
        'Failed to load expenses.\n$e',
      );
    }
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  Future<void> _saveExpense() async {
    final receiptNumber =
    receiptNumberController.text.trim();

    final costText =
    costController.text.trim();

    final notes =
    notesController.text.trim();

    // ------------------------------------------------------------
    // VALIDATE RECEIPT NUMBER
    // ------------------------------------------------------------

    if (receiptNumber.isEmpty) {
      _showMessage(
        'Please enter the receipt number.',
      );
      return;
    }

    final parsedReceiptNumber =
    int.tryParse(receiptNumber);

    if (parsedReceiptNumber == null) {
      _showMessage(
        'Please enter a valid receipt number.',
      );
      return;
    }

    // ------------------------------------------------------------
    // VALIDATE COST
    // ------------------------------------------------------------

    if (costText.isEmpty) {
      _showMessage(
        'Please enter the cost.',
      );
      return;
    }

    final parsedCost =
    int.tryParse(costText);

    if (parsedCost == null) {
      _showMessage(
        'Please enter a valid whole number cost.',
      );
      return;
    }

    // ------------------------------------------------------------
    // SAVE
    // ------------------------------------------------------------

    setState(() {
      saving = true;
    });

    try {
      await HouseholdExpensesApiService.addExpense(
        waslNo: parsedReceiptNumber,
        cost: parsedCost,
        notes: notes.isEmpty ? null : notes,
        date: selectedDate,
        userId: null,
      );

      if (!mounted) return;

      // Clear input fields.
      receiptNumberController.clear();
      costController.clear();
      notesController.clear();

      setState(() {
        saving = false;
        selectedRow = null;
        selectedExpenseId = null;
      });

      _showMessage(
        'Expense saved successfully.',
      );

      // Reload from SQL Server.
      await _loadExpensesWithoutMessage();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _showMessage(
        'Failed to save expense.\n$e',
      );
    }
  }

  // ============================================================
  // LOAD EXPENSES WITHOUT SHOWING MESSAGE
  // ============================================================

  Future<void> _loadExpensesWithoutMessage() async {
    try {
      final result =
      await HouseholdExpensesApiService.getExpensesByDate(
        selectedDate,
      );

      if (!mounted) return;

      setState(() {
        expenses = result;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to refresh expenses.\n$e',
      );
    }
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> _deleteExpense() async {
    if (selectedExpenseId == null) {
      _showMessage(
        'Please select an expense first.',
      );
      return;
    }

    setState(() {
      deleting = true;
    });

    try {
      await HouseholdExpensesApiService.deleteExpense(
        selectedExpenseId!,
      );

      if (!mounted) return;

      setState(() {
        deleting = false;
        selectedRow = null;
        selectedExpenseId = null;
      });

      _showMessage(
        'Expense deleted successfully.',
      );

      // Reload from SQL Server.
      await _loadExpensesWithoutMessage();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deleting = false;
      });

      _showMessage(
        'Failed to delete expense.\n$e',
      );
    }
  }

  // ============================================================
  // SELECT TABLE ROW
  // ============================================================

  void _selectExpenseRow(int index) {
    if (index >= expenses.length) {
      return;
    }

    final expense = expenses[index];

    final id = expense['id'];

    if (id == null) {
      return;
    }

    setState(() {
      selectedRow = index;
      selectedExpenseId =
          int.tryParse(id.toString());
    });
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Text(
        AppTranslations.tr(title),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatDate(selectedDate),
                style: const TextStyle(
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
    );
  }

  // ============================================================
  // HEADER CELL
  // ============================================================

  Widget _headerCell(
      String text,
      double width,
      ) {
    return SizedBox(
      width: width,
      height: 52,
      child: Center(
        child: Text(
          AppTranslations.tr(text),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATA CELL
  // ============================================================

  Widget _dataCell(
      int row,
      String text,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        _selectExpenseRow(row);
      },
      child: Container(
        width: width,
        height: 42,
        color: selectedRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        child: Text(
          AppTranslations.tr(text),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // EXPENSE TABLE
  // ============================================================

  Widget _buildTable() {
    const int emptyRows = 12;

    const double noWidth = 60;
    const double typeWidth = 150;
    const double receiptWidth = 130;
    const double costWidth = 100;
    const double notesWidth = 180;
    const double timeWidth = 120;
    const double accountantWidth = 130;

    final int numberOfRows =
    expenses.isEmpty
        ? emptyRows
        : expenses.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          width: 1,
        ),
        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(noWidth),
          1: FixedColumnWidth(typeWidth),
          2: FixedColumnWidth(receiptWidth),
          3: FixedColumnWidth(costWidth),
          4: FixedColumnWidth(notesWidth),
          5: FixedColumnWidth(timeWidth),
          6: FixedColumnWidth(accountantWidth),
        },
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              _headerCell(
                'No.',
                noWidth,
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
                'Cost',
                costWidth,
              ),
              _headerCell(
                'Notes',
                notesWidth,
              ),
              _headerCell(
                'Time',
                timeWidth,
              ),
              _headerCell(
                'Accountant',
                accountantWidth,
              ),
            ],
          ),

          // ------------------------------------------------------
          // DATA ROWS
          // ------------------------------------------------------

          ...List.generate(
            numberOfRows,
                (index) {
              final hasData =
                  index < expenses.length;

              final expense =
              hasData
                  ? expenses[index]
                  : null;

              final type =
                  expense?['type']
                      ?.toString() ??
                      '';

              final receiptNumber =
                  expense?['wasl_no']
                      ?.toString() ??
                      '';

              final cost =
                  expense?['cost']
                      ?.toString() ??
                      '';

              final notes =
                  expense?['notes']
                      ?.toString() ??
                      '';

              final time =
              _formatTime(
                expense?['Time'],
              );

              final accountant =
                  expense?['log_id']
                      ?.toString() ??
                      '';

              return TableRow(
                children: [
                  _dataCell(
                    index,
                    hasData
                        ? '${index + 1}'
                        : '',
                    noWidth,
                  ),

                  _dataCell(
                    index,
                    type,
                    typeWidth,
                  ),

                  _dataCell(
                    index,
                    receiptNumber,
                    receiptWidth,
                  ),

                  _dataCell(
                    index,
                    cost,
                    costWidth,
                  ),

                  _dataCell(
                    index,
                    notes,
                    notesWidth,
                  ),

                  _dataCell(
                    index,
                    time,
                    timeWidth,
                  ),

                  _dataCell(
                    index,
                    accountant,
                    accountantWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double _calculateTotal() {
    double total = 0;

    for (final expense in expenses) {
      final value = expense['cost'];

      if (value == null) {
        continue;
      }

      total +=
          double.tryParse(
            value.toString(),
          ) ??
              0;
    }

    return total;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Household Expenses'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // CURRENT USER
              // ==================================================

              Row(
                children: [
                  Text(AppTranslations.tr('Current User: '),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('1234567'),
                ],
              ),

              SizedBox(height: 20),

              // ==================================================
              // SEARCH BY DATE
              // ==================================================

              _sectionTitle(
                'Search by Date',
              ),

              SizedBox(height: 14),

              _dateField(),

              SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  loadingExpenses
                      ? null
                      : _search,
                  child: loadingExpenses
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(AppTranslations.tr('Search'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              if (!loadingExpenses &&
                  expenses.isEmpty)
                Center(
                  child: Text(AppTranslations.tr('No operations this day'),
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

              SizedBox(height: 24),

              // ==================================================
              // ADD EXPENSE
              // ==================================================

              _sectionTitle(
                'Add Expense',
              ),

              SizedBox(height: 16),

              _textField(
                controller:
                receiptNumberController,
                label: 'Receipt Number',
                keyboardType:
                TextInputType.number,
              ),

              SizedBox(height: 14),

              _textField(
                controller: costController,
                label: 'Cost',
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: false,
                ),
              ),

              SizedBox(height: 14),

              _textField(
                controller: notesController,
                label: 'Notes',
              ),

              SizedBox(height: 14),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  saving
                      ? null
                      : _saveExpense,
                  child: saving
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(AppTranslations.tr('Save'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // ==================================================
              // EXPENSE DATA
              // ==================================================

              _sectionTitle(
                'Expense Data',
              ),

              if (loadingExpenses)
                Padding(
                  padding:
                  EdgeInsets.all(20),
                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                )
              else
                _buildTable(),

              SizedBox(height: 16),

              // ==================================================
              // DELETE
              // ==================================================

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  deleting
                      ? null
                      : _deleteExpense,
                  child: deleting
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(AppTranslations.tr('Delete'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // ==================================================
              // TOTAL
              // ==================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.tr('Total Expenses: '),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal()
                        .toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
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