import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/indoor_add_new_api_service.dart';

class IndoorAddNewScreen extends StatefulWidget {
  const IndoorAddNewScreen({
    super.key,
  });

  @override
  State<IndoorAddNewScreen> createState() =>
      _IndoorAddNewScreenState();
}

class _IndoorAddNewScreenState
    extends State<IndoorAddNewScreen> {

  // ============================================================
  // PATIENT DATA
  // ============================================================

  List<Map<String, dynamic>> patients = [];

  int? selectedIndex;

  // ============================================================
  // LOADING
  // ============================================================

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
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result =
      await IndoorAddNewApiService.getPatients();

      if (!mounted) {
        return;
      }

      setState(() {
        patients = result;
        selectedIndex = null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        patients = [];
        selectedIndex = null;
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SELECT PATIENT
  // ============================================================

  void _selectPatient(int index) {
    if (index < 0 ||
        index >= patients.length) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  // ============================================================
  // GET VALUE
  // ============================================================

  String _getValue(
      Map<String, dynamic> patient,
      String key,
      ) {
    final value = patient[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('MedicalInternal'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // NEW PATIENT SECTION
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(
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

                    // ==========================================
                    // SECTION TITLE
                    // ==========================================

                    Text(AppTranslations.tr('New Patient'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    // ==========================================
                    // TABLE
                    // ==========================================

                    Container(
                      decoration:
                      BoxDecoration(
                        border: Border.all(
                          color:
                          Colors.grey.shade500,
                        ),
                      ),

                      child:
                      SingleChildScrollView(
                        scrollDirection:
                        Axis.horizontal,

                        child: SizedBox(
                          width: 500,

                          child: Column(
                            children: [

                              // =================================
                              // HEADER
                              // =================================

                              Container(
                                height: 52,

                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .grey.shade100,

                                  border:
                                  Border(
                                    bottom:
                                    BorderSide(
                                      color: Colors
                                          .grey.shade400,
                                    ),
                                  ),
                                ),

                                child:
                                Row(
                                  children: [

                                    _HeaderCell(
                                      title: 'Name',
                                      flex: 3,
                                    ),

                                    _HeaderCell(
                                      title: 'Age',
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),

                              // =================================
                              // LOADING
                              // =================================

                              if (isLoading)
                                SizedBox(
                                  height: 480,

                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                )

                              // =================================
                              // ERROR
                              // =================================

                              else if (
                              errorMessage !=
                                  null)
                                _buildError()

                              // =================================
                              // EMPTY
                              // =================================

                              else if (
                                patients.isEmpty)
                                  _buildEmptyRows()

                                // =================================
                                // DATA
                                // =================================

                                else
                                  ...patients
                                      .asMap()
                                      .entries
                                      .map(
                                        (
                                        entry,
                                        ) {
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
  // ERROR
  // ============================================================

  Widget _buildError() {
    return SizedBox(
      height: 480,

      child: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.red,
              ),

              SizedBox(
                height: 12,
              ),

              Text(
                errorMessage ??
                    'Failed to load patients.',
                textAlign:
                TextAlign.center,
              ),

              SizedBox(
                height: 16,
              ),

              ElevatedButton.icon(
                onPressed: _loadPatients,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: Text(AppTranslations.tr('Retry'),
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

            decoration:
            BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                  Colors.grey.shade200,
                ),
              ),
            ),

            child: Row(
              children: [

                _EmptyCell(
                  flex: 3,
                ),

                _EmptyCell(
                  flex: 2,
                ),
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

    final name =
    _getValue(
      patient,
      'patientName',
    );

    final age =
    _getValue(
      patient,
      'age',
    );

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
              text: name,
              flex: 3,
            ),

            _DataCell(
              text: age,
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// TABLE HEADER CELL
// ================================================================

class _HeaderCell
    extends StatelessWidget {

  final String title;

  final int flex;

  const _HeaderCell({
    required this.title,
    required this.flex,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      flex: flex,

      child: Container(
        alignment:
        Alignment.center,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),

        decoration:
        BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade300,
            ),
          ),
        ),

        child: Text(
          title,

          textAlign:
          TextAlign.center,

          style:
          const TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY CELL
// ================================================================

class _EmptyCell
    extends StatelessWidget {

  final int flex;

  const _EmptyCell({
    required this.flex,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      flex: flex,

      child: Container(
        decoration:
        BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade200,
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

class _DataCell
    extends StatelessWidget {

  final String text;

  final int flex;

  const _DataCell({
    required this.text,
    required this.flex,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      flex: flex,

      child: Container(
        alignment:
        Alignment.center,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
        ),

        decoration:
        BoxDecoration(
          border: Border(
            right: BorderSide(
              color:
              Colors.grey.shade200,
            ),

            bottom: BorderSide(
              color:
              Colors.grey.shade200,
            ),
          ),
        ),

        child: Text(
          text,

          textAlign:
          TextAlign.center,

          overflow:
          TextOverflow.ellipsis,
        ),
      ),
    );
  }
}