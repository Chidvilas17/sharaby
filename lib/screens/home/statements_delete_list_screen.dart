import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/tbl_archive_api_service.dart';

class StatementsDeleteListScreen extends StatefulWidget {
  const StatementsDeleteListScreen({super.key});

  @override
  State<StatementsDeleteListScreen> createState() =>
      _StatementsDeleteListScreenState();
}

class _StatementsDeleteListScreenState
    extends State<StatementsDeleteListScreen> {
  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  bool isLoading = false;
  bool isDeleting = false;

  List<Map<String, dynamic>> records = [];

  final List<String> headers = [
    'No.',
    'Name',
    'Type',
    'Date',
    'Time',
    'User',
  ];

  @override
  void initState() {
    super.initState();

    // Automatically load today's deleted records.
    _loadRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  String _formatDateValue(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      return _formatDate(date);
    } catch (_) {
      return value.toString();
    }
  }

  String _formatTimeValue(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      final hour =
      date.hour.toString().padLeft(2, '0');

      final minute =
      date.minute.toString().padLeft(2, '0');

      final second =
      date.second.toString().padLeft(2, '0');

      return '$hour:$minute:$second';
    } catch (_) {
      return value.toString();
    }
  }

  // =========================================================
  // LOAD RECORDS
  // =========================================================

  Future<void> _loadRecords() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        selectedRow = null;
      });
    }

    try {
      final result =
      await TblArchiveApiService.getArchive(
        date: selectedDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        records = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        records = [];
      });

      _showMessage(
        'Failed to load delete list.\n$e',
      );
    }
  }

  // =========================================================
  // SELECT DATE
  // =========================================================

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

    await _loadRecords();
  }

  // =========================================================
  // DELETE SELECTED RECORD
  // =========================================================

  Future<void> _deleteSelectedRow() async {
    if (selectedRow == null) {
      _showMessage(
        'Please select a row first.',
      );
      return;
    }

    final rowIndex = selectedRow!;

    if (rowIndex < 0 ||
        rowIndex >= records.length) {
      return;
    }

    final record = records[rowIndex];

    final delId = int.tryParse(
      record['delID']?.toString() ??
          record['DelID']?.toString() ??
          '',
    );

    if (delId == null) {
      _showMessage(
        'Invalid archive record ID.',
      );
      return;
    }

    final name =
        record['name']?.toString() ??
            record['Name']?.toString() ??
            '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTranslations.tr('Delete')),
          content: Text(
            name.isEmpty
                ? 'Are you sure you want to delete this record?'
                : 'Are you sure you want to delete "$name"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(AppTranslations.tr('Cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(AppTranslations.tr('Delete')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await TblArchiveApiService.deleteArchive(
        delId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isDeleting = false;
        selectedRow = null;

        records.removeAt(rowIndex);
      });

      _showMessage(
        'Record deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isDeleting = false;
      });

      _showMessage(
        'Failed to delete record.\n$e',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _headerCell(String text) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      color: const Color(0xFF4D88B5),
      child: Text(
        AppTranslations.tr(text),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // =========================================================
  // DATA CELL
  // =========================================================

  Widget _dataCell({
    required int rowIndex,
    required String text,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = rowIndex;
        });
      },
      child: Container(
        height: 42,
        alignment: Alignment.center,
        color: selectedRow == rowIndex
            ? Colors.blue.withValues(alpha: 0.20)
            : const Color(0xFFD3DFE9),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    const int minimumRows = 20;

    final rowCount =
    records.length < minimumRows
        ? minimumRows
        : records.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(140),
        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),
        children: [
          // HEADER
          TableRow(
            children: headers
                .map(_headerCell)
                .toList(),
          ),

          // DATA
          ...List.generate(
            rowCount,
                (index) {
              if (index >= records.length) {
                return TableRow(
                  children: [
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                    _dataCell(
                      rowIndex: index,
                      text: '',
                    ),
                  ],
                );
              }

              final record = records[index];

              final delId =
                  record['delID'] ??
                      record['DelID'] ??
                      '';

              final name =
                  record['name'] ??
                      record['Name'] ??
                      '';

              final type =
                  record['type'] ??
                      record['Type'] ??
                      '';

              final archiveDate =
                  record['archiveDate'] ??
                      record['ArchiveDate'] ??
                      record['date'] ??
                      record['Date'];

              final archiveTime =
                  record['archiveTime'] ??
                      record['ArchiveTime'] ??
                      record['time'] ??
                      record['Time'];

              final userName =
                  record['userName'] ??
                      record['UserName'] ??
                      '';

              return TableRow(
                children: [
                  _dataCell(
                    rowIndex: index,
                    text: delId.toString(),
                  ),
                  _dataCell(
                    rowIndex: index,
                    text: name.toString(),
                  ),
                  _dataCell(
                    rowIndex: index,
                    text: type.toString(),
                  ),
                  _dataCell(
                    rowIndex: index,
                    text: _formatDateValue(
                      archiveDate,
                    ),
                  ),
                  _dataCell(
                    rowIndex: index,
                    text: _formatTimeValue(
                      archiveTime,
                    ),
                  ),
                  _dataCell(
                    rowIndex: index,
                    text: userName.toString(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Delete List'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Text(AppTranslations.tr('Date'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              InkWell(
                onTap:
                isLoading || isDeleting
                    ? null
                    : _selectDate,
                child: InputDecorator(
                  decoration:
                  InputDecoration(
                    border:
                    OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.calendar_month,
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

              SizedBox(height: 24),

              Container(
                padding:
                const EdgeInsets.all(8),
                decoration:
                BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Text(AppTranslations.tr('Screening Data'),
                      textAlign:
                      TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    if (isLoading)
                      Padding(
                        padding:
                        EdgeInsets.all(30),
                        child:
                        Center(
                          child:
                          CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildTable(),
                  ],
                ),
              ),

              SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                  isLoading ||
                      isDeleting
                      ? null
                      : _deleteSelectedRow,
                  icon: isDeleting
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.delete_outline,
                  ),
                  label: Text(
                    isDeleting
                        ? 'Deleting...'
                        : 'Delete',
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