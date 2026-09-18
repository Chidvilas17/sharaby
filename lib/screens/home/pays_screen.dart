import 'package:flutter/material.dart';

import '../../services/pays_api_service.dart';

class PaysScreen extends StatefulWidget {
  const PaysScreen({super.key});

  @override
  State<PaysScreen> createState() => _PaysScreenState();
}

class _PaysScreenState extends State<PaysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController searchController =
  TextEditingController();

  final TextEditingController typeController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  List<Map<String, dynamic>> payList = [];

  int? selectedPayId;
  String selectedVisible = 'false';

  bool loadingAll = true;
  bool loadingPay = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _loadAllPays();
  }

  @override
  void dispose() {
    _tabController.dispose();

    searchController.dispose();
    typeController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD ALL
  // ============================================================

  Future<void> _loadAllPays() async {
    if (!mounted) return;

    setState(() {
      loadingAll = true;
    });

    try {
      final data =
      await PaysApiService.getAll();

      if (!mounted) return;

      setState(() {
        payList = data;
        loadingAll = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAll = false;
      });

      _showMessage(
        'Failed to load pays: $e',
      );
    }
  }

  // ============================================================
  // LOAD BY PAY ID
  // ============================================================

  Future<void> _loadPay() async {
    final text =
    searchController.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'Please enter a Pay ID.',
      );
      return;
    }

    final id = int.tryParse(text);

    if (id == null) {
      _showMessage(
        'Please enter a valid Pay ID.',
      );
      return;
    }

    setState(() {
      loadingPay = true;
    });

    try {
      final data =
      await PaysApiService.getById(id);

      if (!mounted) return;

      setState(() {
        selectedPayId =
            int.tryParse(
              data['pay_id'].toString(),
            );

        typeController.text =
            data['type']?.toString() ?? '';

        priceController.text =
            data['pay_amount']
                ?.toString() ??
                '';

        selectedVisible =
            data['visible']?.toString() ??
                'false';

        loadingPay = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingPay = false;
        selectedPayId = null;
        typeController.clear();
        priceController.clear();
      });

      _showMessage(
        'Pay not found: $e',
      );
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _savePay() async {
    if (selectedPayId == null) {
      _showMessage(
        'Please load a Pay ID first.',
      );
      return;
    }

    final type =
    typeController.text.trim();

    final priceText =
    priceController.text.trim();

    if (type.isEmpty) {
      _showMessage(
        'Type cannot be empty.',
      );
      return;
    }

    final price =
    int.tryParse(priceText);

    if (price == null) {
      _showMessage(
        'Please enter a valid Price.',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await PaysApiService.updatePay(
        id: selectedPayId!,
        payAmount: price,
        type: type,
        visible: selectedVisible,
      );

      if (!mounted) return;

      await _loadAllPays();

      if (!mounted) return;

      _showMessage(
        'Pay saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save Pay: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
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
  // ALL TAB
  // ============================================================

  Widget _buildAllTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Container(
              padding:
              const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
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
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Pay ID',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Type',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // DATA
            // ======================================================

            Expanded(
              child: loadingAll
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : payList.isEmpty
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
                _loadAllPays,
                child:
                ListView.builder(
                  itemCount:
                  payList.length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final pay =
                    payList[index];

                    return Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration:
                      BoxDecoration(
                        border:
                        Border(
                          bottom:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child:
                            Text(
                              pay['pay_id']
                                  ?.toString() ??
                                  '',
                            ),
                          ),
                          Expanded(
                            child:
                            Text(
                              pay['type']
                                  ?.toString() ??
                                  '',
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child:
                            Text(
                              pay['pay_amount']
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
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT TAB
  // ============================================================

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),

          // ======================================================
          // SEARCH AREA
          // ======================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              const Text(
                'Search By Pay Id :',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                width: 20,
              ),

              Expanded(
                child: TextField(
                  controller:
                  searchController,
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    border:
                    OutlineInputBorder(),
                    hintText:
                    'Enter Pay ID',
                  ),
                ),
              ),

              const SizedBox(
                width: 20,
              ),

              SizedBox(
                width: 120,
                height: 45,
                child: ElevatedButton(
                  onPressed:
                  loadingPay
                      ? null
                      : _loadPay,
                  child: loadingPay
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Load',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 40,
          ),

          // ======================================================
          // EDIT FORM
          // ======================================================

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Column(
              children: [
                // ==================================================
                // TYPE
                // ==================================================

                Row(
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        'Type :',
                        style:
                        TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller:
                        typeController,
                        decoration:
                        const InputDecoration(
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // PRICE
                // ==================================================

                Row(
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        'Price :',
                        style:
                        TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller:
                        priceController,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        const InputDecoration(
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed:
                    saving
                        ? null
                        : _savePay,
                    child: saving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save',
                    ),
                  ),
                ),
              ],
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
        title: const Text(
          'Pays Details',
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller:
            _tabController,
            tabs: const [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Edit',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller:
              _tabController,
              children: [
                _buildAllTab(),
                _buildEditTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}