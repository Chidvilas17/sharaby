import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/staff_discounts_api_service.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  // ============================================================
  // EMPLOYEE TYPE
  // ============================================================

  String selectedType = 'Nurses';

  // ============================================================
  // MONTH
  // ============================================================

  final TextEditingController monthController =
  TextEditingController(
    text: '09/2026',
  );

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> employees = [];

  bool loading = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    monthController.dispose();
    super.dispose();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  int _categoryId() {
    switch (selectedType) {
      case 'Accountants':
        return 2;

      case 'Workers':
        return 4;

      case 'Nurses':
      default:
        return 3;
    }
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
  // LOAD DATA
  //
  // IMPORTANT:
  // This uses the SAME API service as Staff Discounts.
  // ============================================================

  Future<void> _loadData() async {
    final parsed = _parseMonth();

    if (parsed == null) {
      _showMessage(
        'Please enter month as MM/YYYY.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result =
      await StaffDiscountsApiService.getStaffDiscounts(
        category: _categoryId(),
        month: parsed['month']!,
        year: parsed['year']!,
      );

      if (!mounted) return;

      setState(() {
        employees = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        employees = [];
      });

      _showMessage(
        'Failed to load deductions.\n$e',
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE TYPE
  // ============================================================

  Widget _buildTypeRadio({
    required String title,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: selectedType,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: loading
          ? null
          : (value) async {
        if (value == null) return;

        setState(() {
          selectedType = value;
          employees = [];
        });

        await _loadData();
      },
    );
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  String _name(Map<String, dynamic> employee) {
    return employee['name']?.toString() ?? '';
  }

  String _deductions(Map<String, dynamic> employee) {
    return employee['deductions']?.toString() ?? '0';
  }

  String _advances(Map<String, dynamic> employee) {
    return employee['advances']?.toString() ?? '0';
  }

  String _bonuses(Map<String, dynamic> employee) {
    return employee['bonuses']?.toString() ?? '0';
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(AppTranslations.tr('Name'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(AppTranslations.tr('Deductions'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(AppTranslations.tr('Advances'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(AppTranslations.tr('Bonuses'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // DATA
          // ======================================================

          if (loading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (employees.isEmpty)
            Expanded(
              child: Center(
                child: Text(AppTranslations.tr('No data'),
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _name(employee),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _deductions(employee),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _advances(employee),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _bonuses(employee),
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
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Deductions'),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            // ====================================================
            // MONTH
            // ====================================================

            Text(AppTranslations.tr('Month'),
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            SizedBox(height: 8),

            TextField(
              controller: monthController,

              decoration:
              InputDecoration(
                border:
                OutlineInputBorder(),
                hintText: AppTranslations.tr('MM/YYYY'),
              ),
            ),

            SizedBox(height: 20),

            // ====================================================
            // EMPLOYEE TYPE
            // ====================================================

            Text(AppTranslations.tr('Select Type'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 8),

            _buildTypeRadio(
              title: 'Nurses',
            ),

            _buildTypeRadio(
              title: 'Accountants',
            ),

            _buildTypeRadio(
              title: 'Workers',
            ),

            SizedBox(height: 12),

            // ====================================================
            // SHOW
            // ====================================================

            SizedBox(
              height: 45,

              child: ElevatedButton(
                onPressed:
                loading ? null : _loadData,

                child: Text(AppTranslations.tr('Show'),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ====================================================
            // DATA TABLE
            // ====================================================

            Text(AppTranslations.tr('Salary Details'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 8),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}