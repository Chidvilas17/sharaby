import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/sterilization_material_accounts_api_service.dart';

class SterilizationMaterialAccountsScreen
    extends StatefulWidget {
  const SterilizationMaterialAccountsScreen({
    super.key,
  });

  @override
  State<SterilizationMaterialAccountsScreen>
  createState() =>
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

  // ============================================================
  // DATABASE DATA
  // ============================================================

  List<Map<String, dynamic>> payments = [];

  List<Map<String, dynamic>> oldDetails = [];

  List<Map<String, dynamic>> purchasesSinceLastPayment =
  [];

  int? selectedPaymentId;

  int previousRemaining = 0;
  int purchasesTotal = 0;
  int totalAccount = 0;
  int cost = 0;

  bool loading = true;
  bool savingPayment = false;

  @override
  void initState() {
    super.initState();

    _loadAccount();
    _loadCost();
  }

  @override
  void dispose() {
    paymentAmountController.dispose();
    receiptNumberController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD EVERYTHING
  // ============================================================

  Future<void> _loadAccount() async {
    setState(() {
      loading = true;
    });

    try {
      final results = await Future.wait([
        SterilizationMaterialAccountsApiService
            .getPayments(),

        SterilizationMaterialAccountsApiService
            .getPurchasesSinceLastPayment(),

        SterilizationMaterialAccountsApiService
            .getSummary(),
      ]);

      if (!mounted) return;

      final loadedPayments =
      results[0] as List<Map<String, dynamic>>;

      final loadedPurchases =
      results[1] as List<Map<String, dynamic>>;

      final summary =
      results[2] as Map<String, dynamic>;

      setState(() {
        payments = loadedPayments;

        purchasesSinceLastPayment =
            loadedPurchases;

        previousRemaining =
            int.tryParse(
              summary['previousRemaining']
                  ?.toString() ??
                  '0',
            ) ??
                0;

        purchasesTotal =
            int.tryParse(
              summary['purchasesTotal']
                  ?.toString() ??
                  '0',
            ) ??
                0;

        totalAccount =
            int.tryParse(
              summary['totalAccount']
                  ?.toString() ??
                  '0',
            ) ??
                0;

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load account data: $e',
      );
    }
  }

  // ============================================================
  // LOAD DETAILS FOR PAYMENT
  // ============================================================

  Future<void> _loadDetails(int row) async {
    if (row < 0 || row >= payments.length) {
      return;
    }

    final id =
    int.tryParse(
      payments[row]['id']?.toString() ?? '',
    );

    if (id == null) {
      return;
    }

    try {
      final result =
      await SterilizationMaterialAccountsApiService
          .getPaymentDetails(id);

      if (!mounted) return;

      setState(() {
        selectedPaymentId = id;
        oldDetails = result;
        selectedOldAccountRow = row;
        selectedOldDetailsRow = null;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to load account details.',
      );
    }
  }

  // ============================================================
  // COST
  // ============================================================

  Future<void> _loadCost() async {
    try {
      final result =
      await SterilizationMaterialAccountsApiService
          .getCost(
        from: fromDate,
        to: toDate,
      );

      if (!mounted) return;

      setState(() {
        cost = result;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to load cost.',
      );
    }
  }

  // ============================================================
  // SAVE PAYMENT
  // ============================================================

  Future<void> _savePayment() async {
    final amountText =
    paymentAmountController.text.trim();

    final receipt =
    receiptNumberController.text.trim();

    if (amountText.isEmpty) {
      _showMessage(
        'Please enter the payment amount.',
      );
      return;
    }

    final amount =
    int.tryParse(amountText);

    if (amount == null || amount < 0) {
      _showMessage(
        'Please enter a valid payment amount.',
      );
      return;
    }

    if (receipt.isEmpty) {
      _showMessage(
        'Please enter the receipt number.',
      );
      return;
    }

    if (savingPayment) {
      return;
    }

    setState(() {
      savingPayment = true;
    });

    try {
      await SterilizationMaterialAccountsApiService
          .savePayment(
        paymentAmount: amount,
        receiptNumber: receipt,
        userId: null,
      );

      if (!mounted) return;

      paymentAmountController.clear();
      receiptNumberController.clear();

      await _loadAccount();

      if (!mounted) return;

      _showMessage(
        'Payment saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save payment: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          savingPayment = false;
        });
      }
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day-$month-$year';
  }

  String _formatNullableDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final parsed =
    DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return value.toString();
    }

    return _formatDate(parsed);
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDate(
      bool isFromDate) async {
    final DateTime initialDate =
    isFromDate ? fromDate : toDate;

    final DateTime? picked =
    await showDatePicker(
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

    await _loadCost();
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
  // DATE BOX
  // ============================================================

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
          borderRadius:
          BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
            ),
          ],
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

  // ============================================================
  // OLD ACCOUNT TABLE
  // ============================================================

  Widget _buildOldAccountTable() {
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
          for (int i = 0;
          i < widths.length;
          i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0;
              i < headers.length;
              i++)
                _headerCell(
                  headers[i],
                  widths[i],
                ),
            ],
          ),

          for (int row = 0;
          row < payments.length;
          row++)
            TableRow(
              children: [
                _paymentCell(
                  row,
                  payments[row]['amountDue'],
                  widths[0],
                ),
                _paymentCell(
                  row,
                  payments[row]['paid'],
                  widths[1],
                ),
                _paymentCell(
                  row,
                  payments[row]['remaining'],
                  widths[2],
                ),
                _paymentCell(
                  row,
                  _formatNullableDate(
                    payments[row]['fromDate'],
                  ),
                  widths[3],
                ),
                _paymentCell(
                  row,
                  _formatNullableDate(
                    payments[row]['toDate'],
                  ),
                  widths[4],
                ),
                _paymentCell(
                  row,
                  payments[row]['by'],
                  widths[5],
                ),
                _paymentCell(
                  row,
                  payments[row]['receiptNumber'],
                  widths[6],
                ),
              ],
            ),

          if (payments.isEmpty)
            TableRow(
              children: [
                for (final width in widths)
                  SizedBox(
                    width: width,
                    height: 38,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _paymentCell(
      int row,
      dynamic value,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        _loadDetails(row);
      },
      child: Container(
        width: width,
        height: 38,
        color: selectedOldAccountRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          value?.toString() ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS TABLE
  // ============================================================

  Widget _buildDetailsTable() {
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
          for (int i = 0;
          i < widths.length;
          i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0;
              i < headers.length;
              i++)
                _headerCell(
                  headers[i],
                  widths[i],
                ),
            ],
          ),

          for (int row = 0;
          row < oldDetails.length;
          row++)
            TableRow(
              children: [
                _detailCell(
                  row,
                  oldDetails[row]['quantity'],
                  widths[0],
                ),
                _detailCell(
                  row,
                  oldDetails[row]['type'],
                  widths[1],
                ),
                _detailCell(
                  row,
                  oldDetails[row]['unitPrice'],
                  widths[2],
                ),
                _detailCell(
                  row,
                  oldDetails[row]['discount'],
                  widths[3],
                ),
                _detailCell(
                  row,
                  oldDetails[row]['total'],
                  widths[4],
                ),
                _detailCell(
                  row,
                  oldDetails[row]
                  ['discountDetails'],
                  widths[5],
                ),
                _detailCell(
                  row,
                  oldDetails[row]['by'],
                  widths[6],
                ),
                _detailCell(
                  row,
                  oldDetails[row]
                  ['receiptNumber'],
                  widths[7],
                ),
                _detailCell(
                  row,
                  _formatNullableDate(
                    oldDetails[row]['date'],
                  ),
                  widths[8],
                ),
              ],
            ),

          if (oldDetails.isEmpty)
            TableRow(
              children: [
                for (final width in widths)
                  SizedBox(
                    width: width,
                    height: 38,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _detailCell(
      int row,
      dynamic value,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOldDetailsRow = row;
        });
      },
      child: Container(
        width: width,
        height: 38,
        color: selectedOldDetailsRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          value?.toString() ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // PURCHASE TABLE
  // ============================================================

  Widget _buildPurchaseTable() {
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
          for (int i = 0;
          i < widths.length;
          i++)
            i: FixedColumnWidth(widths[i]),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (int i = 0;
              i < headers.length;
              i++)
                _headerCell(
                  headers[i],
                  widths[i],
                ),
            ],
          ),

          for (int row = 0;
          row <
              purchasesSinceLastPayment.length;
          row++)
            TableRow(
              children: [
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['quantity'],
                  widths[0],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['type'],
                  widths[1],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['unitPrice'],
                  widths[2],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['discount'],
                  widths[3],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['total'],
                  widths[4],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['discountDetails'],
                  widths[5],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['by'],
                  widths[6],
                ),
                _purchaseCell(
                  row,
                  purchasesSinceLastPayment[row]
                  ['receiptNumber'],
                  widths[7],
                ),
                _purchaseCell(
                  row,
                  _formatNullableDate(
                    purchasesSinceLastPayment[row]
                    ['date'],
                  ),
                  widths[8],
                ),
              ],
            ),

          if (purchasesSinceLastPayment.isEmpty)
            TableRow(
              children: [
                for (final width in widths)
                  SizedBox(
                    width: width,
                    height: 38,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _purchaseCell(
      int row,
      dynamic value,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPurchaseRow = row;
        });
      },
      child: Container(
        width: width,
        height: 38,
        color: selectedPurchaseRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          value?.toString() ?? '',
          textAlign: TextAlign.center,
        ),
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
        title: Text(AppTranslations.tr('Sterilization Material Accounts'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Old Account'),

              _buildOldAccountTable(),

              SizedBox(height: 12),

              Center(
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(AppTranslations.tr('Old Account: '),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    Text(
                      previousRemaining
                          .toString(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28),

              _sectionTitle(
                'Old Account Details',
              ),

              _buildDetailsTable(),

              SizedBox(height: 28),

              _sectionTitle(
                'Purchases Since Last Payment',
              ),

              _buildPurchaseTable(),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.tr('Total Account: '),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalAccount.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              _textField(
                controller:
                paymentAmountController,
                label: 'Payment Amount',
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

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: savingPayment
                      ? null
                      : _savePayment,
                  child: Text(
                    savingPayment
                        ? 'Saving...'
                        : 'Save',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 28),

              _sectionTitle(
                'Cost Date Range',
              ),

              SizedBox(height: 14),

              _dateBox(
                date: fromDate,
                onTap: () =>
                    _pickDate(true),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(AppTranslations.tr('To'),
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              _dateBox(
                date: toDate,
                onTap: () =>
                    _pickDate(false),
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(AppTranslations.tr('Cost: '),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    cost.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
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