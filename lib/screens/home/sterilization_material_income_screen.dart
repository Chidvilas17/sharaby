import 'package:flutter/material.dart';

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

  // Empty until database/API connection.
  final List<Map<String, String>> purchases = [];

  @override
  void dispose() {
    quantityController.dispose();
    receiptNumberController.dispose();
    discountController.dispose();
    discountDetailsController.dispose();
    super.dispose();
  }

  void _addPurchase() {
    final quantity = quantityController.text.trim();
    final receiptNumber = receiptNumberController.text.trim();
    final discount = discountController.text.trim();

    if (quantity.isEmpty) {
      _showMessage('Please enter the quantity.');
      return;
    }

    final parsedQuantity = double.tryParse(quantity);

    if (parsedQuantity == null) {
      _showMessage('Please enter a valid quantity.');
      return;
    }

    if (selectedType == null || selectedType!.isEmpty) {
      _showMessage('Please select the type.');
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

    final parsedDiscount = double.tryParse(discount);

    if (parsedDiscount == null) {
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
    _showMessage('Selected purchase is ready for deletion.');
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

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      items: const [
        // Real types will come from the database later.
      ],
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
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
            ? Theme.of(context).colorScheme.primaryContainer
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
          5: FixedColumnWidth(discountDetailsWidth),
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
              _headerCell('Quantity', quantityWidth),
              _headerCell('Type', typeWidth),
              _headerCell('Unit Price', unitPriceWidth),
              _headerCell('Discount', discountWidth),
              _headerCell('Total', totalWidth),
              _headerCell(
                'Discount Details',
                discountDetailsWidth,
              ),
              _headerCell('By', byWidth),
              _headerCell(
                'Receipt Number',
                receiptWidth,
              ),
              _headerCell('Date', dateWidth),
            ],
          ),

          // Empty rows.
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
      total += double.tryParse(
        purchase['total'] ?? '',
      ) ??
          0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sterilization Material'),
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

              // Total
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Cost: ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal()
                        .toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==========================
              // NEW PURCHASE
              // ==========================

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

              _typeDropdown(),

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
                controller: discountDetailsController,
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