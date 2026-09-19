import 'package:flutter/material.dart';
import '../../services/detection_new_api_service.dart';

class DetectionNewScreen extends StatefulWidget {
  const DetectionNewScreen({super.key});

  @override
  State<DetectionNewScreen> createState() => _DetectionNewScreenState();
}

class _DetectionNewScreenState extends State<DetectionNewScreen> {
  final TextEditingController _currentUserController =
  TextEditingController();

  final TextEditingController _time1Controller =
  TextEditingController();

  final TextEditingController _time2Controller =
  TextEditingController();

  String? _message;
  int? _selectedTableIndex;

  bool _isLoading = false;

  // ============================================================
  // DATABASE DATA
  // ============================================================

  final List<Map<String, String>> delayedBookings = [];
  final List<Map<String, String>> morningCurrentBookings = [];
  final List<Map<String, String>> eveningCurrentBookings = [];
  final List<Map<String, String>> morningPhoneBookings = [];
  final List<Map<String, String>> eveningPhoneBookings = [];

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  @override
  void dispose() {
    _currentUserController.dispose();
    _time1Controller.dispose();
    _time2Controller.dispose();
    super.dispose();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _message = 'Loading data...';
      _selectedTableIndex = null;
    });

    try {
      final data =
      await DetectionNewApiService.getDetectionData();

      if (!mounted) return;

      _fillTableData(data);

      setState(() {
        _message = 'Data loaded successfully.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = 'Failed to load data.\n$e';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // FILL DATA
  // ============================================================

  void _fillTableData(
      Map<String, dynamic> data,
      ) {
    delayedBookings.clear();
    morningCurrentBookings.clear();
    eveningCurrentBookings.clear();
    morningPhoneBookings.clear();
    eveningPhoneBookings.clear();

    // ----------------------------------------------------------
    // Current User
    // ----------------------------------------------------------

    final currentUser =
        data['currentUser']?.toString() ?? '';

    _currentUserController.text = currentUser;

    // ----------------------------------------------------------
    // Time 1
    // ----------------------------------------------------------

    final time1 =
        data['time1']?.toString() ?? '';

    _time1Controller.text = time1;

    // ----------------------------------------------------------
    // Time 2
    // ----------------------------------------------------------

    final time2 =
        data['time2']?.toString() ?? '';

    _time2Controller.text = time2;

    // ----------------------------------------------------------
    // Delayed Booking
    // ----------------------------------------------------------

    _addRows(
      data['delayedBookings'],
      delayedBookings,
      const [
        'No.',
        'Booking',
        'Name',
        'Time',
      ],
    );

    // ----------------------------------------------------------
    // Morning Current Booking
    // ----------------------------------------------------------

    _addRows(
      data['morningCurrentBookings'],
      morningCurrentBookings,
      const [
        'No.',
        'Booking',
        'Name',
        'Type',
        'Arrival',
        'Entry',
      ],
    );

    // ----------------------------------------------------------
    // Evening Current Booking
    // ----------------------------------------------------------

    _addRows(
      data['eveningCurrentBookings'],
      eveningCurrentBookings,
      const [
        'No.',
        'Booking',
        'Name',
        'Type',
        'Arrival',
        'Entry',
      ],
    );

    // ----------------------------------------------------------
    // Morning Phone Booking
    // ----------------------------------------------------------

    _addRows(
      data['morningPhoneBookings'],
      morningPhoneBookings,
      const [
        'No.',
        'Booking',
        'Name',
        'Booking Time',
        'Entry',
      ],
    );

    // ----------------------------------------------------------
    // Evening Phone Booking
    // ----------------------------------------------------------

    _addRows(
      data['eveningPhoneBookings'],
      eveningPhoneBookings,
      const [
        'No.',
        'Booking',
        'Name',
        'Booking Time',
        'Entry',
      ],
    );
  }

  // ============================================================
  // API ROW CONVERTER
  // ============================================================

  void _addRows(
      dynamic apiRows,
      List<Map<String, String>> target,
      List<String> columns,
      ) {
    if (apiRows is! List) {
      return;
    }

    for (final item in apiRows) {
      if (item is! Map) {
        continue;
      }

      final row =
      Map<String, dynamic>.from(item);

      final converted =
      <String, String>{};

      for (final column in columns) {
        switch (column) {
          case 'No.':
            converted[column] =
                _value(row['no']);
            break;

          case 'Booking':
            converted[column] =
                _value(row['booking']);
            break;

          case 'Name':
            converted[column] =
                _value(row['name']);
            break;

          case 'Time':
            converted[column] =
                _value(row['time']);
            break;

          case 'Type':
            converted[column] =
                _value(row['type']);
            break;

          case 'Arrival':
            converted[column] =
                _value(row['arrival']);
            break;

          case 'Entry':
            converted[column] =
                _value(row['entry']);
            break;

          case 'Booking Time':
            converted[column] =
                _value(row['bookingTime']);
            break;

          default:
            converted[column] = '';
        }
      }

      target.add(converted);
    }
  }

  // ============================================================
  // VALUE HELPER
  // ============================================================

  String _value(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    final currentUser =
    _currentUserController.text.trim();

    final time1 =
    _time1Controller.text.trim();

    final time2 =
    _time2Controller.text.trim();

    // ----------------------------------------------------------
    // Validation
    // ----------------------------------------------------------

    if (time1.isEmpty ||
        time2.isEmpty) {
      setState(() {
        _message =
        'Please enter Time 1 and Time 2.';
      });
      return;
    }

    final parsedTime1 =
    int.tryParse(time1);

    final parsedTime2 =
    int.tryParse(time2);

    if (parsedTime1 == null ||
        parsedTime2 == null) {
      setState(() {
        _message =
        'Time 1 and Time 2 must be numbers.';
      });
      return;
    }

    if (parsedTime1 < 0 ||
        parsedTime1 > 60 ||
        parsedTime2 < 0 ||
        parsedTime2 > 60) {
      setState(() {
        _message =
        'Time values must be between 0 and 60.';
      });
      return;
    }

    // ----------------------------------------------------------
    // Save
    // ----------------------------------------------------------

    setState(() {
      _isLoading = true;
      _message = 'Saving...';
    });

    try {
      await DetectionNewApiService.saveSettings(
        currentUser: currentUser,
        time1: parsedTime1,
        time2: parsedTime2,
      );

      if (!mounted) return;

      setState(() {
        _message =
        'Settings saved successfully.';
        _isLoading = false;
      });

      // --------------------------------------------------------
      // Reload from database after saving
      // --------------------------------------------------------

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _message =
        'Failed to save settings.\n$e';
      });
    }
  }

  // ============================================================
  // TABLE SELECTION
  // ============================================================

  void _selectTableRow(int index) {
    setState(() {
      _selectedTableIndex = index;
      _message =
      'Row ${index + 1} selected.';
    });
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detection - New',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // TOP CONTROLS
              // ==================================================

              _buildControlSection(),

              const SizedBox(height: 16),

              // ==================================================
              // MESSAGE
              // ==================================================

              if (_message != null) ...[
                Container(
                  padding:
                  const EdgeInsets.all(12),
                  decoration:
                  BoxDecoration(
                    border: Border.all(
                      color:
                      Colors.grey.shade400,
                    ),
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  child: Text(
                    _message!,
                    style:
                    const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ==================================================
              // LOADING
              // ==================================================

              if (_isLoading)
                const Padding(
                  padding:
                  EdgeInsets.only(
                    bottom: 16,
                  ),
                  child:
                  LinearProgressIndicator(),
                ),

              // ==================================================
              // 1. DELAYED BOOKING
              // ==================================================

              _buildTableSection(
                title:
                'Delayed Booking',
                columns: const [
                  'No.',
                  'Booking',
                  'Name',
                  'Time',
                ],
                rows:
                delayedBookings,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 2. CURRENT MORNING BOOKING
              // ==================================================

              _buildTableSection(
                title:
                'Current Morning Booking',
                columns: const [
                  'No.',
                  'Booking',
                  'Name',
                  'Type',
                  'Arrival',
                  'Entry',
                ],
                rows:
                morningCurrentBookings,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 3. CURRENT EVENING BOOKING
              // ==================================================

              _buildTableSection(
                title:
                'Current Evening Booking',
                columns: const [
                  'No.',
                  'Booking',
                  'Name',
                  'Type',
                  'Arrival',
                  'Entry',
                ],
                rows:
                eveningCurrentBookings,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 4. MORNING PHONE BOOKING
              // ==================================================

              _buildTableSection(
                title:
                'Morning Phone Booking',
                columns: const [
                  'No.',
                  'Booking',
                  'Name',
                  'Booking Time',
                  'Entry',
                ],
                rows:
                morningPhoneBookings,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 5. EVENING PHONE BOOKING
              // ==================================================

              _buildTableSection(
                title:
                'Evening Phone Booking',
                columns: const [
                  'No.',
                  'Booking',
                  'Name',
                  'Booking Time',
                  'Entry',
                ],
                rows:
                eveningPhoneBookings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTROL SECTION
  // ============================================================

  Widget _buildControlSection() {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500,
        ),
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [

          // -------------------------------
          // Current User
          // -------------------------------

          const Text(
            'Current User',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
            _currentUserController,
            decoration:
            const InputDecoration(
              border:
              OutlineInputBorder(),
              hintText:
              'Enter current user',
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------
          // Time 1
          // -------------------------------

          const Text(
            'Time 1',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
            _time1Controller,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              border:
              OutlineInputBorder(),
              hintText:
              'Enter Time 1',
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------
          // Time 2
          // -------------------------------

          const Text(
            'Time 2',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
            _time2Controller,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              border:
              OutlineInputBorder(),
              hintText:
              'Enter Time 2',
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------
          // Refresh
          // -------------------------------

          SizedBox(
            height: 48,
            child:
            OutlinedButton.icon(
              onPressed:
              _isLoading
                  ? null
                  : _refresh,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                _isLoading
                    ? 'Loading...'
                    : 'Refresh',
                style:
                const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------
          // Save
          // -------------------------------

          SizedBox(
            height: 48,
            child:
            ElevatedButton.icon(
              onPressed:
              _isLoading
                  ? null
                  : _save,
              icon: const Icon(
                Icons.save_outlined,
              ),
              label: const Text(
                'Save',
                style:
                TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE SECTION
  // ============================================================

  Widget _buildTableSection({
    required String title,
    required List<String> columns,
    required List<Map<String, String>> rows,
  }) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        18,
        12,
        12,
      ),
      decoration:
      BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500,
        ),
        borderRadius:
        BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [

          // Section title

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Table

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: SizedBox(
              width:
              _tableWidth(
                columns.length,
              ),
              child: Column(
                children: [

                  // -------------------------------
                  // TABLE HEADER
                  // -------------------------------

                  Container(
                    height: 50,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.grey.shade200,
                      border:
                      Border.all(
                        color:
                        Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      children:
                      columns
                          .asMap()
                          .entries
                          .map(
                            (entry) {
                          return _HeaderCell(
                            title:
                            entry.value,
                            flex:
                            _columnFlex(
                              entry.key,
                              columns.length,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  // -------------------------------
                  // TABLE DATA
                  // -------------------------------

                  if (rows.isEmpty)
                    _buildEmptyRows(
                      columns.length,
                    )
                  else
                    ...rows
                        .asMap()
                        .entries
                        .map(
                          (entry) {
                        return _buildDataRow(
                          index:
                          entry.key,
                          data:
                          entry.value,
                          columns:
                          columns,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY TABLE
  // ============================================================

  Widget _buildEmptyRows(
      int columnCount,
      ) {
    return Column(
      children: List.generate(
        8,
            (index) {
          return Container(
            height: 36,
            decoration:
            BoxDecoration(
              border: Border(
                left: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
                right: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
                bottom: BorderSide(
                  color:
                  Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children:
              List.generate(
                columnCount,
                    (columnIndex) {
                  return Expanded(
                    flex:
                    _columnFlex(
                      columnIndex,
                      columnCount,
                    ),
                    child:
                    Container(
                      decoration:
                      BoxDecoration(
                        border:
                        Border(
                          right:
                          BorderSide(
                            color: Colors
                                .grey
                                .shade200,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DATA ROW
  // ============================================================

  Widget _buildDataRow({
    required int index,
    required Map<String, String> data,
    required List<String> columns,
  }) {
    final selected =
        _selectedTableIndex ==
            index;

    return InkWell(
      onTap: () =>
          _selectTableRow(index),
      child: Container(
        height: 44,
        color: selected
            ? Colors.blue.withValues(
          alpha: 0.12,
        )
            : Colors.transparent,
        child: Row(
          children: columns
              .asMap()
              .entries
              .map(
                (entry) {
              final columnIndex =
                  entry.key;

              final columnName =
                  entry.value;

              return Expanded(
                flex:
                _columnFlex(
                  columnIndex,
                  columns.length,
                ),
                child: Container(
                  alignment:
                  Alignment.center,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    border:
                    Border(
                      right:
                      BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                      bottom:
                      BorderSide(
                        color: Colors
                            .grey
                            .shade200,
                      ),
                    ),
                  ),
                  child: Text(
                    data[columnName] ??
                        '',
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // COLUMN WIDTH
  // ============================================================

  int _columnFlex(
      int index,
      int totalColumns,
      ) {
    if (index == 0) {
      return 1;
    }

    return 2;
  }

  double _tableWidth(
      int columnCount,
      ) {
    if (columnCount <= 4) {
      return 600;
    }

    if (columnCount == 5) {
      return 700;
    }

    return 780;
  }
}

// ================================================================
// HEADER CELL
// ================================================================

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell({
    required this.title,
    required this.flex,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment:
        Alignment.center,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration:
        BoxDecoration(
          border:
          Border(
            right:
            BorderSide(
              color: Colors
                  .grey
                  .shade300,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign:
          TextAlign.center,
          style:
          const TextStyle(
            fontSize: 13,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}