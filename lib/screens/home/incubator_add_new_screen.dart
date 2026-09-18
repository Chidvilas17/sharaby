import 'package:flutter/material.dart';
import '../../services/incubator_add_new_api_service.dart';

class IncubatorAddNewScreen extends StatefulWidget {
  const IncubatorAddNewScreen({super.key});

  @override
  State<IncubatorAddNewScreen> createState() =>
      _IncubatorAddNewScreenState();
}

class _IncubatorAddNewScreenState
    extends State<IncubatorAddNewScreen> {
  List<Map<String, dynamic>> patients = [];

  int? selectedIndex;

  bool isLoading = true;
  String? errorMessage;

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
    });

    try {
      final data =
      await IncubatorAddNewApiService.getPatients();

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
              // ==================================================
              // NEW PATIENT SECTION
              // ==================================================

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
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // SECTION HEADING
                    // ==================================================

                    const Text(
                      'New Patient',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // TABLE
                    // ==================================================

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
                              // ==================================================
                              // HEADER
                              // ==================================================

                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                      Colors.grey.shade400,
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

                              // ==================================================
                              // LOADING
                              // ==================================================

                              if (isLoading)
                                const SizedBox(
                                  height: 480,
                                  child: Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                )

                              // ==================================================
                              // ERROR
                              // ==================================================

                              else if (errorMessage != null)
                                SizedBox(
                                  height: 480,
                                  child: Center(
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
                                          const Text(
                                            'Failed to load patients.',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            errorMessage!,
                                            textAlign:
                                            TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                            _loadPatients,
                                            child:
                                            const Text(
                                              'Retry',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )

                              // ==================================================
                              // NO DATA
                              // ==================================================

                              else if (patients.isEmpty)
                                  const SizedBox(
                                    height: 480,
                                    child: Center(
                                      child: Text(
                                        'No patients found.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )

                                // ==================================================
                                // PATIENT DATA
                                // ==================================================

                                else
                                  ...patients.asMap().entries.map(
                                        (entry) {
                                      final index =
                                          entry.key;

                                      final patient =
                                          entry.value;

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

  // ============================================================
  // PATIENT ROW
  // ============================================================

  Widget _buildPatientRow(
      int index,
      Map<String, dynamic> patient,
      ) {
    final isSelected =
        selectedIndex == index;

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
              text: patient['name']?.toString() ?? '',
              flex: 3,
            ),
            _DataCell(
              text:
              patient['birthDate']?.toString() ?? '',
              flex: 2,
            ),
            _DataCell(
              text:
              patient['birthTime']?.toString() ?? '',
              flex: 2,
            ),
            _DataCell(
              text:
              patient['admissionDate']?.toString() ??
                  '',
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