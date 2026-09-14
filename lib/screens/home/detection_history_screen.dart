import 'package:flutter/material.dart';

class DetectionHistoryScreen extends StatefulWidget {
  const DetectionHistoryScreen({super.key});

  @override
  State<DetectionHistoryScreen> createState() =>
      _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState
    extends State<DetectionHistoryScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _message;

  // This will be loaded from the API later.
  // Do NOT add sample patients here.
  final List<Map<String, String>> _patients = [];

  List<Map<String, String>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();

    // Initially there is no database data.
    _filteredPatients = List.from(_patients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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

  void _search() {
    final name = _searchController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _message = 'Enter Name to search';
        _filteredPatients = [];
      });
      return;
    }

    // API is not connected yet.
    // Once connected, this will be replaced with the API request.
    final results = _patients.where((patient) {
      final patientName =
      (patient['patientName'] ?? '').toLowerCase();

      return patientName.contains(name.toLowerCase());
    }).toList();

    setState(() {
      _filteredPatients = results;

      if (results.isEmpty) {
        _message = 'Not found';
      } else {
        _message = null;
      }
    });
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredPatients = List.from(_patients);
      _message = null;
    });
  }

  // ============================================================
  // DETAIL
  // ============================================================

  void _showDetail(Map<String, String> patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Patient Detail'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem(
                  'Patient Name',
                  patient['patientName'] ?? '',
                ),
                _detailItem(
                  'Age',
                  patient['age'] ?? '',
                ),
                _detailItem(
                  'Previous tt',
                  patient['previousTt'] ?? '',
                ),
                _detailItem(
                  'Investi',
                  patient['investi'] ?? '',
                ),
                _detailItem(
                  'Date',
                  patient['date'] ?? '',
                ),
                _detailItem(
                  'Type',
                  patient['type'] ?? '',
                ),
                _detailItem(
                  'C/O',
                  patient['co'] ?? '',
                ),
                _detailItem(
                  'Diagnosis',
                  patient['diagnosis'] ?? '',
                ),
                _detailItem(
                  'Treatment',
                  patient['treatment'] ?? '',
                ),
                _detailItem(
                  'By Doctor',
                  patient['byDoctor'] ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '-' : value,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Patient'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // SEARCH SECTION
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      'Search By Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Name
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        _search();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Patient Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(6),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        child: Text(
                          _formatDate(_selectedDate),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Search
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _search,
                        icon: const Icon(
                          Icons.search,
                        ),
                        label: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Clear
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.clear,
                        ),
                        label: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MESSAGE
              // ==================================================

              if (_message != null)
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red.shade300,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(
        12,
        18,
        12,
        12,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const Text(
            'Patient History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal scrolling only for the wide table.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1250,
              child: Column(
                children: [

                  // ============================================
                  // HEADER
                  // ============================================

                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      children: columns.asMap().entries.map(
                            (entry) {
                          return _HeaderCell(
                            title: entry.value,
                            flex: _columnFlex(entry.key),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  // ============================================
                  // DATA
                  // ============================================

                  if (_filteredPatients.isEmpty)
                    _buildEmptyRows(columns.length)
                  else
                    ..._filteredPatients.asMap().entries.map(
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

  Widget _buildEmptyRows(int columnCount) {
    return Column(
      children: List.generate(
        12,
            (index) {
          return Container(
            height: 38,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.shade300,
                ),
                right: BorderSide(
                  color: Colors.grey.shade300,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: List.generate(
                columnCount,
                    (columnIndex) {
                  return Expanded(
                    flex: _columnFlex(columnIndex),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade200,
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
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade300,
          ),
          right: BorderSide(
            color: Colors.grey.shade300,
          ),
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          ...values.asMap().entries.map(
                (entry) {
              return _DataCell(
                text: entry.value,
                flex: _columnFlex(entry.key),
              );
            },
          ),

          // Detail button
          Expanded(
            flex: _columnFlex(11),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () {
                  _showDetail(patient);
                },
                child: const Text(
                  'Detail',
                  style: TextStyle(
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

  int _columnFlex(int index) {
    switch (index) {
      case 0:
        return 1; // No.
      case 1:
        return 3; // Patient Name
      case 2:
        return 1; // Age
      case 3:
        return 2; // Previous tt
      case 4:
        return 2; // Investi
      case 5:
        return 2; // Date
      case 6:
        return 2; // Type
      case 7:
        return 2; // C/O
      case 8:
        return 3; // Diagnosis
      case 9:
        return 3; // Treatment
      case 10:
        return 2; // By Doctor
      case 11:
        return 2; // Detail
      default:
        return 2;
    }
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DATA CELL
// ================================================================

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;

  const _DataCell({
    required this.text,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}