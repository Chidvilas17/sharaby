import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/oxygen_intake_api_service.dart';

class OxygenIntakeScreen extends StatefulWidget {
  const OxygenIntakeScreen({super.key});

  @override
  State<OxygenIntakeScreen> createState() =>
      _OxygenIntakeScreenState();
}

class _OxygenIntakeScreenState
    extends State<OxygenIntakeScreen> {
  final TextEditingController quantityController =
  TextEditingController(text: '0');

  final TextEditingController unitPriceController =
  TextEditingController(text: '0');

  final TextEditingController receiptNumberController =
  TextEditingController(text: '0');

  final TextEditingController discountController =
  TextEditingController(text: '0');

  final TextEditingController discountDetailsController =
  TextEditingController();

  int? selectedRow;

  List<Map<String, dynamic>> purchases = [];

  List<int> purchaseIds = [];

  bool loadingPurchases = true;
  bool savingPurchase = false;
  bool deletingPurchase = false;

  @override
  void initState() {
    super.initState();

    _loadPurchases();
  }

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    receiptNumberController.dispose();
    discountController.dispose();
    discountDetailsController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PURCHASES
  // ============================================================

  Future<void> _loadPurchases() async {
    try {
      final result =
      await OxygenIntakeApiService.getAll();

      if (!mounted) return;

      final List<int> ids = [];

      for (final item in result) {
        final id = int.tryParse(
          item['id']?.toString() ?? '',
        );

        if (id != null) {
          ids.add(id);
        }
      }

      setState(() {
        purchases = result;
        purchaseIds = ids;
        loadingPurchases = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingPurchases = false;
      });

      _showMessage(
        'Failed to load oxygen operations: $e',
      );
    }
  }

  // ============================================================
  // ADD PURCHASE
  // ============================================================

  Future<void> _addPurchase() async {
    final quantity =
    quantityController.text.trim();

    final unitPrice =
    unitPriceController.text.trim();

    final receiptNumber =
    receiptNumberController.text.trim();

    final discount =
    discountController.text.trim();

    final discountDetails =
    discountDetailsController.text.trim();

    if (quantity.isEmpty) {
      _showMessage(
        'Please enter the quantity.',
      );
      return;
    }

    final parsedQuantity =
    int.tryParse(quantity);

    if (parsedQuantity == null ||
        parsedQuantity <= 0) {
      _showMessage(
        'Please enter a valid quantity.',
      );
      return;
    }

    if (unitPrice.isEmpty) {
      _showMessage(
        'Please enter the unit price.',
      );
      return;
    }

    final parsedUnitPrice =
    int.tryParse(unitPrice);

    if (parsedUnitPrice == null ||
        parsedUnitPrice < 0) {
      _showMessage(
        'Please enter a valid unit price.',
      );
      return;
    }

    if (receiptNumber.isEmpty) {
      _showMessage(
        'Please enter the receipt number.',
      );
      return;
    }

    if (discount.isEmpty) {
      _showMessage(
        'Please enter the discount.',
      );
      return;
    }

    final parsedDiscount =
    int.tryParse(discount);

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
      await OxygenIntakeApiService.add(
        count: parsedQuantity,
        unitPrice: parsedUnitPrice,
        receiptNumber: receiptNumber,
        discount: parsedDiscount,
        discountDetails:
        discountDetails.isEmpty
            ? null
            : discountDetails,
        userId: null,
      );

      if (!mounted) return;

      await _loadPurchases();

      if (!mounted) return;

      setState(() {
        quantityController.text = '0';
        unitPriceController.text = '0';
        receiptNumberController.text = '0';
        discountController.text = '0';
        discountDetailsController.clear();
        selectedRow = null;
      });

      _showMessage(
        'Oxygen operation added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save oxygen operation: $e',
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

    if (row < 0 ||
        row >= purchaseIds.length) {
      _showMessage(
        'Invalid selected purchase.',
      );
      return;
    }

    if (deletingPurchase) {
      return;
    }

    final id = purchaseIds[row];

    setState(() {
      deletingPurchase = true;
    });

    try {
      await OxygenIntakeApiService.delete(id);

      if (!mounted) return;

      setState(() {
        selectedRow = null;
      });

      await _loadPurchases();

      if (!mounted) return;

      _showMessage(
        'Oxygen operation deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete oxygen operation: $e',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
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
    const int emptyRows = 10;

    const double quantityWidth = 90;
    const double unitPriceWidth = 110;
    const double discountWidth = 90;
    const double totalWidth = 110;
    const double discountDetailsWidth = 180;
    const double byWidth = 110;
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
          0: FixedColumnWidth(
            quantityWidth,
          ),
          1: FixedColumnWidth(
            unitPriceWidth,
          ),
          2: FixedColumnWidth(
            discountWidth,
          ),
          3: FixedColumnWidth(
            totalWidth,
          ),
          4: FixedColumnWidth(
            discountDetailsWidth,
          ),
          5: FixedColumnWidth(
            byWidth,
          ),
          6: FixedColumnWidth(
            receiptWidth,
          ),
          7: FixedColumnWidth(
            dateWidth,
          ),
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

          for (int i = 0;
          i < emptyRows;
          i++)
            TableRow(
              children: [
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['quantity']
                      ?.toString() ??
                      ''
                      : '',
                  quantityWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['unitPrice']
                      ?.toString() ??
                      ''
                      : '',
                  unitPriceWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['discount']
                      ?.toString() ??
                      ''
                      : '',
                  discountWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['total']
                      ?.toString() ??
                      ''
                      : '',
                  totalWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['discountDetails']
                      ?.toString() ??
                      ''
                      : '',
                  discountDetailsWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['by']
                      ?.toString() ??
                      ''
                      : '',
                  byWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? purchases[i]
                  ['receiptNumber']
                      ?.toString() ??
                      ''
                      : '',
                  receiptWidth,
                ),
                _dataCell(
                  i,
                  i < purchases.length
                      ? _formatDate(
                    purchases[i]['date'],
                  )
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
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final date =
    DateTime.tryParse(
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
  // TOTAL
  // ============================================================

  double _calculateTotal() {
    double total = 0;

    for (final purchase in purchases) {
      total +=
          double.tryParse(
            purchase['total']
                ?.toString() ??
                '',
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
        title: Text(AppTranslations.tr('Oxygen Intake'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // =================================
              // OPERATIONS SINCE LAST PURCHASE
              // =================================

              _sectionTitle(
                'Operations Since Last Purchase',
              ),

              _buildTable(),

              SizedBox(height: 16),

              // =================================
              // DELETE
              // =================================

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

              SizedBox(height: 16),

              // =================================
              // TOTAL COST
              // =================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.tr('Total Cost: '),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal()
                        .toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),

              // =================================
              // NEW PURCHASE
              // =================================

              _sectionTitle(
                'New Purchase',
              ),

              SizedBox(height: 16),

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

              SizedBox(height: 14),

              _textField(
                controller:
                unitPriceController,
                label: 'Unit Price',
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              SizedBox(height: 14),

              _textField(
                controller:
                receiptNumberController,
                label: 'Receipt Number',
              ),

              SizedBox(height: 14),

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

              SizedBox(height: 14),

              _textField(
                controller:
                discountDetailsController,
                label: 'Discount Details',
              ),

              SizedBox(height: 16),

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