import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatementsTodayAccountScreen extends StatefulWidget {
  const StatementsTodayAccountScreen({super.key});

  @override
  State<StatementsTodayAccountScreen> createState() =>
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

  @override
  void initState() {
    super.initState();
    _loadStatements();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  Future<void> _loadStatements() async {
    setState(() {
      isLoading = true;
      selectedRow = null;
    });

    final dateText =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5137/api/TodayStatements?date=$dateText'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          if (mounted) {
            setState(() {
              statements = decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
            });
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
    _loadStatements();
  }

  double _calculateTotalIncome() {
    double total = 0;
    for (final item in statements) {
      total += double.tryParse(item['price']?.toString() ?? item['amount']?.toString() ?? '') ?? 0;
    }
    return total;
  }

  Widget _buildTable() {
    final displayCount = statements.length < 10 ? 10 : statements.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(140),
        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF4D88B5),
            ),
            children: headers.map((header) {
              return Container(
                height: 48,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),

          for (int index = 0; index < displayCount; index++)
            TableRow(
              children: [
                _dataCell(index, index < statements.length ? '${index + 1}' : ''),
                _dataCell(index, index < statements.length ? (statements[index]['name']?.toString() ?? statements[index]['patientName']?.toString() ?? '') : ''),
                _dataCell(index, index < statements.length ? (statements[index]['type']?.toString() ?? '') : ''),
                _dataCell(index, index < statements.length ? (statements[index]['price']?.toString() ?? statements[index]['amount']?.toString() ?? '') : ''),
                _dataCell(index, index < statements.length ? (statements[index]['time']?.toString() ?? '') : ''),
                _dataCell(index, index < statements.length ? (statements[index]['doctor']?.toString() ?? statements[index]['doctorName']?.toString() ?? '') : ''),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dataCell(int index, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = index;
        });
      },
      child: Container(
        height: 42,
        alignment: Alignment.center,
        color: selectedRow == index
            ? Colors.blue.withOpacity(0.2)
            : const Color(0xFFD3DFE9),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _calculateTotalIncome();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Total Statements / بيانات الكشف اليومية'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'التاريخ / Date',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _formatDate(selectedDate),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _loadStatements,
                  icon: const Icon(Icons.search),
                  label: const Text(
                    'Search / بحث',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'بيانات الكشف / Statement Data',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTable(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'إجمالي الواردات / Total Income: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    totalIncome.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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