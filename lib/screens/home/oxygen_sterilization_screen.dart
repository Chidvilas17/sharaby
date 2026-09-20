import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/oxygen_sterilization_api_service.dart';

class OxygenSterilizationScreen extends StatefulWidget {
  const OxygenSterilizationScreen({super.key});

  @override
  State<OxygenSterilizationScreen> createState() =>
      _OxygenSterilizationScreenState();
}

class _OxygenSterilizationScreenState
    extends State<OxygenSterilizationScreen> {
  final TextEditingController oxygenPriceController =
  TextEditingController();

  final TextEditingController materialTypeController =
  TextEditingController();

  final TextEditingController unitPriceController =
  TextEditingController();

  List<Map<String, dynamic>> materials = [];

  bool loading = true;

  bool savingOxygenPrice = false;

  bool savingMaterial = false;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    oxygenPriceController.dispose();
    materialTypeController.dispose();
    unitPriceController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    try {
      final oxygenPrice =
      await OxygenSterilizationApiService
          .getOxygenPrice();

      final materialData =
      await OxygenSterilizationApiService
          .getMaterials();

      if (!mounted) return;

      final price =
      oxygenPrice['price'];

      setState(() {
        if (price != null) {
          oxygenPriceController.text =
              price.toString();
        }

        materials = materialData;

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load data: $e',
      );
    }
  }

  // ============================================================
  // SAVE OXYGEN PRICE
  // ============================================================

  Future<void> _saveOxygenPrice() async {
    final text =
    oxygenPriceController.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'Please enter the oxygen cylinder price.',
      );
      return;
    }

    final price =
    int.tryParse(text);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid oxygen cylinder price.',
      );
      return;
    }

    if (savingOxygenPrice) {
      return;
    }

    setState(() {
      savingOxygenPrice = true;
    });

    try {
      await OxygenSterilizationApiService
          .saveOxygenPrice(price);

      if (!mounted) return;

      _showMessage(
        'Oxygen cylinder price saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save oxygen price: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          savingOxygenPrice = false;
        });
      }
    }
  }

  // ============================================================
  // ADD MATERIAL
  // ============================================================

  Future<void> _saveMaterial() async {
    final type =
    materialTypeController.text.trim();

    final priceText =
    unitPriceController.text.trim();

    if (type.isEmpty) {
      _showMessage(
        'Please enter the material type.',
      );
      return;
    }

    if (priceText.isEmpty) {
      _showMessage(
        'Please enter the unit price.',
      );
      return;
    }

    final price =
    int.tryParse(priceText);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid unit price.',
      );
      return;
    }

    if (savingMaterial) {
      return;
    }

    setState(() {
      savingMaterial = true;
    });

    try {
      await OxygenSterilizationApiService
          .addMaterial(
        type: type,
        price: price,
      );

      if (!mounted) return;

      materialTypeController.clear();

      unitPriceController.clear();

      await _loadMaterials();

      if (!mounted) return;

      _showMessage(
        'Sterilization material added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add sterilization material: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          savingMaterial = false;
        });
      }
    }
  }

  // ============================================================
  // LOAD MATERIALS
  // ============================================================

  Future<void> _loadMaterials() async {
    final result =
    await OxygenSterilizationApiService
        .getMaterials();

    if (!mounted) return;

    setState(() {
      materials = result;
    });
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
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
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
          Text(
            title,
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
          child,
        ],
      ),
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
        title: Text(AppTranslations.tr('Oxygen & Sterilization Data'),
        ),
      ),

      body: loading
          ? Center(
        child:
        CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [

            // ==========================================
            // OXYGEN CYLINDER PRICE
            // ==========================================

            _buildSection(
              title:
              'Oxygen Cylinder Price',

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

                children: [

                  Text(AppTranslations.tr('Price'),
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
                    oxygenPriceController,

                    keyboardType:
                    TextInputType
                        .number,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),

                      hintText: AppTranslations.tr('Enter oxygen cylinder price'),
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Center(
                    child:
                    SizedBox(
                      width: 120,
                      height: 45,

                      child:
                      ElevatedButton(
                        onPressed:
                        savingOxygenPrice
                            ? null
                            : _saveOxygenPrice,

                        child:
                        Text(
                          savingOxygenPrice
                              ? 'Saving...'
                              : 'Save',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 24,
            ),

            // ==========================================
            // ADD STERILIZATION MATERIAL
            // ==========================================

            _buildSection(
              title:
              'Add Sterilization Material',

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

                children: [

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
                    materialTypeController,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),

                      hintText: AppTranslations.tr('Enter material type'),
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Text(AppTranslations.tr('Unit Price'),
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
                    unitPriceController,

                    keyboardType:
                    TextInputType
                        .number,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(),

                      hintText: AppTranslations.tr('Enter unit price'),
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Center(
                    child:
                    SizedBox(
                      width: 120,
                      height: 45,

                      child:
                      ElevatedButton(
                        onPressed:
                        savingMaterial
                            ? null
                            : _saveMaterial,

                        child:
                        Text(
                          savingMaterial
                              ? 'Saving...'
                              : 'Save',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 24,
            ),

            // ==========================================
            // CURRENT STERILIZATION MATERIALS
            // ==========================================

            Text(AppTranslations.tr('Current Sterilization Materials'),

              style:
              TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            SizedBox(
              height: 8,
            ),

            SizedBox(
              height: 400,

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

                    // HEADER

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical:
                        12,
                        horizontal:
                        12,
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
                            Text(AppTranslations.tr('Type'),

                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child:
                            Text(AppTranslations.tr('Unit Price'),

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

                    // DATA

                    Expanded(
                      child:
                      materials.isEmpty
                          ? Center(
                        child:
                        Text(AppTranslations.tr('No data'),
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      )
                          : ListView
                          .builder(
                        itemCount:
                        materials.length,

                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final item =
                          materials[index];

                          return Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical:
                              10,
                              horizontal:
                              12,
                            ),

                            decoration:
                            BoxDecoration(
                              border:
                              Border(
                                bottom:
                                BorderSide(
                                  color:
                                  Colors.grey.shade300,
                                ),
                              ),
                            ),

                            child:
                            Row(
                              children: [

                                Expanded(
                                  child:
                                  Text(
                                    item['type']
                                        ?.toString() ??
                                        '',
                                  ),
                                ),

                                Expanded(
                                  child:
                                  Text(
                                    item['price']
                                        ?.toString() ??
                                        '',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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