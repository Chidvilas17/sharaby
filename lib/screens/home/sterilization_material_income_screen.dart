import 'package:flutter/material.dart';
import '../../services/sterilization_material_api_service.dart';

class SterilizationMaterialIncomeScreen extends StatefulWidget {
  const SterilizationMaterialIncomeScreen({super.key});

  @override
  State<SterilizationMaterialIncomeScreen> createState() =>
      _SterilizationMaterialIncomeScreenState();
}

class _SterilizationMaterialIncomeScreenState
    extends State<SterilizationMaterialIncomeScreen> {
  final TextEditingController quantityController =
  TextEditingController(text: '0');

  final TextEditingController receiptNumberController =
  TextEditingController();

  final TextEditingController discountController =
  TextEditingController(text: '0');

  final TextEditingController discountDetailsController =
  TextEditingController();

  String? selectedType;

  int? selectedRow;

  List<Map<String, dynamic>> materialTypes = [];

  List<Map<String, String>> purchases = [];

  // Keep the real database IDs separately.
  List<int> purchaseIds = [];

  bool loadingTypes = true;
  bool loadingPurchases = true;
  bool savingPurchase = false;
  bool deletingPurchase = false;

  @override
  void initState() {
    super.initState();

    _loadMaterialTypes();
    _loadPurchases();
  }

  // ============================================================
  // LOAD MATERIAL TYPES
  // ============================================================

  Future<void> _loadMaterialTypes() async {
    try {
      final result =
      await SterilizationMaterialApiService.getTypes();

      if (!mounted) return;

      setState(() {
        materialTypes = result;
        loadingTypes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingTypes = false;
      });

      _showMessage(
        'Failed to load material types.',
      );
    }
  }

  // ============================================================
  // LOAD PURCHASES FROM DATABASE
  // ============================================================

  Future<void> _loadPurchases() async {
    try {
      final result =
      await SterilizationMaterialApiService.getAll();

      if (!mounted) return;

      final List<Map<String, String>> loadedPurchases = [];
      final List<int> loadedIds = [];

      for (final item in result) {
        final id = int.tryParse(
          item['id']?.toString() ?? '',
        );

        if (id == null) {
          continue;
        }

        loadedIds.add(id);

        loadedPurchases.add({
          'quantity':
          item['count']?.toString() ?? '',
          'type':
          item['type']?.toString() ?? '',
          'unitPrice':
          item['unitPrice']?.toString() ?? '',
          'discount':
          item['discount']?.toString() ?? '',
          'total':
          item['total']?.toString() ?? '',
          'discountDetails':
          item['discountDetails']?.toString() ?? '',
          'by':
          item['logId']?.toString() ?? '',
          'receiptNumber':
          item['waslNo']?.toString() ?? '',
          'date':
          _formatDate(item['date']),
        });
      }

      setState(() {
        purchases = loadedPurchases;
        purchaseIds = loadedIds;
        loadingPurchases = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingPurchases = false;
      });

      _showMessage(
        'Failed to load purchases.',
      );
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final date = DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // ADD PURCHASE
  // ============================================================

  Future<void> _addPurchase() async {
    final quantityText =
    quantityController.text.trim();

    final receiptNumber =
    receiptNumberController.text.trim();

    final discountText =
    discountController.text.trim();

    final discountDetails =
    discountDetailsController.text.trim();

    if (quantityText.isEmpty) {
      _showMessage('Please enter the quantity.');
      return;
    }

    final parsedQuantity =
    int.tryParse(quantityText);

    if (parsedQuantity == null ||
        parsedQuantity <= 0) {
      _showMessage(
        'Please enter a valid quantity.',
      );
      return;
    }

    if (selectedType == null ||
        selectedType!.isEmpty) {
      _showMessage('Please select the type.');
      return;
    }

    if (receiptNumber.isEmpty) {
      _showMessage(
        'Please enter the receipt number.',
      );
      return;
    }

    if (discountText.isEmpty) {
      _showMessage(
        'Please enter the discount.',
      );
      return;
    }

    final parsedDiscount =
    int.tryParse(discountText);

    if (parsedDiscount == null ||
        parsedDiscount < 0) {
      _showMessage(
        'Please enter a valid discount.',
      );
      return;
    }

    if (savingPurchase) {
      return;
    }

    setState(() {
      savingPurchase = true;
    });

    try {
      await SterilizationMaterialApiService.add(
        count: parsedQuantity,
        type: selectedType!,
        waslNo: receiptNumber,
        discount: parsedDiscount,
        discountDetails:
        discountDetails.isEmpty
            ? null
            : discountDetails,
        userId: null,
        status: 'Test',
        date: DateTime.now(),
      );

      if (!mounted) return;

      // Read again from SQL Server.
      await _loadPurchases();

      if (!mounted) return;

      setState(() {
        quantityController.text = '0';
        receiptNumberController.clear();
        discountController.text = '0';
        discountDetailsController.clear();
        selectedType = null;
        selectedRow = null;
      });

      _showMessage(
        'Purchase added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save purchase: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          savingPurchase = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE PURCHASE
  // ============================================================

  Future<void> _deletePurchase() async {
    if (selectedRow == null) {
      _showMessage(
        'Please select a purchase first.',
      );
      return;
    }

    final row = selectedRow!;

    if (row >= purchaseIds.length) {
      _showMessage(
        'Please select an existing purchase.',
      );
      return;
    }

    final id = purchaseIds[row];

    if (deletingPurchase) {
      return;
    }

    setState(() {
      deletingPurchase = true;
    });

    try {
      await SterilizationMaterialApiService.delete(
        id,
      );

      if (!mounted) return;

      setState(() {
        selectedRow = null;
      });

      await _loadPurchases();

      if (!mounted) return;

      _showMessage(
        'Purchase deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete purchase: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          deletingPurchase = false;
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // TYPE DROPDOWN
  // ============================================================

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      items: materialTypes.map((item) {
        final type =
            item['type']?.toString() ?? '';

        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged:
      loadingTypes || materialTypes.isEmpty
          ? null
          : (value) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }

  // ============================================================
  // HEADER CELL
  // ============================================================

  Widget _headerCell(
      String text,
      double width,
      ) {
    return SizedBox(
      width: width,
      height: 52,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATA CELL
  // ============================================================

  Widget _dataCell(
      int row,
      String text,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        if (row >= purchases.length) {
          return;
        }

        setState(() {
          selectedRow = row;
        });
      },
      child: Container(
        width: width,
        height: 42,
        color: selectedRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    const int emptyRows = 12;

    const double quantityWidth = 90;
    const double typeWidth = 150;
    const double unitPriceWidth = 110;
    const double discountWidth = 90;
    const double totalWidth = 110;
    const double discountDetailsWidth = 180;
    const double byWidth = 120;
    const double receiptWidth = 150;
    const double dateWidth = 120;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          width: 1,
        ),
        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(quantityWidth),
          1: FixedColumnWidth(typeWidth),
          2: FixedColumnWidth(unitPriceWidth),
          3: FixedColumnWidth(discountWidth),
          4: FixedColumnWidth(totalWidth),
          5: FixedColumnWidth(
              discountDetailsWidth),
          6: FixedColumnWidth(byWidth),
          7: FixedColumnWidth(receiptWidth),
          8: FixedColumnWidth(dateWidth),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              _headerCell(
                'Quantity',
                quantityWidth,
              ),
              _headerCell(
                'Type',
                typeWidth,
              ),
              _headerCell(
                'Unit Price',
                unitPriceWidth,
              ),
              _headerCell(
                'Discount',
                discountWidth,
              ),
              _headerCell(
                'Total',
                totalWidth,
              ),
              _headerCell(
                'Discount Details',
                discountDetailsWidth,
              ),
              _headerCell(
                'By',
                byWidth,
              ),
              _headerCell(
                'Receipt Number',
                receiptWidth,
              ),
              _headerCell(
                'Date',
                dateWidth,
              ),
            ],
          ),

          for (int i = 0; i < emptyRows; i++)
            TableRow(
              children: [
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['quantity'] ?? ''
                      : '',
                  quantityWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['type'] ?? ''
                      : '',
                  typeWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['unitPrice'] ?? ''
                      : '',
                  unitPriceWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['discount'] ?? ''
                      : '',
                  discountWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['total'] ?? ''
                      : '',
                  totalWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['discountDetails'] ??
                      ''
                      : '',
                  discountDetailsWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['by'] ?? ''
                      : '',
                  byWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['receiptNumber'] ??
                      ''
                      : '',
                  receiptWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]['date'] ?? ''
                      : '',
                  dateWidth,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double _calculateTotal() {
    double total = 0;

    for (final purchase in purchases) {
      total +=
          double.tryParse(
            purchase['total'] ?? '',
          ) ??
              0;
    }

    return total;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sterilization Material',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==========================
              // PURCHASE TABLE
              // ==========================

              _sectionTitle(
                'Purchases Since Last Payment',
              ),

              _buildTable(),

              const SizedBox(height: 16),

              // Delete
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  deletingPurchase
                      ? null
                      : _deletePurchase,
                  child: Text(
                    deletingPurchase
                        ? 'Deleting...'
                        : 'Delete',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Cost: ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal()
                        .toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==========================
              // NEW PURCHASE
              // ==========================

              _sectionTitle(
                'New Purchase',
              ),

              const SizedBox(height: 16),

              _textField(
                controller:
                quantityController,
                label: 'Quantity',
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 14),

              _typeDropdown(),

              const SizedBox(height: 14),

              _textField(
                controller:
                receiptNumberController,
                label: 'Receipt Number',
              ),

              const SizedBox(height: 14),

              _textField(
                controller:
                discountController,
                label: 'Discount',
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 14),

              _textField(
                controller:
                discountDetailsController,
                label: 'Discount Details',
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  savingPurchase
                      ? null
                      : _addPurchase,
                  child: Text(
                    savingPurchase
                        ? 'Saving...'
                        : 'Add',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}