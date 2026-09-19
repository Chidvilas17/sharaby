import 'package:flutter/material.dart';

import '../../services/daily_movement_api_service.dart';
import 'faults_screen.dart';
import 'internal_daily_accounts_screen.dart';
import 'nursery_daily_accounts_screen.dart';
import 'other_expenses_screen.dart';
import 'other_income_screen.dart';
import 'oxygen_calculation_screen.dart';
import 'statements_today_account_screen.dart';
import 'sterilization_material_accounts_screen.dart';

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

  DateTime selectedDate = DateTime.now();

  // ============================================================
  // DATA
  // ============================================================

  Map<String, dynamic> data = {};

  bool isLoading = true;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadDailyMovement();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadDailyMovement() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
      await DailyMovementApiService
          .getDailyMovement(
        date: selectedDate,
      );

      if (!mounted) return;

      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // TODAY
  // ============================================================

  Future<void> _today() async {
    setState(() {
      selectedDate = DateTime.now();
    });

    await _loadDailyMovement();
  }

  // ============================================================
  // PREVIOUS DAY
  // ============================================================

  Future<void> _previousDay() async {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day - 1,
      );
    });

    await _loadDailyMovement();
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
  // SEARCH
  // ============================================================

  Future<void> _searchByDate() async {
    await _loadDailyMovement();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // NUMBER
  // ============================================================

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '0';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    return value.toString();
  }

  // ============================================================
  // PLACEHOLDER DETAILS (SCREENS 1 & 2)
  // ============================================================

  void _showPlaceholderDetails(String title) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            '$title\n\n'
            'Reserved navigation slot.\n'
            'Awaiting exact Windows application screenshot before implementing.',
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Movement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDailyMovement,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // DATE CONTROLS
                // ==================================================

                _buildDateSection(),

                const SizedBox(height: 14),

                if (isLoading)
                  const Padding(
                    padding:
                    EdgeInsets.all(40),
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  _buildError()
                else ...[
                    // ================================================
                    // RESERVED PLACEHOLDERS (SCREENS 1 & 2)
                    // ================================================

                    _buildPlaceholderSection(),

                    const SizedBox(height: 14),

                    // ================================================
                    // INCOME
                    // ================================================

                    _buildIncomeSection(),

                    const SizedBox(height: 14),

                    // ================================================
                    // EXPENSES
                    // ================================================

                    _buildExpenseSection(),

                    const SizedBox(height: 14),

                    // ================================================
                    // OXYGEN
                    // ================================================

                    _buildEmptySection(
                      title:
                      'Oxygen Pipe Income',
                    ),

                    const SizedBox(height: 14),

                    // ================================================
                    // STERILIZATION
                    // ================================================

                    _buildEmptySection(
                      title:
                      'Sterilization Income',
                    ),

                    const SizedBox(height: 14),

                    // ================================================
                    // MAINTENANCE
                    // ================================================

                    _buildEmptySection(
                      title: 'Maintenance',
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PLACEHOLDER SECTION (NURSES & BOARDING)
  // ============================================================

  Widget _buildPlaceholderSection() {
    return _buildSectionContainer(
      title: 'Reserved Detail Slots',
      titleColor: Colors.deepPurple,
      child: Column(
        children: [
          _buildMovementRow(
            title: 'Total for Nurses',
            value: '0',
            showDetails: true,
            onDetailsPressed: () {
              _showPlaceholderDetails('Screen 1: Total for Nurses');
            },
          ),
          _buildMovementRow(
            title: 'Total for Boarding',
            value: '0',
            showDetails: true,
            onDetailsPressed: () {
              _showPlaceholderDetails('Screen 2: Total for Boarding');
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE SECTION
  // ============================================================

  Widget _buildDateSection() {
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  isLoading
                      ? null
                      : _previousDay,
                  child: const Text(
                    'Previous Day',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : _today,
                  child: const Text(
                    'Today',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: isLoading
                ? null
                : _selectDate,
            child: InputDecorator(
              decoration:
              const InputDecoration(
                labelText:
                'Search By Date',
                border:
                OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.calendar_today,
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

          const SizedBox(height: 10),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed:
              isLoading
                  ? null
                  : _searchByDate,
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
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade300,
        ),
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          const Text(
            'Failed to load Daily Movement.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            errorMessage ?? '',
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(height: 14),

          ElevatedButton(
            onPressed:
            _loadDailyMovement,
            child: const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INCOME
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
            _value(
              'todayReceipts',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatementsTodayAccountScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Total Income From Nursery',
            value:
            _value(
              'nurseryIncome',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NurseryDailyAccountsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Total Income From Indoor',
            value:
            _value(
              'indoorIncome',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InternalDailyAccountsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Total Other Income',
            value:
            _value(
              'otherIncome',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OtherIncomeScreen(),
                ),
              );
            },
          ),

          const Divider(),

          _buildTotalRow(
            title: 'Total',
            value:
            _value(
              'totalIncome',
            ),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPENSES
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
            _value(
              'nurseryExpenses',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NurseryDailyAccountsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Total Expenses From Indoor',
            value:
            _value(
              'indoorExpenses',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InternalDailyAccountsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Total Other Expenses',
            value:
            _value(
              'otherExpenses',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OtherExpensesScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Payments For Oxygen Account',
            value:
            _value(
              'oxygenPayments',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OxygenCalculationScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Payments For Sterilization Account',
            value:
            _value(
              'sterilizationPayments',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SterilizationMaterialAccountsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Payments For Maintenance',
            value:
            _value(
              'maintenancePayments',
            ),
            showDetails: true,
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FaultsScreen(),
                ),
              );
            },
          ),

          _buildMovementRow(
            title:
            'Discounts From Nursery',
            value:
            _value(
              'nurseryDiscounts',
            ),
            showDetails: false,
          ),

          _buildMovementRow(
            title:
            'Discounts From Indoor',
            value:
            _value(
              'indoorDiscounts',
            ),
            showDetails: false,
          ),

          _buildMovementRow(
            title: 'Advances',
            value:
            _value(
              'advances',
            ),
            showDetails: false,
          ),

          const Divider(),

          _buildTotalRow(
            title: 'Total',
            value:
            _value(
              'totalExpenses',
            ),
            color: Colors.red,
          ),

          const SizedBox(height: 8),

          _buildTotalRow(
            title: 'Daily Net',
            value:
            _value(
              'dailyNet',
            ),
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
  // SECTION
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
              textAlign:
              TextAlign.right,
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
    VoidCallback? onDetailsPressed,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          if (showDetails)
            SizedBox(
              width: 82,
              child: OutlinedButton(
                onPressed: onDetailsPressed ?? () {},
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
  // TOTAL
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