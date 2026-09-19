import 'package:flutter/material.dart';
import 'doctors_manage_screen.dart';
import '../../services/detection_history_api_service.dart';

class DetectionHistoryScreen extends StatefulWidget {
  const DetectionHistoryScreen({super.key});

  @override
  State<DetectionHistoryScreen> createState() =>
      _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState
    extends State<DetectionHistoryScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _searchController =
  TextEditingController();

  // ============================================================
  // DATE
  // ============================================================

  DateTime _selectedDate = DateTime.now();

  // ============================================================
  // STATE
  // ============================================================

  String? _message;

  bool _isLoading = false;

  // ============================================================
  // DATABASE DATA
  // ============================================================

  final List<Map<String, String>> _patients = [];

  List<Map<String, String>> _filteredPatients = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load ALL history when screen opens.
    _loadAllHistory();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ALL HISTORY
  // ============================================================

  Future<void> _loadAllHistory() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Loading history...';
      _filteredPatients = [];
    });

    try {
      final results =
      await DetectionHistoryApiService.searchHistory(
        name: '',
      );

      if (!mounted) {
        return;
      }

      final converted =
      results.map<Map<String, String>>(
            (patient) {
          return {
            'medId': _value(
              patient['medId'],
            ),
            'patientName': _value(
              patient['patientName'],
            ),
            'age': _value(
              patient['age'],
            ),
            'previousTt': _value(
              patient['previousTt'],
            ),
            'investi': _value(
              patient['investi'],
            ),
            'date': _formatApiDate(
              patient['recordDate'],
            ),
            'type': _value(
              patient['typeName'],
            ),
            'co': _value(
              patient['co'],
            ),
            'diagnosis': _value(
              patient['diagnosis'],
            ),
            'treatment': _value(
              patient['treatment'],
            ),
            'byDoctor': _value(
              patient['byDoctor'],
            ),
          };
        },
      ).toList();

      setState(() {
        _filteredPatients = converted;
        _isLoading = false;

        if (converted.isEmpty) {
          _message = 'No history records found.';
        } else {
          _message = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _filteredPatients = [];
        _message =
        'Failed to load data.\n$e';
      });
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      _message = null;
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    final name =
    _searchController.text.trim();

    // ==========================================================
    // EMPTY NAME = SHOW ALL
    // ==========================================================

    if (name.isEmpty) {
      await _loadAllHistory();
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Searching...';
      _filteredPatients = [];
    });

    try {
      final results =
      await DetectionHistoryApiService.searchHistory(
        name: name,
      );

      if (!mounted) {
        return;
      }

      final converted =
      results.map<Map<String, String>>(
            (patient) {
          return {
            'medId': _value(
              patient['medId'],
            ),
            'patientName': _value(
              patient['patientName'],
            ),
            'age': _value(
              patient['age'],
            ),
            'previousTt': _value(
              patient['previousTt'],
            ),
            'investi': _value(
              patient['investi'],
            ),
            'date': _formatApiDate(
              patient['recordDate'],
            ),
            'type': _value(
              patient['typeName'],
            ),
            'co': _value(
              patient['co'],
            ),
            'diagnosis': _value(
              patient['diagnosis'],
            ),
            'treatment': _value(
              patient['treatment'],
            ),
            'byDoctor': _value(
              patient['byDoctor'],
            ),
          };
        },
      ).toList();

      setState(() {
        _filteredPatients = converted;
        _isLoading = false;

        if (converted.isEmpty) {
          _message = 'No matching patient found.';
        } else {
          _message = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _filteredPatients = [];
        _message =
        'Failed to load data.\n$e';
      });
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> _clearSearch() async {
    _searchController.clear();

    await _loadAllHistory();
  }

  // ============================================================
  // DETAIL
  // ============================================================

  Future<void> _showDetail(
      Map<String, String> patient,
      ) async {
    final medId =
    int.tryParse(
      patient['medId'] ?? '',
    );

    if (medId == null) {
      _showLocalDetail(patient);
      return;
    }

    try {
      final detail =
      await DetectionHistoryApiService.getDetail(
        medId,
      );

      if (!mounted) {
        return;
      }

      final detailPatient =
      <String, String>{
        'patientName': _value(
          detail['patientName'],
        ),
        'age': _value(
          detail['age'],
        ),
        'previousTt': _value(
          detail['previousTt'],
        ),
        'investi': _value(
          detail['investi'],
        ),
        'date': _formatApiDate(
          detail['recordDate'],
        ),
        'type': _value(
          detail['typeName'],
        ),
        'co': _value(
          detail['co'],
        ),
        'diagnosis': _value(
          detail['diagnosis'],
        ),
        'treatment': _value(
          detail['treatment'],
        ),
        'byDoctor': _value(
          detail['byDoctor'],
        ),
      };

      _showLocalDetail(
        detailPatient,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message =
        'Failed to load detail.\n$e';
      });
    }
  }

  // ============================================================
  // DETAIL DIALOG
  // ============================================================

  void _showLocalDetail(
      Map<String, String> patient,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Patient Detail',
          ),

          content:
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                _detailItem(
                  'Patient Name',
                  patient['patientName'] ??
                      '',
                ),

                _detailItem(
                  'Age',
                  patient['age'] ??
                      '',
                ),

                _detailItem(
                  'Previous tt',
                  patient['previousTt'] ??
                      '',
                ),

                _detailItem(
                  'Investi',
                  patient['investi'] ??
                      '',
                ),

                _detailItem(
                  'Date',
                  patient['date'] ??
                      '',
                ),

                _detailItem(
                  'Type',
                  patient['type'] ??
                      '',
                ),

                _detailItem(
                  'C/O',
                  patient['co'] ??
                      '',
                ),

                _detailItem(
                  'Diagnosis',
                  patient['diagnosis'] ??
                      '',
                ),

                _detailItem(
                  'Treatment',
                  patient['treatment'] ??
                      '',
                ),

                _detailItem(
                  'By Doctor',
                  patient['byDoctor'] ??
                      '',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            label,
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            value.isEmpty
                ? '-'
                : value,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALUE
  // ============================================================

  String _value(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // API DATE
  // ============================================================

  String _formatApiDate(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final text =
    value.toString();

    if (text.isEmpty) {
      return '';
    }

    final parsed =
    DateTime.tryParse(text);

    if (parsed == null) {
      return text;
    }

    return _formatDate(
      parsed,
    );
  }

  // ============================================================
  // DATE FORMAT
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

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Patient',
        ),
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [

              // ==================================================
              // SEARCH SECTION
              // ==================================================

              Container(
                padding:
                const EdgeInsets.all(16),

                decoration:
                BoxDecoration(
                  border:
                  Border.all(
                    color:
                    Colors.grey.shade500,
                  ),
                  borderRadius:
                  BorderRadius.circular(6),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [

                    const Text(
                      'Search By Name',
                      style:
                      TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------------
                    // NAME
                    // ------------------------------------------------

                    TextField(
                      controller:
                      _searchController,

                      textInputAction:
                      TextInputAction.search,

                      onSubmitted:
                          (_) {
                        _search();
                      },

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Patient Name',
                        border:
                        OutlineInputBorder(),
                        prefixIcon:
                        Icon(
                          Icons.search,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------------
                    // DATE
                    // ------------------------------------------------

                    InkWell(
                      onTap:
                      _selectDate,

                      borderRadius:
                      BorderRadius.circular(
                        6,
                      ),

                      child:
                      InputDecorator(
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Date',
                          border:
                          OutlineInputBorder(),
                          prefixIcon:
                          Icon(
                            Icons
                                .calendar_today_outlined,
                          ),
                        ),

                        child:
                        Text(
                          _formatDate(
                            _selectedDate,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ------------------------------------------------
                    // SEARCH BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      height: 48,

                      child:
                      ElevatedButton.icon(
                        onPressed:
                        _isLoading
                            ? null
                            : _search,

                        icon:
                        const Icon(
                          Icons.search,
                        ),

                        label:
                        Text(
                          _isLoading
                              ? 'Searching...'
                              : 'Search',
                          style:
                          const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ------------------------------------------------
                    // CLEAR BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      height: 48,

                      child:
                      OutlinedButton.icon(
                        onPressed:
                        _isLoading
                            ? null
                            : _clearSearch,

                        icon:
                        const Icon(
                          Icons.clear,
                        ),

                        label:
                        const Text(
                          'Clear',
                          style:
                          TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // MESSAGE
              // ==================================================

              if (_message != null)
                Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 16,
                  ),

                  padding:
                  const EdgeInsets.all(12),

                  decoration:
                  BoxDecoration(
                    border:
                    Border.all(
                      color:
                      Colors.grey.shade400,
                    ),
                    borderRadius:
                    BorderRadius.circular(6),
                  ),

                  child:
                  Text(
                    _message!,
                    style:
                    const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),

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
              // HISTORY TABLE
              // ==================================================

              _buildHistoryTable(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HISTORY TABLE
  // ============================================================

  Widget _buildHistoryTable() {
    const columns = [
      'No.',
      'Patient Name',
      'Age',
      'Previous tt',
      'Investi',
      'Date',
      'Type',
      'C/O',
      'Diagnosis',
      'Treatment',
      'By Doctor',
      'Detail',
    ];

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
        border:
        Border.all(
          color:
          Colors.grey.shade500,
        ),
        borderRadius:
        BorderRadius.circular(6),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [

          const Text(
            'Patient History',
            style:
            TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,

            child: SizedBox(
              width: 1250,

              child: Column(
                children: [

                  // ==================================================
                  // TABLE HEADER
                  // ==================================================

                  Container(
                    height: 52,

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
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  // ==================================================
                  // TABLE DATA
                  // ==================================================

                  if (_filteredPatients
                      .isEmpty)
                    _buildEmptyRows(
                      columns.length,
                    )
                  else
                    ..._filteredPatients
                        .asMap()
                        .entries
                        .map(
                          (entry) {
                        return _buildPatientRow(
                          entry.key,
                          entry.value,
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
      children:
      List.generate(
        12,
            (index) {
          return Container(
            height: 38,

            decoration:
            BoxDecoration(
              border:
              Border(
                left:
                BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
                right:
                BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
                bottom:
                BorderSide(
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
                    ),
                    child:
                    Container(
                      decoration:
                      BoxDecoration(
                        border:
                        Border(
                          right:
                          BorderSide(
                            color:
                            Colors.grey.shade200,
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
  // PATIENT ROW
  // ============================================================

  Widget _buildPatientRow(
      int index,
      Map<String, String> patient,
      ) {
    final values = [
      '${index + 1}',
      patient['patientName'] ?? '',
      patient['age'] ?? '',
      patient['previousTt'] ?? '',
      patient['investi'] ?? '',
      patient['date'] ?? '',
      patient['type'] ?? '',
      patient['co'] ?? '',
      patient['diagnosis'] ?? '',
      patient['treatment'] ?? '',
      patient['byDoctor'] ?? '',
    ];

    return Container(
      height: 48,

      decoration:
      BoxDecoration(
        border:
        Border(
          left:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),
          right:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),
          bottom:
          BorderSide(
            color:
            Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        children: [

          // --------------------------------------------------------
          // DATA CELLS
          // --------------------------------------------------------

          ...values
              .asMap()
              .entries
              .map(
                (entry) {
              return _DataCell(
                text:
                entry.value,
                flex:
                _columnFlex(
                  entry.key,
                ),
              );
            },
          ),

          // --------------------------------------------------------
          // DETAIL
          // --------------------------------------------------------

          Expanded(
            flex:
            _columnFlex(11),

            child:
            Padding(
              padding:
              const EdgeInsets.all(
                4,
              ),

              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorsManageScreen(
                        patient: patient,
                      ),
                    ),
                  );
                },

                child:
                const Text(
                  'Detail',
                  style:
                  TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLUMN WIDTHS
  // ============================================================

  int _columnFlex(
      int index,
      ) {
    switch (index) {
      case 0:
        return 1;

      case 1:
        return 3;

      case 2:
        return 1;

      case 3:
        return 2;

      case 4:
        return 2;

      case 5:
        return 2;

      case 6:
        return 2;

      case 7:
        return 2;

      case 8:
        return 3;

      case 9:
        return 3;

      case 10:
        return 2;

      case 11:
        return 2;

      default:
        return 2;
    }
  }
}

// ================================================================
// HEADER CELL
// ================================================================

class _HeaderCell
    extends StatelessWidget {
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
              color:
              Colors.grey.shade300,
            ),
          ),
        ),

        child:
        Text(
          title,
          textAlign:
          TextAlign.center,

          style:
          const TextStyle(
            fontSize: 12,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DATA CELL
// ================================================================

class _DataCell
    extends StatelessWidget {
  final String text;
  final int flex;

  const _DataCell({
    required this.text,
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
          horizontal: 5,
        ),

        decoration:
        BoxDecoration(
          border:
          Border(
            right:
            BorderSide(
              color:
              Colors.grey.shade200,
            ),
          ),
        ),

        child:
        Text(
          text,
          textAlign:
          TextAlign.center,

          style:
          const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}