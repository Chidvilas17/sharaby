import 'package:flutter/material.dart';

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

  // Empty until the database/API is connected.
  final List<Map<String, String>> purchases = [];

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    receiptNumberController.dispose();
    discountController.dispose();
    discountDetailsController.dispose();
    super.dispose();
  }

  void _addPurchase() {
    final quantity = quantityController.text.trim();
    final unitPrice = unitPriceController.text.trim();
    final receiptNumber =
    receiptNumberController.text.trim();
    final discount = discountController.text.trim();

    if (quantity.isEmpty) {
      _showMessage('Please enter the quantity.');
      return;
    }

    if (double.tryParse(quantity) == null) {
      _showMessage('Please enter a valid quantity.');
      return;
    }

    if (unitPrice.isEmpty) {
      _showMessage('Please enter the unit price.');
      return;
    }

    if (double.tryParse(unitPrice) == null) {
      _showMessage('Please enter a valid unit price.');
      return;
    }

    if (receiptNumber.isEmpty) {
      _showMessage('Please enter the receipt number.');
      return;
    }

    if (discount.isEmpty) {
      _showMessage('Please enter the discount.');
      return;
    }

    if (double.tryParse(discount) == null) {
      _showMessage('Please enter a valid discount.');
      return;
    }

    // Database insertion will be connected later.
    _showMessage('Purchase information is valid.');
  }

  void _deletePurchase() {
    if (selectedRow == null) {
      _showMessage('Please select a purchase first.');
      return;
    }

    // Database deletion will be connected later.
    _showMessage(
      'Selected purchase is ready for deletion.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
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

  Widget _dataCell(
      int row,
      String text,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
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
          0: FixedColumnWidth(quantityWidth),
          1: FixedColumnWidth(unitPriceWidth),
          2: FixedColumnWidth(discountWidth),
          3: FixedColumnWidth(totalWidth),
          4: FixedColumnWidth(discountDetailsWidth),
          5: FixedColumnWidth(byWidth),
          6: FixedColumnWidth(receiptWidth),
          7: FixedColumnWidth(dateWidth),
        },
        children: [
          // Header
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

          // Empty Excel-style rows.
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
                      ? purchases[i]['discountDetails'] ?? ''
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
                      ? purchases[i]['receiptNumber'] ?? ''
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

  double _calculateTotal() {
    double total = 0;

    for (final purchase in purchases) {
      total +=
          double.tryParse(purchase['total'] ?? '') ?? 0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oxygen Intake'),
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

              const SizedBox(height: 16),

              // DELETE
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _deletePurchase,
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // TOTAL COST
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Cost: ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal()
                        .toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =================================
              // NEW PURCHASE
              // =================================

              _sectionTitle('New Purchase'),

              const SizedBox(height: 16),

              _textField(
                controller: quantityController,
                label: 'Quantity',
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 14),

              _textField(
                controller: unitPriceController,
                label: 'Unit Price',
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 14),

              _textField(
                controller: receiptNumberController,
                label: 'Receipt Number',
              ),

              const SizedBox(height: 14),

              _textField(
                controller: discountController,
                label: 'Discount',
                keyboardType:
                const TextInputType.numberWithOptions(
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
                  onPressed: _addPurchase,
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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