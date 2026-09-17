import 'package:flutter/material.dart';
import '../../services/staff_discounts_api_service.dart';

class StaffDiscountsScreen extends StatefulWidget {
  const StaffDiscountsScreen({super.key});

  @override
  State<StaffDiscountsScreen> createState() =>
      _StaffDiscountsScreenState();
}

class _StaffDiscountsScreenState
    extends State<StaffDiscountsScreen> {

  // ============================================================
  // MONTH
  // ============================================================

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // ============================================================
  // TYPE
  // ============================================================

  String selectedType = 'Nurses';

  int? selectedRow;

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> employees = [];

  bool loadingData = false;

  // ============================================================
  // HEADERS
  // ============================================================

  final List<String> headers = [
    'Name',
    'Deductions',
    'Advances',
    'Bonuses',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // ============================================================
  // CATEGORY ID
  // ============================================================

  int _categoryId() {
    switch (selectedType) {
      case 'Accountants':
        return 2;

      case 'Laborers':
        return 4;

      case 'Nurses':
      default:
        return 3;
    }
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      loadingData = true;
      selectedRow = null;
    });

    try {
      final result =
      await StaffDiscountsApiService
          .getStaffDiscounts(
        category: _categoryId(),
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        employees = result;
        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
        employees = [];
      });

      _message(
        'Failed to load discounts.\n$e',
      );
    }
  }

  // ============================================================
  // SELECT MONTH
  // ============================================================

  Future<void> _selectMonth() async {
    int tempMonth = selectedMonth;
    int tempYear = selectedYear;

    final result =
    await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Select Month',
                textAlign:
                TextAlign.center,
              ),

              content: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  // MONTH
                  DropdownButtonFormField<int>(
                    initialValue:
                    tempMonth,

                    isExpanded: true,

                    decoration:
                    const InputDecoration(
                      labelText: 'Month',
                      border:
                      OutlineInputBorder(),
                    ),

                    items:
                    List.generate(
                      12,
                          (index) {
                        final month =
                            index + 1;

                        return DropdownMenuItem<
                            int>(
                          value: month,
                          child: Text(
                            month
                                .toString()
                                .padLeft(
                              2,
                              '0',
                            ),
                          ),
                        );
                      },
                    ),

                    onChanged:
                        (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        tempMonth =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // YEAR
                  DropdownButtonFormField<int>(
                    initialValue:
                    tempYear,

                    isExpanded: true,

                    decoration:
                    const InputDecoration(
                      labelText: 'Year',
                      border:
                      OutlineInputBorder(),
                    ),

                    items:
                    List.generate(
                      101,
                          (index) {
                        final year =
                            2000 + index;

                        return DropdownMenuItem<
                            int>(
                          value: year,
                          child: Text(
                            '$year',
                          ),
                        );
                      },
                    ),

                    onChanged:
                        (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        tempYear =
                            value;
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      DateTime(
                        tempYear,
                        tempMonth,
                      ),
                    );
                  },
                  child:
                  const Text(
                    'Select',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedMonth =
          result.month;

      selectedYear =
          result.year;

      selectedRow = null;
    });

    await _loadData();
  }

  // ============================================================
  // MONTH TEXT
  // ============================================================

  String _monthText() {
    return '${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
  }

  // ============================================================
  // CHANGE TYPE
  // ============================================================

  void _changeType(String type) {
    if (selectedType == type) {
      return;
    }

    setState(() {
      selectedType = type;
      selectedRow = null;
      employees = [];
    });

    _loadData();
  }

  // ============================================================
  // RADIO
  // ============================================================

  Widget _typeRadio(
      String title,
      ) {
    return InkWell(
      onTap: () {
        _changeType(title);
      },

      child: Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Radio<String>(
            value: title,

            groupValue:
            selectedType,

            onChanged:
                (value) {
              if (value == null) {
                return;
              }

              _changeType(value);
            },
          ),

          Text(
            title,
            style:
            const TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE CELL
  // ============================================================

  Widget _tableCell({
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
        const EdgeInsets.all(
          5,
        ),

        color: selected
            ? Colors.blue
            .withOpacity(0.12)
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
  // VALUE TEXT
  // ============================================================

  String _value(
      dynamic value,
      ) {
    if (value == null) {
      return '0';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value
            .toInt()
            .toString();
      }

      return value.toString();
    }

    return value.toString();
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (loadingData) {
      return const SizedBox(
        height: 300,

        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration:
      BoxDecoration(
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
            color:
            Colors.black54,
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
                Color(0xFFEFEFEF),
              ),

              children:
              headers.map(
                    (header) {
                  return Container(
                    height: 50,

                    alignment:
                    Alignment.center,

                    padding:
                    const EdgeInsets.all(
                      5,
                    ),

                    child: Text(
                      header,

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),

            // ==================================================
            // DATA
            // ==================================================

            if (employees.isEmpty)
              ...List.generate(
                18,
                    (index) {
                  final isSelected =
                      selectedRow ==
                          index;

                  return TableRow(
                    children: [
                      _tableCell(
                        text: '',
                        selected:
                        isSelected,
                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      _tableCell(
                        text: '',
                        selected:
                        isSelected,
                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      _tableCell(
                        text: '',
                        selected:
                        isSelected,
                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      _tableCell(
                        text: '',
                        selected:
                        isSelected,
                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),
                    ],
                  );
                },
              )
            else
              ...employees
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                  final index =
                      entry.key;

                  final employee =
                      entry.value;

                  final isSelected =
                      selectedRow ==
                          index;

                  return TableRow(
                    children: [
                      // NAME
                      _tableCell(
                        text:
                        employee[
                        'name']
                            ?.toString() ??
                            '',

                        selected:
                        isSelected,

                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      // DEDUCTIONS
                      _tableCell(
                        text:
                        _value(
                          employee[
                          'deductions'],
                        ),

                        selected:
                        isSelected,

                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      // ADVANCES
                      _tableCell(
                        text:
                        _value(
                          employee[
                          'advances'],
                        ),

                        selected:
                        isSelected,

                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
                        },
                      ),

                      // BONUSES
                      _tableCell(
                        text:
                        _value(
                          employee[
                          'bonuses'],
                        ),

                        selected:
                        isSelected,

                        onTap: () {
                          setState(() {
                            selectedRow =
                                index;
                          });
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
          'Discounts',
        ),
      ),

      body:
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
            // MONTH
            // ==================================================

            Row(
              children: [
                const Text(
                  'Month:',
                  style:
                  TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: InkWell(
                    onTap:
                    _selectMonth,

                    child:
                    InputDecorator(
                      decoration:
                      const InputDecoration(
                        border:
                        OutlineInputBorder(),

                        suffixIcon:
                        Icon(
                          Icons
                              .calendar_month,
                        ),
                      ),

                      child: Text(
                        _monthText(),

                        textAlign:
                        TextAlign
                            .center,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // TYPE SELECTION
            // ==================================================

            Wrap(
              alignment:
              WrapAlignment
                  .center,

              spacing: 10,

              runSpacing: 5,

              children: [
                _typeRadio(
                  'Nurses',
                ),

                _typeRadio(
                  'Accountants',
                ),

                _typeRadio(
                  'Laborers',
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // CURRENT SELECTION
            // ==================================================

            Text(
              '$selectedType - ${_monthText()}',

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // TABLE
            // ==================================================

            _buildTable(),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}