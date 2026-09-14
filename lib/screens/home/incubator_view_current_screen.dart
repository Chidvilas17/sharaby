import 'package:flutter/material.dart';

class IncubatorViewCurrentScreen extends StatefulWidget {
  const IncubatorViewCurrentScreen({super.key});

  @override
  State<IncubatorViewCurrentScreen> createState() =>
      _IncubatorViewCurrentScreenState();
}

class _IncubatorViewCurrentScreenState
    extends State<IncubatorViewCurrentScreen> {
  // This will be filled from the API later.
  // Keep empty for now.
  final List<Map<String, String>> patients = [];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In Patient Check'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // CURRENT PATIENTS SECTION
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  12,
                  18,
                  12,
                  12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Current Patients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // PATIENT TABLE
                    // ==========================================
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 700,
                          child: Column(
                            children: [
                              // ==================================
                              // TABLE HEADER
                              // ==================================
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    _HeaderCell(
                                      title: 'Name',
                                      flex: 3,
                                    ),
                                    _HeaderCell(
                                      title: 'Date of Birth',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'Time of Birth',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'Admission Date',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'Status',
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),

                              // ==================================
                              // DATABASE DATA
                              // ==================================
                              if (patients.isEmpty)
                                _buildEmptyRows()
                              else
                                ...patients.asMap().entries.map(
                                      (entry) {
                                    final index = entry.key;
                                    final patient = entry.value;

                                    return _buildPatientRow(
                                      index,
                                      patient,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY TABLE
  // ==========================================

  Widget _buildEmptyRows() {
    return Column(
      children: List.generate(
        15,
            (index) {
          return Container(
            height: 32,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: const Row(
              children: [
                _EmptyCell(flex: 3),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // PATIENT ROW
  // ==========================================

  Widget _buildPatientRow(
      int index,
      Map<String, String> patient,
      ) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        height: 44,
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Row(
          children: [
            _DataCell(
              text: patient['name'] ?? '',
              flex: 3,
            ),
            _DataCell(
              text: patient['dateOfBirth'] ?? '',
              flex: 2,
            ),
            _DataCell(
              text: patient['timeOfBirth'] ?? '',
              flex: 2,
            ),
            _DataCell(
              text: patient['admissionDate'] ?? '',
              flex: 2,
            ),
            _DataCell(
              text: patient['status'] ?? '',
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TABLE HEADER CELL
// ==========================================

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell({
    required this.title,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// EMPTY CELL
// ==========================================

class _EmptyCell extends StatelessWidget {
  final int flex;

  const _EmptyCell({
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// DATA CELL
// ==========================================

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;

  const _DataCell({
    required this.text,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
            ),
            bottom: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}