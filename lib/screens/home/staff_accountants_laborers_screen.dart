import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/staff_salary_api_service.dart';

class StaffAccountantsLaborersScreen extends StatefulWidget {
  const StaffAccountantsLaborersScreen({super.key});

  @override
  State<StaffAccountantsLaborersScreen> createState() =>
      _StaffAccountantsLaborersScreenState();
}

class _StaffAccountantsLaborersScreenState
    extends State<StaffAccountantsLaborersScreen> {
  // ============================================================
  // ACCOUNTANTS
  // ============================================================

  List<Map<String, dynamic>> accountants = [];

  bool loadingAccountants = false;
  bool loadingAccountantSalary = false;

  String? selectedAccountant;

  int accountantTotalSalary = 0;
  int accountantDeductions = 0;
  int accountantAdvances = 0;
  int accountantBonuses = 0;
  int accountantNetSalary = 0;

  // ============================================================
  // LABORERS
  // ============================================================

  List<Map<String, dynamic>> laborers = [];

  bool loadingLaborers = false;
  bool loadingLaborerSalary = false;

  String? selectedLaborer;

  int laborerTotalSalary = 0;
  int laborerDeductions = 0;
  int laborerAdvances = 0;
  int laborerBonuses = 0;
  int laborerNetSalary = 0;

  // ============================================================
  // MONTH
  // ============================================================

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAccountants();
    _loadLaborers();
  }

  // ============================================================
  // LOAD ACCOUNTANTS
  // ============================================================

  Future<void> _loadAccountants() async {
    setState(() {
      loadingAccountants = true;
    });

    try {
      final result =
      await StaffSalaryApiService.getAccountants();

      if (!mounted) return;

      setState(() {
        accountants = result;
        loadingAccountants = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAccountants = false;
      });

      _message(
        'Failed to load accountants.\n$e',
      );
    }
  }

  // ============================================================
  // LOAD LABORERS
  // ============================================================

  Future<void> _loadLaborers() async {
    setState(() {
      loadingLaborers = true;
    });

    try {
      final result =
      await StaffSalaryApiService.getLaborers();

      if (!mounted) return;

      setState(() {
        laborers = result;
        loadingLaborers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLaborers = false;
      });

      _message(
        'Failed to load laborers.\n$e',
      );
    }
  }

  // ============================================================
  // SELECT MONTH
  // ============================================================

  Future<void> _selectMonth() async {
    int tempMonth = selectedMonth;
    int tempYear = selectedYear;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppTranslations.tr('Select Month'),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // MONTH
                  DropdownButtonFormField<int>(
                    initialValue: tempMonth,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppTranslations.tr('Month'),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      12,
                          (index) {
                        final month = index + 1;

                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                            month
                                .toString()
                                .padLeft(2, '0'),
                          ),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        tempMonth = value;
                      });
                    },
                  ),

                  SizedBox(height: 15),

                  // YEAR
                  DropdownButtonFormField<int>(
                    initialValue: tempYear,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppTranslations.tr('Year'),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      101,
                          (index) {
                        final year = 2000 + index;

                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        tempYear = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(AppTranslations.tr('Cancel')),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      DateTime(
                        tempYear,
                        tempMonth,
                      ),
                    );
                  },
                  child: Text(AppTranslations.tr('Select')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      selectedMonth = result.month;
      selectedYear = result.year;
    });
  }

  // ============================================================
  // MONTH TEXT
  // ============================================================

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  // ============================================================
  // SHOW ACCOUNTANT
  // ============================================================

  Future<void> _showAccountant() async {
    if (selectedAccountant == null ||
        selectedAccountant == 'SELECT') {
      _message(
        'Please select an accountant.',
      );
      return;
    }

    final empId =
    int.tryParse(selectedAccountant!);

    if (empId == null) {
      _message(
        'Invalid accountant.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loadingAccountantSalary = true;
    });

    try {
      final result =
      await StaffSalaryApiService.getAccountantSalary(
        empId: empId,
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        accountantTotalSalary =
            _toInt(result['totalSalary']);

        accountantDeductions =
            _toInt(result['deductions']);

        accountantAdvances =
            _toInt(result['advances']);

        accountantBonuses =
            _toInt(result['bonuses']);

        accountantNetSalary =
            _toInt(result['netSalary']);

        loadingAccountantSalary = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAccountantSalary = false;
      });

      _message(
        'Failed to load accountant salary.\n$e',
      );
    }
  }

  // ============================================================
  // SHOW LABORER
  // ============================================================

  Future<void> _showLaborer() async {
    if (selectedLaborer == null ||
        selectedLaborer == 'SELECT') {
      _message(
        'Please select a laborer.',
      );
      return;
    }

    final empId =
    int.tryParse(selectedLaborer!);

    if (empId == null) {
      _message(
        'Invalid laborer.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loadingLaborerSalary = true;
    });

    try {
      final result =
      await StaffSalaryApiService.getLaborerSalary(
        empId: empId,
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        laborerTotalSalary =
            _toInt(result['totalSalary']);

        laborerDeductions =
            _toInt(result['deductions']);

        laborerAdvances =
            _toInt(result['advances']);

        laborerBonuses =
            _toInt(result['bonuses']);

        laborerNetSalary =
            _toInt(result['netSalary']);

        loadingLaborerSalary = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLaborerSalary = false;
      });

      _message(
        'Failed to load laborer salary.\n$e',
      );
    }
  }

  // ============================================================
  // INTEGER CONVERSION
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }

  // ============================================================
  // GET PERSON NAME
  // ============================================================

  String _getName(
      List<Map<String, dynamic>> people,
      String? id,
      ) {
    if (id == null || id == 'SELECT') {
      return '';
    }

    for (final person in people) {
      if (person['id'].toString() == id) {
        return person['name']?.toString() ?? '';
      }
    }

    return '';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // PERSON DROPDOWN
  // ============================================================

  Widget _personDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> people,
    required bool loading,
    required ValueChanged<String?> onChanged,
  }) {
    if (loading) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: AppTranslations.tr(label),
          border: const OutlineInputBorder(),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'SELECT',
          child: Text(AppTranslations.tr('Select')),
        ),
        ...people.map(
              (person) {
            return DropdownMenuItem<String>(
              value: person['id'].toString(),
              child: Text(
                person['name']?.toString() ?? '',
              ),
            );
          },
        ),
      ],
      onChanged: onChanged,
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(
            width: 70,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE SECTION
  // ============================================================

  Widget _employeeSection({
    required String title,
    required String? selectedPerson,
    required List<Map<String, dynamic>> people,
    required bool loadingPeople,
    required bool loadingSalary,
    required ValueChanged<String?> onChanged,
    required VoidCallback onShow,
    required int totalSalary,
    required int deductions,
    required int advances,
    required int bonuses,
    required int netSalary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          // TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          // DROPDOWN
          _personDropdown(
            label: 'Select Name',
            value: selectedPerson,
            people: people,
            loading: loadingPeople,
            onChanged: onChanged,
          ),

          SizedBox(height: 12),

          // SHOW
          ElevatedButton(
            onPressed:
            loadingSalary ? null : onShow,
            child: loadingSalary
                ? SizedBox(
              height: 20,
              width: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Text(AppTranslations.tr('Show')),
          ),

          SizedBox(height: 12),

          // SELECTED PERSON
          Text(
            selectedPerson == null ||
                selectedPerson == 'SELECT'
                ? '--'
                : _getName(
              people,
              selectedPerson,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          SizedBox(height: 12),

          // TOTAL SALARY
          _summaryRow(
            label: 'Total Salary',
            value: loadingSalary
                ? '...'
                : totalSalary.toString(),
            valueColor: Colors.black,
          ),

          // DEDUCTIONS
          _summaryRow(
            label: 'Deductions',
            value: loadingSalary
                ? '...'
                : deductions.toString(),
            valueColor: Colors.red,
          ),

          // ADVANCES
          _summaryRow(
            label: 'Advances',
            value: loadingSalary
                ? '...'
                : advances.toString(),
            valueColor: Colors.red,
          ),

          // BONUSES
          _summaryRow(
            label: 'Bonuses',
            value: loadingSalary
                ? '...'
                : bonuses.toString(),
            valueColor: Colors.green,
          ),

          // NET SALARY
          _summaryRow(
            label: 'Net Salary',
            value: loadingSalary
                ? '...'
                : netSalary.toString(),
            valueColor: Colors.blue,
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
        title: Text(AppTranslations.tr('Accountants and Laborers'),
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

            InkWell(
              onTap: _selectMonth,

              child: InputDecorator(
                decoration:
                InputDecoration(
                  labelText: AppTranslations.tr('Month'),
                  border:
                  OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_month,
                  ),
                ),

                child: Text(
                  _monthText(),
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ====================================================
            // ACCOUNTANTS
            // ====================================================

            _employeeSection(
              title: 'Accountants',

              selectedPerson:
              selectedAccountant,

              people: accountants,

              loadingPeople:
              loadingAccountants,

              loadingSalary:
              loadingAccountantSalary,

              onChanged: (value) {
                setState(() {
                  selectedAccountant = value;

                  // Reset displayed salary
                  accountantTotalSalary = 0;
                  accountantDeductions = 0;
                  accountantAdvances = 0;
                  accountantBonuses = 0;
                  accountantNetSalary = 0;
                });
              },

              onShow: _showAccountant,

              totalSalary:
              accountantTotalSalary,

              deductions:
              accountantDeductions,

              advances:
              accountantAdvances,

              bonuses:
              accountantBonuses,

              netSalary:
              accountantNetSalary,
            ),

            SizedBox(height: 20),

            // ====================================================
            // LABORERS
            // ====================================================

            _employeeSection(
              title: 'Laborers',

              selectedPerson:
              selectedLaborer,

              people: laborers,

              loadingPeople:
              loadingLaborers,

              loadingSalary:
              loadingLaborerSalary,

              onChanged: (value) {
                setState(() {
                  selectedLaborer = value;

                  // Reset displayed salary
                  laborerTotalSalary = 0;
                  laborerDeductions = 0;
                  laborerAdvances = 0;
                  laborerBonuses = 0;
                  laborerNetSalary = 0;
                });
              },

              onShow: _showLaborer,

              totalSalary:
              laborerTotalSalary,

              deductions:
              laborerDeductions,

              advances:
              laborerAdvances,

              bonuses:
              laborerBonuses,

              netSalary:
              laborerNetSalary,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}