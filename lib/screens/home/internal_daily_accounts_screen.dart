import 'package:flutter/material.dart';
import '../../services/internal_daily_accounts_api_service.dart';

class InternalDailyAccountsScreen extends StatefulWidget {
  const InternalDailyAccountsScreen({super.key});

  @override
  State<InternalDailyAccountsScreen> createState() => _InternalDailyAccountsScreenState();
}

class _InternalDailyAccountsScreenState extends State<InternalDailyAccountsScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedIncomeRow;
  int? selectedExpenseRow;

  bool loading = false;
  bool deletingIncome = false;
  bool deletingExpense = false;

  List<Map<String, dynamic>> incomeRecords = [];
  List<Map<String, dynamic>> expenseRecords = [];

  final List<String> headers = [
    'اسم الحالة / Case Name',
    'النوع / Type',
    'رقم الوصل / Receipt Number',
    'المبلغ / Amount',
    'محاسب / Accountant',
    'ملاحظات / Notes',
  ];

  @override
  void initState() {
    super.initState();
    _search();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
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
      _search();
    }
  }

  Future<void> _search() async {
    setState(() {
      loading = true;
      selectedIncomeRow = null;
      selectedExpenseRow = null;
    });

    try {
      final result = await InternalDailyAccountsApiService.getDailyAccounts(selectedDate);
      final income = result['income'];
      final expenses = result['expenses'];

      if (!mounted) return;

      setState(() {
        incomeRecords = income is List
            ? income.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList()
            : [];
        expenseRecords = expenses is List
            ? expenses.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList()
            : [];
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _deleteIncome() async {
    if (selectedIncomeRow == null || selectedIncomeRow! < 0 || selectedIncomeRow! >= incomeRecords.length) {
      _showMessage('Please select an income row first.');
      return;
    }

    final record = incomeRecords[selectedIncomeRow!];
    final id = record['id'];

    setState(() => deletingIncome = true);
    try {
      if (id != null) {
        await InternalDailyAccountsApiService.deleteIncome(int.parse(id.toString()));
      }
      setState(() {
        incomeRecords.removeAt(selectedIncomeRow!);
        selectedIncomeRow = null;
      });
      _showMessage('Internal income record deleted.');
    } catch (e) {
      _showMessage('Failed to delete: $e');
    } finally {
      if (mounted) setState(() => deletingIncome = false);
    }
  }

  Future<void> _deleteExpense() async {
    if (selectedExpenseRow == null || selectedExpenseRow! < 0 || selectedExpenseRow! >= expenseRecords.length) {
      _showMessage('Please select an expense row first.');
      return;
    }

    final record = expenseRecords[selectedExpenseRow!];
    final id = record['id'];

    setState(() => deletingExpense = true);
    try {
      if (id != null) {
        await InternalDailyAccountsApiService.deleteExpense(int.parse(id.toString()));
      }
      setState(() {
        expenseRecords.removeAt(selectedExpenseRow!);
        selectedExpenseRow = null;
      });
      _showMessage('Internal expense record deleted.');
    } catch (e) {
      _showMessage('Failed to delete: $e');
    } finally {
      if (mounted) setState(() => deletingExpense = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double _calculateTotal(List<Map<String, dynamic>> list) {
    double sum = 0;
    for (final item in list) {
      sum += double.tryParse(item['amount']?.toString() ?? item['price']?.toString() ?? '') ?? 0;
    }
    return sum;
  }

  Widget _buildTable({required bool isIncome}) {
    final records = isIncome ? incomeRecords : expenseRecords;
    final selectedRow = isIncome ? selectedIncomeRow : selectedExpenseRow;
    final displayRows = records.length < 8 ? 8 : records.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(140),
        border: TableBorder.all(color: Colors.grey, width: 0.7),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
            children: headers.map((header) {
              return Container(
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            }).toList(),
          ),
          for (int index = 0; index < displayRows; index++)
            TableRow(
              children: [
                _cell(index, isIncome, index < records.length ? (records[index]['patientName']?.toString() ?? '') : '', selectedRow),
                _cell(index, isIncome, index < records.length ? (records[index]['type']?.toString() ?? '') : '', selectedRow),
                _cell(index, isIncome, index < records.length ? (records[index]['receiptNumber']?.toString() ?? '') : '', selectedRow),
                _cell(index, isIncome, index < records.length ? (records[index]['amount']?.toString() ?? '') : '', selectedRow),
                _cell(index, isIncome, index < records.length ? (records[index]['accountant']?.toString() ?? '') : '', selectedRow),
                _cell(index, isIncome, index < records.length ? (records[index]['notes']?.toString() ?? '') : '', selectedRow),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(int index, bool isIncome, String text, int? selectedRow) {
    final isSelected = selectedRow == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isIncome) {
            selectedIncomeRow = index;
          } else {
            selectedExpenseRow = index;
          }
        });
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildAccountPanel({
    required String title,
    required bool isIncome,
    required VoidCallback onDelete,
  }) {
    final records = isIncome ? incomeRecords : expenseRecords;
    final total = _calculateTotal(records);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            records.isEmpty ? 'لا يوجد عمليات لهذا اليوم / No operations this day' : '${records.length} operation(s)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: records.isEmpty ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildTable(isIncome: isIncome),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onDelete,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.delete),
            label: const Text('Delete / حذف'),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isIncome ? 'إجمالي الوارد / Total Income: ' : 'إجمالي المنصرف / Total Expenses: ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                total.toStringAsFixed(0),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isIncome ? Colors.blue : Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات اليومية للداخلي / Internal Daily Accounts'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search by Date Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    const Text(
                      'بحث بالتاريخ / Search By Date',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _formatDate(selectedDate),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search / بحث', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (loading)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
              else ...[
                // Right Panel: Internal Income
                _buildAccountPanel(
                  title: 'واردات الداخلي / Internal Income',
                  isIncome: true,
                  onDelete: _deleteIncome,
                ),
                const SizedBox(height: 20),
                // Left Panel: Internal Expenses
                _buildAccountPanel(
                  title: 'مصروفات الداخلي / Internal Expenses',
                  isIncome: false,
                  onDelete: _deleteExpense,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
