import 'package:flutter/material.dart';

class DailyMovementScreen extends StatefulWidget {
  const DailyMovementScreen({super.key});

  @override
  State<DailyMovementScreen> createState() =>
      _DailyMovementScreenState();
}

class _DailyMovementScreenState
    extends State<DailyMovementScreen> {
  // ============================================================
  // DATE
  // ============================================================

  DateTime selectedDate = DateTime(2026, 9, 19);

  // ============================================================
  // DISPLAY VALUES
  //
  // Database/business calculations will be connected later.
  // For now they intentionally remain zero, matching the
  // Windows screen shown.
  // ============================================================

  final String totalTodayReceipts = '0';
  final String totalNurseryIncome = '0';
  final String totalIndoorIncome = '0';
  final String totalOtherIncome = '0';

  final String totalNurseryExpenses = '0';
  final String totalIndoorExpenses = '0';
  final String totalOtherExpenses = '0';
  final String oxygenPayments = '0';
  final String sterilizationPayments = '0';
  final String maintenancePayments = '0';
  final String nurseryDiscounts = '0';
  final String indoorDiscounts = '0';
  final String advances = '0';

  final String incomeTotal = '0';
  final String expenseTotal = '0';
  final String dailyNet = '0';

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day-$month-$year';
  }

  // ============================================================
  // PREVIOUS DAY
  // ============================================================

  void _previousDay() {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day - 1,
      );
    });
  }

  // ============================================================
  // TODAY
  // ============================================================

  void _today() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedDate = result;
    });
  }

  // ============================================================
  // SEARCH BY DATE
  //
  // At this stage it only selects the date.
  // Database loading will be connected later.
  // ============================================================

  void _searchByDate() {
    setState(() {});
  }

  // ============================================================
  // DETAILS BUTTON
  //
  // Placeholder only for now.
  // We will connect each detail operation after the screen
  // structure has been confirmed.
  // ============================================================

  void _showDetails(String title) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Details'),
          content: Text(
            'Details for:\n$title\n\n'
                'Database details will be connected later.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Movement',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // DATE CONTROLS
              // ==================================================

              _buildDateSection(),

              const SizedBox(height: 14),

              // ==================================================
              // CASH INCOME
              // ==================================================

              _buildIncomeSection(),

              const SizedBox(height: 14),

              // ==================================================
              // CASH EXPENSES
              // ==================================================

              _buildExpenseSection(),

              const SizedBox(height: 14),

              // ==================================================
              // OXYGEN PIPE INCOME
              // ==================================================

              _buildEmptySection(
                title: 'Oxygen Pipe Income',
              ),

              const SizedBox(height: 14),

              // ==================================================
              // STERILIZATION INCOME
              // ==================================================

              _buildEmptySection(
                title: 'Sterilization Income',
              ),

              const SizedBox(height: 14),

              // ==================================================
              // MAINTENANCE
              // ==================================================

              _buildEmptySection(
                title: 'Maintenance',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE SECTION
  // ============================================================

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          // ------------------------------------------
          // PREVIOUS DAY / TODAY
          // ------------------------------------------

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousDay,
                  child: const Text(
                    'Previous Day',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: _today,
                  child: const Text(
                    'Today',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------
          // DATE
          // ------------------------------------------

          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration:
              const InputDecoration(
                labelText: 'Search By Date',
                border:
                OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.calendar_today,
                ),
              ),
              child: Text(
                _formatDate(selectedDate),
                textAlign:
                TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ------------------------------------------
          // SEARCH
          // ------------------------------------------

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _searchByDate,
              icon: const Icon(
                Icons.search,
              ),
              label: const Text(
                'Search',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INCOME SECTION
  // ============================================================

  Widget _buildIncomeSection() {
    return _buildSectionContainer(
      title: 'Cash Income',
      titleColor: Colors.blue,
      child: Column(
        children: [
          _buildMovementRow(
            title:
            'Total Today Receipts',
            value:
            totalTodayReceipts,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Total Income From Nursery',
            value:
            totalNurseryIncome,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Total Income From Indoor',
            value:
            totalIndoorIncome,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Total Other Income',
            value:
            totalOtherIncome,
            showDetails: true,
          ),

          const Divider(),

          _buildTotalRow(
            title: 'Total',
            value: incomeTotal,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPENSE SECTION
  // ============================================================

  Widget _buildExpenseSection() {
    return _buildSectionContainer(
      title: 'Cash Expenses',
      titleColor: Colors.blue,
      child: Column(
        children: [
          _buildMovementRow(
            title:
            'Total Expenses From Nursery',
            value:
            totalNurseryExpenses,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Total Expenses From Indoor',
            value:
            totalIndoorExpenses,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Total Other Expenses',
            value:
            totalOtherExpenses,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Payments For Oxygen Account',
            value:
            oxygenPayments,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Payments For Sterilization Account',
            value:
            sterilizationPayments,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Payments For Maintenance',
            value:
            maintenancePayments,
            showDetails: true,
          ),

          _buildMovementRow(
            title:
            'Discounts From Nursery',
            value:
            nurseryDiscounts,
            showDetails: false,
          ),

          _buildMovementRow(
            title:
            'Discounts From Indoor',
            value:
            indoorDiscounts,
            showDetails: false,
          ),

          _buildMovementRow(
            title: 'Advances',
            value: advances,
            showDetails: false,
          ),

          const Divider(),

          _buildTotalRow(
            title: 'Total',
            value: expenseTotal,
            color: Colors.red,
          ),

          const SizedBox(height: 8),

          _buildTotalRow(
            title: 'Daily Net',
            value: dailyNet,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

  Widget _buildEmptySection({
    required String title,
  }) {
    return _buildSectionContainer(
      title: title,
      titleColor: Colors.black87,
      child: const Padding(
        padding:
        EdgeInsets.symmetric(
          vertical: 28,
        ),
        child: Center(
          child: Text(
            'No Data',
            style: TextStyle(
              color: Colors.red,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _buildSectionContainer({
    required String title,
    required Color titleColor,
    required Widget child,
  }) {
    return Container(
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
          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              8,
            ),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const Divider(
            height: 1,
          ),

          Padding(
            padding:
            const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOVEMENT ROW
  // ============================================================

  Widget _buildMovementRow({
    required String title,
    required String value,
    required bool showDetails,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          if (showDetails)
            SizedBox(
              width: 82,
              child: OutlinedButton(
                onPressed: () {
                  _showDetails(title);
                },
                style:
                OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            const SizedBox(
              width: 82,
            ),

          const SizedBox(width: 10),

          SizedBox(
            width: 55,
            child: Text(
              value,
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              textAlign:
              TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL ROW
  // ============================================================

  Widget _buildTotalRow({
    required String title,
    required String value,
    required Color color,
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
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 20),

          SizedBox(
            width: 70,
            child: Text(
              value,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}