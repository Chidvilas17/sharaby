import 'package:flutter/material.dart';

class SterilizationMaterialAccountsScreen extends StatefulWidget {
  const SterilizationMaterialAccountsScreen({super.key});

  @override
  State<SterilizationMaterialAccountsScreen> createState() =>
      _SterilizationMaterialAccountsScreenState();
}

class _SterilizationMaterialAccountsScreenState
    extends State<SterilizationMaterialAccountsScreen> {
  final TextEditingController paymentAmountController =
  TextEditingController();

  final TextEditingController receiptNumberController =
  TextEditingController();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  int? selectedOldAccountRow;
  int? selectedOldDetailsRow;
  int? selectedPurchaseRow;

  @override
  void dispose() {
    paymentAmountController.dispose();
    receiptNumberController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _pickDate(bool isFromDate) async {
    final DateTime initialDate = isFromDate ? fromDate : toDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isFromDate) {
        fromDate = picked;
      } else {
        toDate = picked;
      }
    });
  }

  void _savePayment() {
    final amount = paymentAmountController.text.trim();
    final receipt = receiptNumberController.text.trim();

    if (amount.isEmpty) {
      _showMessage('Please enter the payment amount.');
      return;
    }

    if (double.tryParse(amount) == null) {
      _showMessage('Please enter a valid payment amount.');
      return;
    }

    if (receipt.isEmpty) {
      _showMessage('Please enter the receipt number.');
      return;
    }

    // Database save will be connected later.
    _showMessage('Payment information is valid.');
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

  Widget _dateBox({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
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
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _emptyCell(
      int row,
      double width,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 38,
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildOldAccountTable() {
    const rows = 8;

    const widths = [
      130.0,
      100.0,
      110.0,
      120.0,
      100.0,
      100.0,
      160.0,
    ];

    const headers = [
      'Amount Due',
      'Paid',
      'Remaining',
      'From Date',
      'To',
      'By',
      'Payment Receipt Number',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
        ),
        columnWidths: {
          for (int i = 0; i < widths.length; i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0; i < headers.length; i++)
                _headerCell(headers[i], widths[i]),
            ],
          ),
          for (int row = 0; row < rows; row++)
            TableRow(
              children: [
                for (int col = 0; col < headers.length; col++)
                  _emptyCell(
                    row,
                    widths[col],
                        () {
                      setState(() {
                        selectedOldAccountRow = row;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTable() {
    const rows = 8;

    const widths = [
      90.0,
      150.0,
      110.0,
      90.0,
      110.0,
      180.0,
      110.0,
      150.0,
      120.0,
    ];

    const headers = [
      'Quantity',
      'Type',
      'Unit Price',
      'Discount',
      'Total',
      'Discount Details',
      'By',
      'Receipt Number',
      'Date',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
        ),
        columnWidths: {
          for (int i = 0; i < widths.length; i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0; i < headers.length; i++)
                _headerCell(headers[i], widths[i]),
            ],
          ),
          for (int row = 0; row < rows; row++)
            TableRow(
              children: [
                for (int col = 0; col < headers.length; col++)
                  _emptyCell(
                    row,
                    widths[col],
                        () {
                      setState(() {
                        selectedOldDetailsRow = row;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTable() {
    const rows = 8;

    const widths = [
      90.0,
      150.0,
      110.0,
      90.0,
      110.0,
      180.0,
      110.0,
      150.0,
      120.0,
    ];

    const headers = [
      'Quantity',
      'Type',
      'Unit Price',
      'Discount',
      'Total',
      'Discount Details',
      'By',
      'Receipt Number',
      'Date',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
        ),
        columnWidths: {
          for (int i = 0; i < widths.length; i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0; i < headers.length; i++)
                _headerCell(headers[i], widths[i]),
            ],
          ),
          for (int row = 0; row < rows; row++)
            TableRow(
              children: [
                for (int col = 0; col < headers.length; col++)
                  _emptyCell(
                    row,
                    widths[col],
                        () {
                      setState(() {
                        selectedPurchaseRow = row;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sterilization Material Accounts',
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
              // OLD ACCOUNT
              // ==========================

              _sectionTitle('Old Account'),

              _buildOldAccountTable(),

              const SizedBox(height: 12),

              Center(
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Old Account: ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '00',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================
              // OLD ACCOUNT DETAILS
              // ==========================

              _sectionTitle(
                'Old Account Details',
              ),

              _buildDetailsTable(),

              const SizedBox(height: 28),

              // ==========================
              // PURCHASES SINCE LAST PAYMENT
              // ==========================

              _sectionTitle(
                'Purchases Since Last Payment',
              ),

              _buildPurchaseTable(),

              const SizedBox(height: 20),

              // ==========================
              // ACCOUNT TOTAL
              // ==========================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Account: ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================
              // PAYMENT
              // ==========================

              _textField(
                controller: paymentAmountController,
                label: 'Payment Amount',
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

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _savePayment,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==========================
              // COST DATE RANGE
              // ==========================

              _sectionTitle('Cost Date Range'),

              const SizedBox(height: 14),

              _dateBox(
                date: fromDate,
                onTap: () => _pickDate(true),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'To',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _dateBox(
                date: toDate,
                onTap: () => _pickDate(false),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Cost: ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '000',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}