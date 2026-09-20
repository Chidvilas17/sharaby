import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/statements_discover_api_service.dart';

class StatementsDiscoverScreen extends StatefulWidget {
  const StatementsDiscoverScreen({super.key});

  @override
  State<StatementsDiscoverScreen> createState() =>
      _StatementsDiscoverScreenState();
}

class _StatementsDiscoverScreenState
    extends State<StatementsDiscoverScreen> {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController childNameController =
  TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> allRows = [];

  List<Map<String, dynamic>> delayedBooking = [];
  List<Map<String, dynamic>> currentMorning = [];
  List<Map<String, dynamic>> morningPhone = [];
  List<Map<String, dynamic>> currentEvening = [];
  List<Map<String, dynamic>> eveningPhone = [];
  List<Map<String, dynamic>> comingDays = [];

  bool loading = false;
  int? selectedTable;
  int? selectedRow;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    childNameController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });

    try {
      final result =
      await StatementsDiscoverApiService.getData(
        name: childNameController.text,
      );

      if (!mounted) return;

      allRows = result;

      _classifyRows();

      setState(() {
        loading = false;
        selectedTable = null;
        selectedRow = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to load screening registrations.\n$e',
      );
    }
  }

  // ============================================================
  // CLASSIFY
  // ============================================================

  void _classifyRows() {
    delayedBooking = [];
    currentMorning = [];
    morningPhone = [];
    currentEvening = [];
    eveningPhone = [];
    comingDays = [];

    final today = DateTime.now();

    for (final row in allRows) {
      final bookDate =
      _parseDate(row['bookDate']);

      final bookingTime =
      _parseDate(row['bookingTime']);

      final bookPhone =
      _text(row['bookPhone']);

      final late =
      _text(row['late']);

      final lateNumber =
      row['lateNumber'];

      final isLate =
          late.isNotEmpty ||
              lateNumber != null;

      final isPhoneBooking =
          bookPhone.isNotEmpty;

      // --------------------------------------------------------
      // DELAYED
      // --------------------------------------------------------

      if (isLate) {
        delayedBooking.add(row);

        continue;
      }

      // --------------------------------------------------------
      // COMING DAYS
      // --------------------------------------------------------

      if (isPhoneBooking &&
          bookDate != null &&
          _dateOnly(bookDate)
              .isAfter(_dateOnly(today))) {
        comingDays.add(row);

        continue;
      }

      // --------------------------------------------------------
      // TODAY
      // --------------------------------------------------------

      final effectiveDate =
          bookDate ?? bookingTime;

      if (effectiveDate == null) {
        continue;
      }

      final isToday =
      _dateOnly(effectiveDate)
          .isAtSameMomentAs(
        _dateOnly(today),
      );

      if (!isToday) {
        continue;
      }

      // --------------------------------------------------------
      // PHONE BOOKINGS
      // --------------------------------------------------------

      if (isPhoneBooking) {
        if (effectiveDate.hour < 15) {
          morningPhone.add(row);
        } else {
          eveningPhone.add(row);
        }

        continue;
      }

      // --------------------------------------------------------
      // CURRENT BOOKINGS
      // --------------------------------------------------------

      if (effectiveDate.hour < 15) {
        currentMorning.add(row);
      } else {
        currentEvening.add(row);
      }
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteSelected() async {
    if (selectedTable == null ||
        selectedRow == null) {
      _showMessage(
        'Please select a row first.',
      );

      return;
    }

    final rows =
    _rowsForTable(selectedTable!);

    if (selectedRow! >= rows.length) {
      return;
    }

    final row = rows[selectedRow!];

    final medId =
    _toInt(row['medId']);

    if (medId == null) {
      _showMessage(
        'This row does not have a valid medical record ID.',
      );

      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTranslations.tr('Delete Record'),
          ),
          content: Text(AppTranslations.tr('Are you sure you want to delete this record?'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(AppTranslations.tr('Cancel'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(AppTranslations.tr('Delete'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await StatementsDiscoverApiService.delete(
        medId,
      );

      await _loadData();

      _showMessage(
        'Record deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to delete record.\n$e',
      );
    }
  }

  // ============================================================
  // ROWS FOR TABLE
  // ============================================================

  List<Map<String, dynamic>> _rowsForTable(
      int table,
      ) {
    switch (table) {
      case 0:
        return delayedBooking;

      case 1:
        return currentMorning;

      case 2:
        return morningPhone;

      case 3:
        return currentEvening;

      case 4:
        return eveningPhone;

      case 5:
        return comingDays;

      default:
        return [];
    }
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable({
    required int tableIndex,
    required String title,
    required List<String> columns,
    required List<Map<String, dynamic>> rows,
  }) {
    const double columnWidth = 115;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: Table(
              defaultColumnWidth:
              const FixedColumnWidth(
                columnWidth,
              ),
              border: TableBorder.all(
                color: Colors.black54,
                width: 0.7,
              ),
              children: [
                // HEADER
                TableRow(
                  decoration:
                  const BoxDecoration(
                    color: Color(
                      0xFF4D88B5,
                    ),
                  ),
                  children:
                  columns.map((column) {
                    return Container(
                      height: 48,
                      alignment:
                      Alignment.center,
                      padding:
                      const EdgeInsets.all(5),
                      child: Text(
                        column,
                        textAlign:
                        TextAlign.center,
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // DATA
                ...List.generate(
                  rows.length,
                      (rowIndex) {
                    final isSelected =
                        selectedTable ==
                            tableIndex &&
                            selectedRow ==
                                rowIndex;

                    final row =
                    rows[rowIndex];

                    return TableRow(
                      children:
                      List.generate(
                        columns.length,
                            (columnIndex) {
                          final column =
                          columns[
                          columnIndex];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTable =
                                    tableIndex;

                                selectedRow =
                                    rowIndex;
                              });
                            },
                            child:
                            Container(
                              height: 42,
                              alignment:
                              Alignment.center,
                              color: isSelected
                                  ? Colors
                                  .blue
                                  .withValues(
                                alpha: 0.12,
                              )
                                  : const Color(
                                0xFFD3DFE9,
                              ),
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                _cellValue(
                                  row,
                                  tableIndex,
                                  column,
                                  rowIndex,
                                ),
                                textAlign:
                                TextAlign.center,
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // EMPTY ROWS
                ...List.generate(
                  rows.isEmpty
                      ? 8
                      : (rows.length < 8
                      ? 8 - rows.length
                      : 0),
                      (index) {
                    return TableRow(
                      children:
                      columns.map(
                            (column) {
                          return Container(
                            height: 42,
                            color:
                            const Color(
                              0xFFD3DFE9,
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CELL VALUE
  // ============================================================

  String _cellValue(
      Map<String, dynamic> row,
      int tableIndex,
      String column,
      int rowIndex,
      ) {
    if (column == 'No.') {
      return '${rowIndex + 1}';
    }

    if (column == 'Name') {
      return _text(row['name']);
    }

    if (column == 'Booking') {
      return _text(
        row['bookingNumber'] ??
            row['number'],
      );
    }

    if (column == 'Type') {
      final value =
      row['type'];

      if (value == null) {
        return '';
      }

      return value.toString();
    }

    if (column == 'Attendance') {
      return _text(
        row['entry'],
      );
    }

    if (column == 'Arrival') {
      return _formatDateTime(
        row['timeOfIn'],
      );
    }

    if (column == 'Entry') {
      return _text(
        row['entry'],
      );
    }

    if (column == 'Delay') {
      return _text(
        row['late'],
      );
    }

    if (column == 'Confirmation') {
      return _text(
        row['bookPhone'],
      );
    }

    if (column == 'Date') {
      return _formatDateTime(
        row['bookDate'],
        dateOnly: true,
      );
    }

    if (column == 'Delete') {
      return 'Delete';
    }

    return '';
  }

  // ============================================================
  // UPDATE
  // ============================================================

  void _update() {
    FocusScope.of(context).unfocus();

    _loadData();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _text(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _formatDateTime(
      dynamic value, {
        bool dateOnly = false,
      }) {
    final date =
    _parseDate(value);

    if (date == null) {
      return '';
    }

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final year =
    date.year.toString();

    if (dateOnly) {
      return '$day-$month-$year';
    }

    final hour =
    date.hour.toString().padLeft(
      2,
      '0',
    );

    final minute =
    date.minute.toString().padLeft(
      2,
      '0',
    );

    return '$day-$month-$year $hour:$minute';
  }

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

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
        title: Text(AppTranslations.tr('Screening Registration'),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // SEARCH AREA
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                      childNameController,
                      textDirection:
                      TextDirection.rtl,
                      decoration:
                      InputDecoration(
                        labelText: AppTranslations.tr('Child Name'),
                        border:
                        OutlineInputBorder(),
                        prefixIcon:
                        Icon(
                          Icons
                              .person_search,
                        ),
                      ),
                      onSubmitted: (_) {
                        _loadData();
                      },
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  SizedBox(
                    height: 56,
                    child:
                    ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : _update,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label:
                      Text(AppTranslations.tr('Update'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (loading)
              const LinearProgressIndicator(),

            // ==================================================
            // TABLES
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    _buildTable(
                      tableIndex: 0,
                      title:
                      'Delayed Booking',
                      columns: [
                        'No.',
                        'Booking',
                        'Name',
                        'Type',
                        'Attendance',
                        'Delete',
                      ],
                      rows:
                      delayedBooking,
                    ),

                    _buildTable(
                      tableIndex: 1,
                      title:
                      'Current Morning Booking',
                      columns: [
                        'No.',
                        'Booking',
                        'Name',
                        'Type',
                        'Arrival',
                        'Entry',
                        'Delay',
                      ],
                      rows:
                      currentMorning,
                    ),

                    _buildTable(
                      tableIndex: 2,
                      title:
                      'Morning Phone Booking',
                      columns: [
                        'No.',
                        'Name',
                        'Type',
                        'Entry',
                        'Confirmation',
                      ],
                      rows:
                      morningPhone,
                    ),

                    _buildTable(
                      tableIndex: 3,
                      title:
                      'Current Evening Booking',
                      columns: [
                        'No.',
                        'Booking',
                        'Name',
                        'Type',
                        'Arrival',
                        'Entry',
                        'Delay',
                      ],
                      rows:
                      currentEvening,
                    ),

                    _buildTable(
                      tableIndex: 4,
                      title:
                      'Evening Phone Booking',
                      columns: [
                        'No.',
                        'Name',
                        'Type',
                        'Entry',
                        'Confirmation',
                      ],
                      rows:
                      eveningPhone,
                    ),

                    _buildTable(
                      tableIndex: 5,
                      title:
                      'Phone Booking for Coming Days',
                      columns: [
                        'No.',
                        'Name',
                        'Type',
                        'Date',
                        'Entry',
                      ],
                      rows:
                      comingDays,
                    ),

                    SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // DELETE BUTTON
      // ========================================================

      floatingActionButton:
      selectedTable == 0 &&
          selectedRow != null
          ? FloatingActionButton.extended(
        onPressed:
        loading
            ? null
            : _deleteSelected,
        icon: const Icon(
          Icons.delete,
        ),
        label:
        Text(AppTranslations.tr('Delete'),
        ),
      )
          : null,
    );
  }
}