import 'package:flutter/material.dart';

import '../../services/diagnosis_api_service.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final TextEditingController diagnosisController =
  TextEditingController();

  List<Map<String, dynamic>> diagnosisList = [];

  bool loading = true;
  bool adding = false;

  String? diagnosisError;

  @override
  void initState() {
    super.initState();
    _loadDiagnosis();
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadDiagnosis() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final data =
      await DiagnosisApiService.getAll();

      if (!mounted) return;

      setState(() {
        diagnosisList = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load diagnosis: $e',
      );
    }
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> _addDiagnosis() async {
    final name =
    diagnosisController.text.trim();

    if (name.isEmpty) {
      setState(() {
        diagnosisError = 'Invalid Diagnosis Name';
      });
      return;
    }

    setState(() {
      diagnosisError = null;
      adding = true;
    });

    try {
      await DiagnosisApiService.addDiagnosis(
        diagnosisName: name,
      );

      if (!mounted) return;

      diagnosisController.clear();

      await _loadDiagnosis();

      if (!mounted) return;

      _showMessage(
        'Diagnosis added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add diagnosis: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        adding = false;
      });
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildDiagnosisRow(
      Map<String, dynamic> diagnosis,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              diagnosis['diagnosis_id']
                  ?.toString() ??
                  '',
            ),
          ),
          Expanded(
            child: Text(
              diagnosis['diagnosis_name']
                  ?.toString() ??
                  '',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnosis Details',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            // =====================================================
            // ADD SECTION
            // =====================================================

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Diagnosis Name',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    diagnosisController,
                    onChanged: (_) {
                      if (diagnosisError !=
                          null) {
                        setState(() {
                          diagnosisError =
                          null;
                        });
                      }
                    },
                    decoration:
                    InputDecoration(
                      border:
                      const OutlineInputBorder(),
                      hintText:
                      'Enter diagnosis name',
                      errorText:
                      diagnosisError,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        onPressed:
                        adding
                            ? null
                            : _addDiagnosis,
                        child: adding
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Add',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // DATABASE LIST
            // =====================================================

            const Text(
              'Diagnosis List',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Expanded(
              child: Container(
                decoration:
                BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors
                            .grey
                            .shade100,
                        border:
                        Border(
                          bottom:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade400,
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              'No.',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Name',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // DATA
                    // =================================================

                    Expanded(
                      child: loading
                          ? const Center(
                        child:
                        CircularProgressIndicator(),
                      )
                          : diagnosisList
                          .isEmpty
                          ? const Center(
                        child: Text(
                          'No data',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      )
                          : RefreshIndicator(
                        onRefresh:
                        _loadDiagnosis,
                        child:
                        ListView.builder(
                          itemCount:
                          diagnosisList
                              .length,
                          itemBuilder:
                              (
                              context,
                              index,
                              ) {
                            return _buildDiagnosisRow(
                              diagnosisList[
                              index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}