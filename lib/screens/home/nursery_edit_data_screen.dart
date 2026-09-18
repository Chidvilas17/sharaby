import 'package:flutter/material.dart';

import '../../services/nursery_edit_data_api_service.dart';

class NurseryEditDataScreen extends StatefulWidget {
  const NurseryEditDataScreen({super.key});

  @override
  State<NurseryEditDataScreen> createState() =>
      _NurseryEditDataScreenState();
}

class _NurseryEditDataScreenState
    extends State<NurseryEditDataScreen> {
  int? selectedRow;

  bool loading = false;

  List<Map<String, dynamic>> patients = [];

  final List<String> headers = [
    'Name',
    'Phone',
    'Date of Birth',
  ];

  @override
  void initState() {
    super.initState();

    _loadPatients();
  }

  // ============================================================
  // LOAD PATIENTS
  // ============================================================

  Future<void> _loadPatients() async {
    setState(() {
      loading = true;
    });

    try {
      final result =
      await NurseryEditDataApiService.getPatients();

      if (!mounted) return;

      setState(() {
        patients = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load nursery patients: $e',
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '';
    }

    DateTime? date;

    try {
      date = DateTime.tryParse(text);
    } catch (_) {
      date = null;
    }

    if (date == null) {
      return text;
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // GET PATIENT VALUE
  // ============================================================

  String _patientValue(
      Map<String, dynamic> patient,
      String field,
      ) {
    final value = patient[field];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (loading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(170),
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
          // PATIENT DATA
          // ======================================================

          ...List.generate(20, (index) {
            final hasData =
                index < patients.length;

            final patient =
            hasData ? patients[index] : null;

            return TableRow(
              children: headers.map((header) {
                String value = '';

                if (patient != null) {
                  if (header == 'Name') {
                    value = _patientValue(
                      patient,
                      'name',
                    );
                  } else if (header == 'Phone') {
                    value = _patientValue(
                      patient,
                      'phone',
                    );
                  } else if (
                  header == 'Date of Birth') {
                    value = _formatDate(
                      patient['timeOfBorn'],
                    );
                  }
                }

                return GestureDetector(
                  onTap: hasData
                      ? () {
                    setState(() {
                      selectedRow = index;
                    });
                  }
                      : null,
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: selectedRow == index
                        ? Colors.blue
                        .withOpacity(0.12)
                        : Colors.transparent,
                    padding:
                    const EdgeInsets.all(6),
                    child: Text(
                      value,
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
        title: const Text(
          'Edit Nursery Data',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Nursery Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}