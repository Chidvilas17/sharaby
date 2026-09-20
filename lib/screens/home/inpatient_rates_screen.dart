import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/inpatient_rates_api_service.dart';

class InpatientRatesScreen extends StatefulWidget {
  const InpatientRatesScreen({super.key});

  @override
  State<InpatientRatesScreen> createState() =>
      _InpatientRatesScreenState();
}

class _InpatientRatesScreenState
    extends State<InpatientRatesScreen> {
  final TextEditingController typeController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  List<Map<String, dynamic>> rates = [];

  bool loading = true;
  bool saving = false;

  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    _loadRates();
  }

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadRates() async {
    setState(() {
      loading = true;
      selectedIndex = null;
    });

    try {
      final result =
      await InpatientRatesApiService
          .getRates();

      if (!mounted) {
        return;
      }

      setState(() {
        rates = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load internal devices: $e',
      );
    }
  }

  // ============================================================
  // ADD / SAVE
  // ============================================================

  Future<void> _save() async {
    final type =
    typeController.text.trim();

    final priceText =
    priceController.text.trim();

    if (type.isEmpty) {
      _showMessage(
        'Please enter the device type.',
      );
      return;
    }

    if (priceText.isEmpty) {
      _showMessage(
        'Please enter the price.',
      );
      return;
    }

    final price =
    int.tryParse(priceText);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid price.',
      );
      return;
    }

    if (saving) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      if (selectedIndex != null) {
        // ======================================================
        // UPDATE
        // ======================================================

        final selected =
        rates[selectedIndex!];

        final id =
        int.parse(
          selected['id'].toString(),
        );

        await InpatientRatesApiService
            .updateRate(
          id: id,
          type: type,
          price: price,
        );

        _showMessage(
          'Internal device rate updated successfully.',
        );
      } else {
        // ======================================================
        // ADD
        // ======================================================

        await InpatientRatesApiService
            .addRate(
          type: type,
          price: price,
        );

        _showMessage(
          'Internal device rate saved successfully.',
        );
      }

      typeController.clear();
      priceController.clear();

      setState(() {
        selectedIndex = null;
      });

      await _loadRates();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to save internal device: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // ============================================================
  // SELECT ROW
  // ============================================================

  void _selectRow(int index) {
    final item =
    rates[index];

    setState(() {
      selectedIndex = index;

      typeController.text =
          item['type']?.toString() ?? '';

      priceController.text =
          item['price']?.toString() ?? '';
    });
  }

  // ============================================================
  // ADD NEW
  // ============================================================

  void _addNew() {
    setState(() {
      selectedIndex = null;

      typeController.clear();
      priceController.clear();
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteSelected() async {
    if (selectedIndex == null) {
      _showMessage(
        'Please select a device first.',
      );
      return;
    }

    final selected =
    rates[selectedIndex!];

    final id =
    int.parse(
      selected['id'].toString(),
    );

    try {
      await InpatientRatesApiService
          .deleteRate(id);

      typeController.clear();
      priceController.clear();

      setState(() {
        selectedIndex = null;
      });

      await _loadRates();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Internal device rate deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to delete internal device: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (rates.isEmpty) {
      return Center(
        child: Text(AppTranslations.tr('No data'),
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: rates.length,
      itemBuilder: (
          context,
          index,
          ) {
        final item =
        rates[index];

        final selected =
            selectedIndex == index;

        return GestureDetector(
          onTap: () {
            _selectRow(index);
          },
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.blue
                  .withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      item['type']
                          ?.toString() ??
                          '',
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      item['price']
                          ?.toString() ??
                          '',
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(AppTranslations.tr('Internal Device'),
        ),
      ),

      body: loading
          ? Center(
        child:
        CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [
            // =================================================
            // LIST
            // =================================================

            Text(AppTranslations.tr('Internal Devices List'),
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            SizedBox(
              height: 8,
            ),

            SizedBox(
              height: 300,

              child: Container(
                decoration:
                BoxDecoration(
                  border:
                  Border.all(
                    color:
                    Colors.grey,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    8,
                  ),
                ),

                child: Column(
                  children: [
                    // =======================================
                    // HEADER
                    // =======================================

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

                      child:
                      Row(
                        children: [
                          Expanded(
                            child:
                            Center(
                              child:
                              Text(AppTranslations.tr('Type'),
                                style:
                                TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child:
                            Center(
                              child:
                              Text(AppTranslations.tr('Price'),
                                style:
                                TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =======================================
                    // DATA
                    // =======================================

                    Expanded(
                      child:
                      _buildTable(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 16,
            ),

            // =================================================
            // ADD NEW
            // =================================================

            Align(
              alignment:
              Alignment.centerLeft,

              child: SizedBox(
                height: 45,

                child:
                ElevatedButton(
                  onPressed:
                  _addNew,

                  child:
                  Text(AppTranslations.tr('Add New'),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            // =================================================
            // FORM
            // =================================================

            Container(
              padding:
              const EdgeInsets
                  .all(
                16,
              ),

              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color: Colors
                      .grey
                      .shade300,
                ),

                borderRadius:
                BorderRadius
                    .circular(
                  8,
                ),
              ),

              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    selectedIndex ==
                        null
                        ? 'New Device'
                        : 'Edit Device',

                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Text(AppTranslations.tr('Type'),
                    style:
                    TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    typeController,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Text(AppTranslations.tr('Price For Internal'),
                    style:
                    TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    priceController,

                    keyboardType:
                    TextInputType
                        .number,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Center(
                    child:
                    SizedBox(
                      width: 120,
                      height: 45,

                      child:
                      ElevatedButton(
                        onPressed:
                        saving
                            ? null
                            : _save,

                        child:
                        Text(
                          saving
                              ? 'Saving...'
                              : 'Save',
                        ),
                      ),
                    ),
                  ),

                  // Delete is not part of the
                  // Windows screenshot, so we don't
                  // add a visible Delete button here.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}