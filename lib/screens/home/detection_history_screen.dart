import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/detection_history_api_service.dart';
import 'doctors_manage_screen.dart';

class DetectionHistoryScreen extends StatefulWidget {
  const DetectionHistoryScreen({super.key});

  @override
  State<DetectionHistoryScreen> createState() => _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState extends State<DetectionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  String? _message;

  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHistory() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await DetectionHistoryApiService.searchHistory(name: '');

      if (!mounted) return;

      setState(() {
        _patients = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _patients = [];
        _message = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    final name = _searchController.text.trim();

    if (name.isEmpty) {
      await _loadAllHistory();
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await DetectionHistoryApiService.searchHistory(name: name);

      if (!mounted) return;

      setState(() {
        _patients = result;
        if (result.isEmpty) {
          _message = 'Not found';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _patients = [];
        _message = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _clearSearch() async {
    _searchController.clear();
    await _loadAllHistory();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _openDetail(Map<String, dynamic> patient) async {
    final medId = _intValue(patient, 'medId') ?? _intValue(patient, 'MedId');

    if (medId == null || medId <= 0) {
      _showMessage('Medical record ID was not returned by the API.');
      return;
    }

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorsManageScreen(medId: medId),
      ),
    );

    if (changed == true && mounted) {
      await _search();
    }
  }

  Future<void> _showFullDetail(Map<String, dynamic> patient) async {
    final medId = _intValue(patient, 'medId') ?? _intValue(patient, 'MedId');

    if (medId == null || medId <= 0) {
      _showMessage('Medical record ID was not returned by the API.');
      return;
    }

    try {
      final detail = await DetectionHistoryApiService.getDetail(medId);

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(AppTranslations.tr('Patient Detail')),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailItem('Patient Name', _stringValue(detail, 'patientName')),
                    _detailItem('Age', _stringValue(detail, 'age')),
                    _detailItem('Previous tt', _stringValue(detail, 'previousTt')),
                    _detailItem('Investi', _stringValue(detail, 'investi')),
                    _detailItem('Date', _formatApiDate(_value(detail, 'recordDate'))),
                    _detailItem('Type', _stringValue(detail, 'typeName')),
                    _detailItem('C/O', _stringValue(detail, 'co')),
                    _detailItem('Diagnosis', _stringValue(detail, 'diagnosis')),
                    _detailItem('Treatment', _stringValue(detail, 'treatment')),
                    _detailItem('By Doctor', _stringValue(detail, 'byDoctor')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppTranslations.tr('Close')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _openDetail(detail);
                },
                child: Text(AppTranslations.tr('Open')),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  dynamic _value(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  String _stringValue(Map<String, dynamic>? map, String key) {
    final value = _value(map, key);
    return value == null ? '' : value.toString();
  }

  int? _intValue(Map<String, dynamic>? map, String key) {
    final value = _value(map, key);
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  String _formatApiDate(dynamic value) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString());
    return parsed == null ? value.toString() : _formatDate(parsed);
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text(value.trim().isEmpty ? '-' : value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Search Patient')),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadAllHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchSection(),
              SizedBox(height: 16),
              if (_message != null) _buildMessage(),
              _buildHistoryTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppTranslations.tr('Search By Name'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: AppTranslations.tr('Patient Name'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: AppTranslations.tr('Date'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(_formatDate(_selectedDate)),
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _search,
              icon: const Icon(Icons.search),
              label: Text(AppTranslations.tr('Search'), style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _loading ? null : _clearSearch,
              icon: const Icon(Icons.clear),
              label: Text(AppTranslations.tr('Clear'), style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _message!,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

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
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppTranslations.tr('Patient History'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          if (_loading)
            SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1250,
                child: Column(
                  children: [
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: columns.asMap().entries.map((entry) {
                          return _HeaderCell(
                            title: entry.value,
                            flex: _columnFlex(entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                    if (_patients.isEmpty)
                      _buildEmptyRows(columns.length)
                    else
                      ..._patients.asMap().entries.map(
                            (entry) => _buildPatientRow(
                          entry.key,
                          entry.value,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyRows(int count) {
    return Column(
      children: List.generate(
        12,
            (_) => Container(
          height: 38,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              right: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: List.generate(
              count,
                  (index) => Expanded(
                flex: _columnFlex(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientRow(int index, Map<String, dynamic> patient) {
    final values = [
      '${index + 1}',
      _stringValue(patient, 'patientName'),
      _stringValue(patient, 'age'),
      _stringValue(patient, 'previousTt'),
      _stringValue(patient, 'investi'),
      _formatApiDate(_value(patient, 'recordDate')),
      _stringValue(patient, 'typeName'),
      _stringValue(patient, 'co'),
      _stringValue(patient, 'diagnosis'),
      _stringValue(patient, 'treatment'),
      _stringValue(patient, 'byDoctor'),
    ];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          ...values.asMap().entries.map(
                (entry) => _DataCell(
              text: entry.value,
              flex: _columnFlex(entry.key),
            ),
          ),
          Expanded(
            flex: _columnFlex(11),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () => _showFullDetail(patient),
                child: Text(AppTranslations.tr('Detail'), style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _columnFlex(int index) {
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

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell({required this.title, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;

  const _DataCell({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
