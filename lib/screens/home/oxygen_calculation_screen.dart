import 'package:flutter/material.dart';
import '../../services/oxygen_calculation_api_service.dart';

class OxygenCalculationScreen extends StatefulWidget {
  const OxygenCalculationScreen({super.key});

  @override
  State<OxygenCalculationScreen> createState() =>
      _OxygenCalculationScreenState();
}

class _OxygenCalculationScreenState
    extends State<OxygenCalculationScreen> {
  final TextEditingController paymentAmountController =
  TextEditingController();

  final TextEditingController receiptNumberController =
  TextEditingController();

  DateTime fromDate = DateTime.now();

  DateTime toDate = DateTime.now();

  int? selectedOldAccountRow;

  int? selectedOldDetailsRow;

  int? selectedPurchaseRow;

  List<Map<String, dynamic>> oldAccounts = [];

  List<Map<String, dynamic>> oldDetails = [];

  List<Map<String, dynamic>> purchases = [];

  int oldAccountTotal = 0;

  int totalAccount = 0;

  int cost = 0;

  bool loading = true;

  bool savingPayment = false;

  @override
  void initState() {
    super.initState();

    _loadAllData();
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

  Future<void> _loadAllData() async {
    try {
      final oldAccount =
      await OxygenCalculationApiService
          .getOldAccount();

      final purchasesData =
      await OxygenCalculationApiService
          .getPurchasesSinceLastPayment();

      final accountData =
      await OxygenCalculationApiService
          .getTotalAccount();

      if (!mounted) return;

      setState(() {
        oldAccounts = oldAccount;

        purchases = purchasesData;

        oldAccountTotal =
            int.tryParse(
              accountData['oldAccount']
                  ?.toString() ??
                  '0',
            ) ??
                0;

        totalAccount =
            int.tryParse(
              accountData['totalAccount']
                  ?.toString() ??
                  '0',
            ) ??
                0;

        loading = false;
      });

      await _loadCost();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load oxygen calculation data: $e',
      );
    }
  }

  // ============================================================
  // LOAD COST
  // ============================================================

  Future<void> _loadCost() async {
    try {
      final result =
      await OxygenCalculationApiService
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
        'Failed to load cost: $e',
      );
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDate(
      bool isFromDate,
      ) async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate:
      isFromDate
          ? fromDate
          : toDate,
      firstDate:
      DateTime(2000),
      lastDate:
      DateTime(2100),
    );

    if (picked == null) {
      return;
    }

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
  // SAVE PAYMENT
  // ============================================================

  Future<void> _savePayment() async {
    final amount =
    paymentAmountController.text.trim();

    final receipt =
    receiptNumberController.text.trim();

    if (amount.isEmpty) {
      _showMessage(
        'Please enter the payment amount.',
      );
      return;
    }

    final parsedAmount =
    int.tryParse(amount);

    if (parsedAmount == null) {
      _showMessage(
        'Please enter a valid payment amount.',
      );
      return;
    }

    if (parsedAmount < 0) {
      _showMessage(
        'Payment amount cannot be negative.',
      );
      return;
    }

    if (receipt.isEmpty) {
      _showMessage(
        'Please enter the receipt number.',
      );
      return;
    }

    if (toDate.isBefore(fromDate)) {
      _showMessage(
        'To date cannot be before from date.',
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
      await OxygenCalculationApiService
          .savePayment(
        paymentAmount:
        parsedAmount,
        receiptNumber:
        receipt,
        fromDate:
        fromDate,
        toDate:
        toDate,
        userId: null,
      );

      if (!mounted) return;

      paymentAmountController.clear();

      receiptNumberController.clear();

      selectedOldAccountRow = null;

      selectedOldDetailsRow = null;

      selectedPurchaseRow = null;

      await _loadAllData();

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
  // SELECT OLD ACCOUNT
  // ============================================================

  Future<void> _selectOldAccount(
      int row,
      ) async {
    if (row < 0 ||
        row >= oldAccounts.length) {
      return;
    }

    setState(() {
      selectedOldAccountRow = row;
    });

    final paymentId =
    int.tryParse(
      oldAccounts[row]['id']
          ?.toString() ??
          '',
    );

    if (paymentId == null) {
      return;
    }

    try {
      final details =
      await OxygenCalculationApiService
          .getOldAccountDetails(
        paymentId,
      );

      if (!mounted) return;

      setState(() {
        oldDetails = details;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to load old account details: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
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
  // FORMAT DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day
        .toString()
        .padLeft(2, '0');

    final month =
    date.month
        .toString()
        .padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day-$month-$year';
  }

  String _formatDateValue(
      dynamic value,
      ) {
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

    return _formatDate(date);
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        border: Border.all(
          color:
          Colors.grey.shade400,
        ),
      ),
      child: Text(
        title,
        style:
        const TextStyle(
          fontSize: 16,
          fontWeight:
          FontWeight.bold,
        ),
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
      alignment:
      Alignment.center,
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          fontSize: 13,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DATA CELL
  // ============================================================

  Widget _dataCell(
      int row,
      double width,
      String text,
      bool selected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 38,
        color: selected
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        alignment:
        Alignment.center,
        child: Text(
          text,
          textAlign:
          TextAlign.center,
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
      150.0,
    ];

    const headers = [
      'Amount Due',
      'Paid',
      'Remaining',
      'From Date',
      'To',
      'By',
      'Receipt Number',
    ];

    const emptyRows = 8;

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Table(
        border:
        TableBorder.all(
          color: Colors.grey,
        ),
        columnWidths: {
          for (
          int i = 0;
          i < widths.length;
          i++
          )
            i: FixedColumnWidth(
              widths[i],
            ),
        },
        children: [
          TableRow(
            decoration:
            BoxDecoration(
              color:
              Colors.grey.shade200,
            ),
            children: [
              for (
              int i = 0;
              i < headers.length;
              i++
              )
                _headerCell(
                  headers[i],
                  widths[i],
                ),
            ],
          ),

          for (
          int row = 0;
          row < emptyRows;
          row++
          )
            TableRow(
              children: [
                for (
                int col = 0;
                col < headers.length;
                col++
                )
                  _dataCell(
                    row,
                    widths[col],
                    row < oldAccounts.length
                        ? _oldAccountValue(
                      oldAccounts[row],
                      col,
                    )
                        : '',
                    selectedOldAccountRow ==
                        row,
                        () {
                      _selectOldAccount(
                        row,
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _oldAccountValue(
      Map<String, dynamic> item,
      int column,
      ) {
    switch (column) {
      case 0:
        return item['amountDue']
            ?.toString() ??
            '';

      case 1:
        return item['paid']
            ?.toString() ??
            '';

      case 2:
        return item['remaining']
            ?.toString() ??
            '';

      case 3:
        return _formatDateValue(
          item['fromDate'],
        );

      case 4:
        return _formatDateValue(
          item['toDate'],
        );

      case 5:
        return item['by']
            ?.toString() ??
            '';

      case 6:
        return item['receiptNumber']
            ?.toString() ??
            '';

      default:
        return '';
    }
  }

  // ============================================================
  // DETAILS TABLE
  // ============================================================

  Widget _buildDetailsTable({
    required bool purchaseTable,
  }) {
    const widths = [
      90.0,
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
      'Unit Price',
      'Discount',
      'Total',
      'Discount Details',
      'By',
      'Receipt Number',
      'Date',
    ];

    const emptyRows = 8;

    final data =
    purchaseTable
        ? purchases
        : oldDetails;

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Table(
        border:
        TableBorder.all(
          color: Colors.grey,
        ),
        columnWidths: {
          for (
          int i = 0;
          i < widths.length;
          i++
          )
            i: FixedColumnWidth(
              widths[i],
            ),
        },
        children: [
          TableRow(
            decoration:
            BoxDecoration(
              color:
              Colors.grey.shade200,
            ),
            children: [
              for (
              int i = 0;
              i < headers.length;
              i++
              )
                _headerCell(
                  headers[i],
                  widths[i],
                ),
            ],
          ),

          for (
          int row = 0;
          row < emptyRows;
          row++
          )
            TableRow(
              children: [
                for (
                int col = 0;
                col < headers.length;
                col++
                )
                  _dataCell(
                    row,
                    widths[col],
                    row < data.length
                        ? _purchaseValue(
                      data[row],
                      col,
                    )
                        : '',
                    purchaseTable
                        ? selectedPurchaseRow ==
                        row
                        : selectedOldDetailsRow ==
                        row,
                        () {
                      setState(() {
                        if (purchaseTable) {
                          selectedPurchaseRow =
                              row;
                        } else {
                          selectedOldDetailsRow =
                              row;
                        }
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _purchaseValue(
      Map<String, dynamic> item,
      int column,
      ) {
    switch (column) {
      case 0:
        return item['quantity']
            ?.toString() ??
            '';

      case 1:
        return item['unitPrice']
            ?.toString() ??
            '';

      case 2:
        return item['discount']
            ?.toString() ??
            '';

      case 3:
        return item['total']
            ?.toString() ??
            '';

      case 4:
        return item['discountDetails']
            ?.toString() ??
            '';

      case 5:
        return item['by']
            ?.toString() ??
            '';

      case 6:
        return item['receiptNumber']
            ?.toString() ??
            '';

      case 7:
        return _formatDateValue(
          item['date'],
        );

      default:
        return '';
    }
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
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration:
        BoxDecoration(
          border: Border.all(
            color:
            Colors.grey.shade400,
          ),
          borderRadius:
          BorderRadius.circular(
            4,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .calendar_today_outlined,
              size: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                _formatDate(date),
                style:
                const TextStyle(
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
    required TextEditingController
    controller,
    required String label,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
      keyboardType,
      decoration:
      InputDecoration(
        labelText: label,
        border:
        const OutlineInputBorder(),
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
        title: const Text(
          'Oxygen Calculation',
        ),
      ),
      body: SafeArea(
        child: loading
            ? const Center(
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

              // =================================
              // OLD ACCOUNT
              // =================================

              _sectionTitle(
                'Old Account',
              ),

              _buildOldAccountTable(),

              const SizedBox(
                height: 14,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Old Account: ',
                    style:
                    TextStyle(
                      color:
                      Colors.red,
                      fontSize:
                      17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                  Text(
                    oldAccountTotal
                        .toString(),
                    style:
                    const TextStyle(
                      color:
                      Colors.red,
                      fontSize:
                      20,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // =================================
              // OLD ACCOUNT DETAILS
              // =================================

              _sectionTitle(
                'Old Account Details',
              ),

              _buildDetailsTable(
                purchaseTable:
                false,
              ),

              const SizedBox(
                height: 28,
              ),

              // =================================
              // PURCHASES
              // =================================

              _sectionTitle(
                'Purchases Since Last Payment',
              ),

              _buildDetailsTable(
                purchaseTable:
                true,
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================
              // TOTAL ACCOUNT
              // =================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Total Account: ',
                    style:
                    TextStyle(
                      color:
                      Colors.blue,
                      fontSize:
                      17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                  Text(
                    totalAccount
                        .toString(),
                    style:
                    const TextStyle(
                      color:
                      Colors.red,
                      fontSize:
                      20,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================
              // PAYMENT AMOUNT
              // =================================

              _textField(
                controller:
                paymentAmountController,
                label:
                'Payment Amount',
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _textField(
                controller:
                receiptNumberController,
                label:
                'Receipt Number',
              ),

              const SizedBox(
                height: 14,
              ),

              SizedBox(
                height: 48,
                child:
                ElevatedButton(
                  onPressed:
                  savingPayment
                      ? null
                      : _savePayment,
                  child: Text(
                    savingPayment
                        ? 'Saving...'
                        : 'Save',
                    style:
                    const TextStyle(
                      fontSize:
                      16,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // =================================
              // COST DATE RANGE
              // =================================

              _sectionTitle(
                'Cost Date Range',
              ),

              const SizedBox(
                height: 14,
              ),

              _dateBox(
                date: fromDate,
                onTap: () =>
                    _pickDate(
                      true,
                    ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Center(
                child: Text(
                  'To',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _dateBox(
                date: toDate,
                onTap: () =>
                    _pickDate(
                      false,
                    ),
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Cost: ',
                    style:
                    TextStyle(
                      color:
                      Colors.red,
                      fontSize:
                      17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                  Text(
                    cost.toString(),
                    style:
                    const TextStyle(
                      color:
                      Colors.red,
                      fontSize:
                      20,
                      fontWeight:
                      FontWeight
                          .bold,
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