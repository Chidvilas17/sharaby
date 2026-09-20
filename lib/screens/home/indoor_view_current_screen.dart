import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/indoor_view_current_api_service.dart';

class IndoorViewCurrentScreen extends StatefulWidget {
  const IndoorViewCurrentScreen({super.key});

  @override
  State<IndoorViewCurrentScreen> createState() =>
      _IndoorViewCurrentScreenState();
}

class _IndoorViewCurrentScreenState
    extends State<IndoorViewCurrentScreen> {
  // ============================================================
  // DATABASE DATA
  // ============================================================

  List<Map<String, dynamic>> patients = [];

  int? selectedIndex;

  bool isLoading = true;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

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
      isLoading = true;
      errorMessage = null;
      selectedIndex = null;
    });

    try {
      final data =
      await IndoorViewCurrentApiService
          .getCurrentPatients();

      if (!mounted) return;

      setState(() {
        patients = data;
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
  // SELECT PATIENT
  // ============================================================

  void _selectPatient(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('InternalCheck')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // CURRENT PATIENTS
              // ==================================================

              Container(
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
                  borderRadius:
                  BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Text(AppTranslations.tr('Current Patients'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 16),

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
                        scrollDirection:
                        Axis.horizontal,
                        child: SizedBox(
                          width: 520,
                          child: Column(
                            children: [
                              // ==================================
                              // HEADER
                              // ==================================

                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color:
                                  Colors.grey.shade100,
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                      Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _HeaderCell(
                                      title: 'Name',
                                      flex: 3,
                                    ),
                                    _HeaderCell(
                                      title: 'Age',
                                      flex: 2,
                                    ),
                                    _HeaderCell(
                                      title: 'DOB',
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),

                              // ==================================
                              // LOADING
                              // ==================================

                              if (isLoading)
                                SizedBox(
                                  height: 480,
                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                )

                              // ==================================
                              // ERROR
                              // ==================================

                              else if (errorMessage !=
                                  null)
                                SizedBox(
                                  height: 480,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(
                                      20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      children: [
                                        Text(AppTranslations.tr('Failed to load patients.'),
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          errorMessage!,
                                          textAlign:
                                          TextAlign.center,
                                        ),

                                        SizedBox(
                                          height: 16,
                                        ),

                                        ElevatedButton(
                                          onPressed:
                                          _loadPatients,
                                          child:
                                          Text(AppTranslations.tr('Retry'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )

                              // ==================================
                              // NO DATA
                              // ==================================

                              else if (patients.isEmpty)
                                  _buildEmptyRows()

                                // ==================================
                                // DATA
                                // ==================================

                                else
                                  ...patients
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) {
                                      return _buildPatientRow(
                                        entry.key,
                                        entry.value,
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

  // ============================================================
  // EMPTY TABLE
  // ============================================================

  Widget _buildEmptyRows() {
    return Column(
      children: List.generate(
        16,
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
            child: Row(
              children: [
                _EmptyCell(flex: 3),
                _EmptyCell(flex: 2),
                _EmptyCell(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PATIENT ROW
  // ============================================================

  Widget _buildPatientRow(
      int index,
      Map<String, dynamic> patient,
      ) {
    final bool isSelected =
        selectedIndex == index;

    return InkWell(
      onTap: () {
        _selectPatient(index);
      },
      child: Container(
        height: 44,
        color: isSelected
            ? Colors.blue.withValues(
          alpha: 0.12,
        )
            : Colors.transparent,
        child: Row(
          children: [
            _DataCell(
              text:
              patient['name']?.toString() ?? '',
              flex: 3,
            ),

            _DataCell(
              text:
              patient['age']?.toString() ?? '',
              flex: 2,
            ),

            _DataCell(
              text:
              patient['dob']?.toString() ?? '',
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HEADER CELL
// ================================================================

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

// ================================================================
// EMPTY CELL
// ================================================================

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

// ================================================================
// DATA CELL
// ================================================================

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