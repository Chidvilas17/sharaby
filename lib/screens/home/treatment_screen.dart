import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/treatment_api_service.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() =>
      _TreatmentScreenState();
}

class _TreatmentScreenState
    extends State<TreatmentScreen> {
  final TextEditingController treatmentController =
  TextEditingController();

  List<Map<String, dynamic>> treatmentList = [];

  bool loading = true;
  bool adding = false;

  String? treatmentError;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  @override
  void dispose() {
    treatmentController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD TREATMENTS
  // ============================================================

  Future<void> _loadTreatments() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final data =
      await TreatmentApiService.getAll();

      if (!mounted) return;

      setState(() {
        treatmentList = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load treatments: $e',
      );
    }
  }

  // ============================================================
  // ADD TREATMENT
  // ============================================================

  Future<void> _addTreatment() async {
    final name =
    treatmentController.text.trim();

    if (name.isEmpty) {
      setState(() {
        treatmentError =
        'Invalid Treatment Name';
      });
      return;
    }

    setState(() {
      treatmentError = null;
      adding = true;
    });

    try {
      await TreatmentApiService.addTreatment(
        treatment: name,
      );

      // Reload from database so the Flutter
      // list always reflects the actual SQL data.
      await _loadTreatments();

      if (!mounted) return;

      treatmentController.clear();

      _showMessage(
        'Treatment added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add treatment: $e',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
        ),
      );
  }

  // ============================================================
  // TABLE ROW
  // ============================================================

  Widget _buildTreatmentRow(
      Map<String, dynamic> treatment,
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
              treatment['treat_id']
                  ?.toString() ??
                  '',
            ),
          ),
          Expanded(
            child: Text(
              treatment['treatment']
                  ?.toString() ??
                  '',
            ),
          ),
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
        title: Text(AppTranslations.tr('Treatment Details'),
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
                  Text(AppTranslations.tr('Add'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Text(AppTranslations.tr('Treatment Name'),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    treatmentController,
                    onChanged: (_) {
                      if (treatmentError !=
                          null) {
                        setState(() {
                          treatmentError =
                          null;
                        });
                      }
                    },
                    decoration:
                    InputDecoration(
                      border:
                      const OutlineInputBorder(),
                      hintText: AppTranslations.tr('Enter treatment name'),
                      errorText:
                      treatmentError,
                    ),
                  ),

                  SizedBox(
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
                            : _addTreatment,
                        child: adding
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(AppTranslations.tr('Add'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),

            // =====================================================
            // DATABASE LIST
            // =====================================================

            Text(AppTranslations.tr('Treatment List'),
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            SizedBox(
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(AppTranslations.tr('No.'),
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(AppTranslations.tr('Name'),
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
                          ? Center(
                        child:
                        CircularProgressIndicator(),
                      )
                          : treatmentList
                          .isEmpty
                          ? Center(
                        child: Text(AppTranslations.tr('No data'),
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      )
                          : RefreshIndicator(
                        onRefresh:
                        _loadTreatments,
                        child:
                        ListView.builder(
                          itemCount:
                          treatmentList
                              .length,
                          itemBuilder:
                              (
                              context,
                              index,
                              ) {
                            return _buildTreatmentRow(
                              treatmentList[
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