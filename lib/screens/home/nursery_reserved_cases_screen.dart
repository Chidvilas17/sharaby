import 'package:flutter/material.dart';

import '../../services/nursery_reserved_api_service.dart';

class NurseryReservedCasesScreen extends StatefulWidget {
  const NurseryReservedCasesScreen({super.key});

  @override
  State<NurseryReservedCasesScreen> createState() =>
      _NurseryReservedCasesScreenState();
}

class _NurseryReservedCasesScreenState
    extends State<NurseryReservedCasesScreen> {
  int? selectedRow;

  bool loading = false;

  List<Map<String, dynamic>> reservedCases = [];

  final List<String> headers = [
    'No.',
    'Name',
    'Total Account',
  ];

  @override
  void initState() {
    super.initState();

    _loadReservedCases();
  }

  // ============================================================
  // LOAD RESERVED CASES
  // ============================================================

  Future<void> _loadReservedCases() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      final result =
      await NurseryReservedApiService.getReservedCases();

      if (!mounted) return;

      setState(() {
        reservedCases = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load reserved cases: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // GET VALUE
  // ============================================================

  String _getValue(
      Map<String, dynamic> row,
      String key,
      ) {
    final value = row[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (loading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(150),
        border: TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
            ),
            children: headers.map((header) {
              return Container(
                height: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          // ======================================================
          // DATABASE ROWS
          // ======================================================

          ...List.generate(20, (index) {
            final hasData =
                index < reservedCases.length;

            final row =
            hasData
                ? reservedCases[index]
                : null;

            final isSelected =
                selectedRow == index;

            String cellValue(
                String header,
                ) {
              if (!hasData || row == null) {
                return '';
              }

              if (header == 'Name') {
                return _getValue(
                  row,
                  'name',
                );
              }

              if (header == 'Total Account') {
                return _getValue(
                  row,
                  'totalAccount',
                );
              }

              return '';
            }

            return TableRow(
              children: headers.map((header) {
                return GestureDetector(
                  onTap: () {
                    if (!hasData) {
                      return;
                    }

                    setState(() {
                      selectedRow = index;
                    });
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: isSelected
                        ? Colors.blue.withOpacity(0.12)
                        : Colors.transparent,
                    child: Text(
                      header == 'No.'
                          ? hasData
                          ? '${index + 1}'
                          : ''
                          : cellValue(header),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
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
        title: const Text('Reserved Cases'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reserved Cases',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}