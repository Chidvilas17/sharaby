import 'package:flutter/material.dart';
import '../../services/hdan_devices_api_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController typeController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  List<Map<String, dynamic>> devices = [];

  bool loading = true;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    _loadDevices();
  }

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DEVICES
  // ============================================================

  Future<void> _loadDevices() async {
    try {
      final result =
      await HdanDevicesApiService.getDevices();

      if (!mounted) return;

      setState(() {
        devices = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load devices: $e',
      );
    }
  }

  // ============================================================
  // SAVE DEVICE
  // ============================================================

  Future<void> _saveDevice() async {
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
      await HdanDevicesApiService.addDevice(
        type: type,
        price: price,
      );

      typeController.clear();
      priceController.clear();

      await _loadDevices();

      if (!mounted) return;

      _showMessage(
        'Device added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save device: $e',
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
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hdan Devices'),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [

            // =========================
            // DEVICES LIST
            // =========================

            const Text(
              'Devices List',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 300,

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

                    // TABLE HEADER

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

                        border: Border(
                          bottom:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade400,
                          ),
                        ),
                      ),

                      child:
                      const Row(
                        children: [

                          Expanded(
                            child:
                            Text(
                              'Type',
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
                            Text(
                              'Price',
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

                    // TABLE DATA

                    Expanded(
                      child:
                      devices.isEmpty
                          ? const Center(
                        child:
                        Text(
                          'No data',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount:
                        devices.length,

                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final device =
                          devices[index];

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
                                    device['type']
                                        ?.toString() ??
                                        '',
                                  ),
                                ),

                                Expanded(
                                  child:
                                  Text(
                                    device['price']
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

            const SizedBox(height: 16),

            // =========================
            // ADD NEW BUTTON
            // =========================

            Align(
              alignment:
              Alignment.centerLeft,

              child: SizedBox(
                height: 45,

                child:
                ElevatedButton(
                  onPressed: () {
                    typeController.clear();
                    priceController.clear();

                    _showMessage(
                      'Enter the new device information below.',
                    );
                  },

                  child:
                  const Text(
                    'Add New',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // NEW DEVICE
            // =========================

            Container(
              padding:
              const EdgeInsets.all(16),

              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  Colors.grey.shade300,
                ),

                borderRadius:
                BorderRadius.circular(8),
              ),

              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  const Text(
                    'New Device',
                    style:
                    TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Type',
                    style:
                    TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    typeController,

                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Price For Hdan',
                    style:
                    TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                    priceController,

                    keyboardType:
                    TextInputType
                        .number,

                    decoration:
                    const InputDecoration(
                      border:
                      OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
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
                            : _saveDevice,

                        child:
                        Text(
                          saving
                              ? 'Saving...'
                              : 'Save',
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
    );
  }
}