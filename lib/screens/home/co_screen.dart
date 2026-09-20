import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/co_api_service.dart';

class CoScreen extends StatefulWidget {
  const CoScreen({super.key});

  @override
  State<CoScreen> createState() => _CoScreenState();
}

class _CoScreenState extends State<CoScreen> {
  final TextEditingController coController =
  TextEditingController();

  List<Map<String, dynamic>> coList = [];

  bool loading = true;
  bool adding = false;

  String? coError;

  @override
  void initState() {
    super.initState();
    _loadCo();
  }

  @override
  void dispose() {
    coController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD C/O
  // ============================================================

  Future<void> _loadCo() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final data = await CoApiService.getAll();

      if (!mounted) return;

      setState(() {
        coList = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load C/O: $e',
      );
    }
  }

  // ============================================================
  // ADD C/O
  // ============================================================

  Future<void> _addCo() async {
    final name = coController.text.trim();

    if (name.isEmpty) {
      setState(() {
        coError = 'Invalid C/O Name';
      });
      return;
    }

    setState(() {
      coError = null;
      adding = true;
    });

    try {
      await CoApiService.addCo(
        coName: name,
      );

      // Reload from SQL Server so the list
      // reflects the actual database.
      await _loadCo();

      if (!mounted) return;

      coController.clear();

      _showMessage(
        'C/O added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add C/O: $e',
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

  Widget _buildCoRow(
      Map<String, dynamic> record,
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
              record['id']?.toString() ?? '',
            ),
          ),
          Expanded(
            child: Text(
              record['co_name']?.toString() ?? '',
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
        title: Text(AppTranslations.tr('C/O Details')),
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

                  Text(AppTranslations.tr('C/O Name'),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    coController,
                    onChanged: (_) {
                      if (coError != null) {
                        setState(() {
                          coError = null;
                        });
                      }
                    },
                    decoration:
                    InputDecoration(
                      border:
                      const OutlineInputBorder(),
                      hintText: AppTranslations.tr('Enter C/O name'),
                      errorText: coError,
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
                            : _addCo,
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
            // C/O LIST
            // =====================================================

            Text(AppTranslations.tr('C/O List'),
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
                    // TABLE HEADER
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
                          : coList.isEmpty
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
                        _loadCo,
                        child:
                        ListView.builder(
                          itemCount:
                          coList.length,
                          itemBuilder:
                              (
                              context,
                              index,
                              ) {
                            return _buildCoRow(
                              coList[
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