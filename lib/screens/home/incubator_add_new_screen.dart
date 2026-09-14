import 'package:flutter/material.dart';

class IncubatorAddNewScreen extends StatefulWidget {
  const IncubatorAddNewScreen({super.key});

  @override
  State<IncubatorAddNewScreen> createState() => _IncubatorAddNewScreenState();
}

class _IncubatorAddNewScreenState extends State<IncubatorAddNewScreen> {
  // Will be loaded from the API later.
  // Keep empty for now.
  final List<Map<String, String>> patients = [];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Basic Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================
              // NEW PATIENT SECTION
              // =========================
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
                    // Section heading
                    const Text(
                      'New Patient',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // TABLE
                    // =========================
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 650,
                          child: Column(
                            children: [
                              // =========================
                              // TABLE COLUMN NAMES
                              // =========================
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
                                      title: 'Birth Date',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'Birth Time',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'Admission Date',
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),

                              // =========================
                              // DATABASE DATA
                              // =========================
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

  // Empty table area.
  // Actual patients will come from the API later.
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
              ],
            ),
          );
        },
      ),
    );
  }

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
              text: patient['birthDate'] ?? '',
              flex: 2,
            ),
            _DataCell(
              text: patient['birthTime'] ?? '',
              flex: 2,
            ),
            _DataCell(
              text: patient['admissionDate'] ?? '',
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// TABLE HEADER CELL
// ======================================================

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
        padding: const EdgeInsets.symmetric(horizontal: 8),
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

// ======================================================
// EMPTY CELL
// ======================================================

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

// ======================================================
// DATA CELL
// ======================================================

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
        padding: const EdgeInsets.symmetric(horizontal: 8),
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