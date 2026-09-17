import 'package:flutter/material.dart';
import '../../services/other_income_api_service.dart';

class OtherIncomeScreen extends StatefulWidget {
  const OtherIncomeScreen({super.key});

  @override
  State<OtherIncomeScreen> createState() =>
      _OtherIncomeScreenState();
}

class _OtherIncomeScreenState
    extends State<OtherIncomeScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController typeController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  // ============================================================
  // DATE
  // ============================================================

  DateTime selectedDate = DateTime.now();

  // ============================================================
  // DATABASE DATA
  // ============================================================

  List<Map<String, dynamic>> incomeRecords = [];

  int? selectedRecordId;

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool loading = false;
  bool adding = false;
  bool deleting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadByDate();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();
    notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;
    });
  }

  // ============================================================
  // LOAD DATA BY DATE
  // ============================================================

  Future<void> _loadByDate() async {
    setState(() {
      loading = true;
      selectedRecordId = null;
    });

    try {
      final result =
      await OtherIncomeApiService.getByDate(
        selectedDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        incomeRecords = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        incomeRecords = [];
      });

      _message(
        'Failed to load data.\n$e',
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    await _loadByDate();
  }

  // ============================================================
  // ADD INCOME
  // ============================================================

  Future<void> _addIncome() async {
    FocusScope.of(context).unfocus();

    final type =
    typeController.text.trim();

    final priceText =
    priceController.text.trim();

    final notes =
    notesController.text.trim();

    // ------------------------------------------------------------
    // VALIDATE TYPE
    // ------------------------------------------------------------

    if (type.isEmpty) {
      _message(
        'Please enter the type.',
      );
      return;
    }

    // ------------------------------------------------------------
    // VALIDATE PRICE
    // ------------------------------------------------------------

    if (priceText.isEmpty) {
      _message(
        'Please enter the price.',
      );
      return;
    }

    final price =
    int.tryParse(priceText);

    if (price == null) {
      _message(
        'Price must be a whole number.',
      );
      return;
    }

    if (price < 0) {
      _message(
        'Price cannot be negative.',
      );
      return;
    }

    // ------------------------------------------------------------
    // START SAVING
    // ------------------------------------------------------------

    setState(() {
      adding = true;
    });

    try {
      final id =
      await OtherIncomeApiService.addIncome(
        type: type,
        price: price,
        date: selectedDate,
        userId: null,
        notes: notes.isEmpty
            ? null
            : notes,
      );

      if (!mounted) {
        return;
      }

      // ----------------------------------------------------------
      // CLEAR INPUTS
      // ----------------------------------------------------------

      typeController.clear();
      priceController.clear();
      notesController.clear();

      // ----------------------------------------------------------
      // RELOAD FROM DATABASE
      // ----------------------------------------------------------

      await _loadByDate();

      if (!mounted) {
        return;
      }

      setState(() {
        adding = false;
      });

      _message(
        'Income added successfully. ID: $id',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        adding = false;
      });

      _message(
        'Failed to save income.\n$e',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteIncome() async {
    if (selectedRecordId == null) {
      _message(
        'Please select an income record first.',
      );
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Income',
          ),
          content: const Text(
            'Are you sure you want to delete this income record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      deleting = true;
    });

    try {
      await OtherIncomeApiService.deleteIncome(
        selectedRecordId!,
      );

      if (!mounted) {
        return;
      }

      await _loadByDate();

      if (!mounted) {
        return;
      }

      setState(() {
        deleting = false;
        selectedRecordId = null;
      });

      _message(
        'Income deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        deleting = false;
      });

      _message(
        'Failed to delete income.\n$e',
      );
    }
  }

  // ============================================================
  // SELECT TABLE ROW
  // ============================================================

  void _selectRow(int index) {
    if (index < 0 ||
        index >= incomeRecords.length) {
      return;
    }

    final record =
    incomeRecords[index];

    final id =
    record['id'];

    int? parsedId;

    if (id is int) {
      parsedId = id;
    } else {
      parsedId = int.tryParse(
        id?.toString() ?? '',
      );
    }

    setState(() {
      selectedRecordId = parsedId;
    });
  }

  // ============================================================
  // TOTAL
  // ============================================================

  int _calculateTotal() {
    int total = 0;

    for (final record in incomeRecords) {
      final value =
      record['price'];

      if (value is num) {
        total += value.toInt();
      } else {
        total +=
            int.tryParse(
              value?.toString() ?? '',
            ) ??
                0;
      }
    }

    return total;
  }

  // ============================================================
  // RECORD ID
  // ============================================================

  int? _recordId(
      Map<String, dynamic> record,
      ) {
    final value =
    record['id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border:
        const OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // EMPTY TABLE CELL
  // ============================================================

  Widget _emptyCell() {
    return Container(
      height: 42,
      alignment:
      Alignment.center,
      child:
      const Text(''),
    );
  }

  // ============================================================
  // DATA TABLE CELL
  // ============================================================

  Widget _dataCell({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment:
        Alignment.center,
        padding:
        const EdgeInsets.all(5),
        color: selected
            ? Colors.blue
            .withOpacity(0.15)
            : Colors.transparent,
        child: Text(
          text,
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (loading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border:
        Border.all(
          color: Colors.grey,
        ),
      ),
      child:
      SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,
        child: Table(
          defaultColumnWidth:
          const FixedColumnWidth(
            145,
          ),
          border:
          TableBorder.all(
            color: Colors.black54,
            width: 0.7,
          ),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            TableRow(
              decoration:
              const BoxDecoration(
                color:
                Color(0xFF4D88B5),
              ),
              children: const [
                _HeaderCell(
                  'Type',
                ),
                _HeaderCell(
                  'Price',
                ),
                _HeaderCell(
                  'By',
                ),
                _HeaderCell(
                  'Notes',
                ),
              ],
            ),

            // ==================================================
            // EMPTY ROWS
            // ==================================================

            if (incomeRecords.isEmpty)
              ...List.generate(
                10,
                    (index) {
                  return TableRow(
                    children: [
                      _emptyCell(),
                      _emptyCell(),
                      _emptyCell(),
                      _emptyCell(),
                    ],
                  );
                },
              )

            // ==================================================
            // DATABASE ROWS
            // ==================================================

            else
              ...incomeRecords
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                  final index =
                      entry.key;

                  final record =
                      entry.value;

                  final isSelected =
                      selectedRecordId ==
                          _recordId(
                            record,
                          );

                  return TableRow(
                    children: [
                      // TYPE
                      _dataCell(
                        text:
                        record['type']
                            ?.toString() ??
                            '',
                        selected:
                        isSelected,
                        onTap: () {
                          _selectRow(
                            index,
                          );
                        },
                      ),

                      // PRICE
                      _dataCell(
                        text:
                        record['price']
                            ?.toString() ??
                            '0',
                        selected:
                        isSelected,
                        onTap: () {
                          _selectRow(
                            index,
                          );
                        },
                      ),

                      // BY
                      _dataCell(
                        text:
                        record['by']
                            ?.toString() ??
                            '',
                        selected:
                        isSelected,
                        onTap: () {
                          _selectRow(
                            index,
                          );
                        },
                      ),

                      // NOTES
                      _dataCell(
                        text:
                        record['notes']
                            ?.toString() ??
                            '',
                        selected:
                        isSelected,
                        onTap: () {
                          _selectRow(
                            index,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
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
        title:
        const Text(
          'Other Income',
        ),
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            16,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

            children: [
              // ==================================================
              // ADD SECTION
              // ==================================================

              const Text(
                'Add New Income',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // TYPE
              _textField(
                label: 'Type',
                controller:
                typeController,
              ),

              const SizedBox(
                height: 14,
              ),

              // PRICE
              _textField(
                label: 'Price',
                controller:
                priceController,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: false,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // NOTES
              _textField(
                label: 'Notes',
                controller:
                notesController,
                maxLines: 2,
              ),

              const SizedBox(
                height: 14,
              ),

              // ADD BUTTON
              SizedBox(
                height: 48,
                child:
                ElevatedButton.icon(
                  onPressed:
                  adding
                      ? null
                      : _addIncome,
                  icon: adding
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Icon(
                    Icons.add,
                  ),
                  label: Text(
                    adding
                        ? 'Saving...'
                        : 'Add',
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // SEARCH SECTION
              // ==================================================

              const Text(
                'Search by Date',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // DATE
              InkWell(
                onTap:
                _selectDate,
                child:
                InputDecorator(
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Date',
                    border:
                    OutlineInputBorder(),
                    suffixIcon:
                    Icon(
                      Icons
                          .calendar_month,
                    ),
                  ),
                  child: Text(
                    _formatDate(
                      selectedDate,
                    ),
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // SEARCH BUTTON
              SizedBox(
                height: 48,
                child:
                ElevatedButton.icon(
                  onPressed:
                  loading
                      ? null
                      : _search,
                  icon:
                  const Icon(
                    Icons.search,
                  ),
                  label:
                  const Text(
                    'Search',
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // NO DATA MESSAGE
              // ==================================================

              if (!loading &&
                  incomeRecords.isEmpty)
                const Padding(
                  padding:
                  EdgeInsets.all(
                    12,
                  ),
                  child: Text(
                    'No income for this date',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

              // ==================================================
              // TABLE
              // ==================================================

              _buildTable(),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // DELETE BUTTON
              // ==================================================

              SizedBox(
                height: 48,
                child:
                ElevatedButton.icon(
                  onPressed:
                  deleting ||
                      selectedRecordId ==
                          null
                      ? null
                      : _deleteIncome,
                  icon: deleting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .delete_outline,
                  ),
                  label: Text(
                    deleting
                        ? 'Deleting...'
                        : 'Delete',
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // TOTAL
              // ==================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Total:',
                    style:
                    TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  Text(
                    _calculateTotal()
                        .toString(),
                    style:
                    const TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// HEADER CELL
// ================================================================

class _HeaderCell
    extends StatelessWidget {
  final String text;

  const _HeaderCell(
      this.text,
      );

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 48,
      alignment:
      Alignment.center,
      padding:
      const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          color: Colors.white,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}