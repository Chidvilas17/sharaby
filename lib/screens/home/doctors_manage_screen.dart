import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/doctors_manage_api_service.dart';

class DoctorsManageScreen extends StatefulWidget {
  final int? medId;
  final int? patientId;

  const DoctorsManageScreen({
    super.key,
    this.medId,
    this.patientId,
  });

  @override
  State<DoctorsManageScreen> createState() => _DoctorsManageScreenState();
}

class _DoctorsManageScreenState extends State<DoctorsManageScreen> {
  int? medId;
  int? patientId;

  Map<String, dynamic>? patient;
  Map<String, dynamic>? medical;

  bool loading = true;
  bool saving = false;
  bool loadingHistory = false;
  String? message;

  final noteController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final temperatureController = TextEditingController();
  final hcController = TextEditingController();
  final coController = TextEditingController();
  final investigationController = TextEditingController();
  final previousTttController = TextEditingController();
  final diagnosisController = TextEditingController();
  final notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime dayOfRevision = DateTime.now();

  List<Map<String, dynamic>> types = [];
  List<Map<String, dynamic>> coItems = [];
  List<Map<String, dynamic>> diagnosisItems = [];
  List<Map<String, dynamic>> tttItems = [];
  List<Map<String, dynamic>> doseItems = [];

  int? selectedTypeId;
  String? selectedCo;
  String? selectedDiagnosis;
  String? selectedTtt;
  String? selectedDose;

  final List<_TttRow> tttRows = [];
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    medId = widget.medId;
    patientId = widget.patientId;
    _load();
  }

  @override
  void dispose() {
    noteController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    temperatureController.dispose();
    hcController.dispose();
    coController.dispose();
    investigationController.dispose();
    previousTttController.dispose();
    diagnosisController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        message = null;
      });
    }

    try {
      await _loadMasters();

      if (medId != null) {
        final result = await DoctorsManageApiService.getMedical(medId!);
        medical = _asMap(result['medical']);
        patient = _asMap(result['patient']);

        if (medical != null) {
          patientId = _intValue(medical, 'patiant_id') ??
              _intValue(medical, 'patientId') ??
              patientId;
          _fillMedical();
        }
      } else if (patientId != null) {
        patient = await DoctorsManageApiService.getPatient(patientId!);
      }

      if (patientId != null) {
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          message = e.toString();
        });
      }
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _loadMasters() async {
    final results = await Future.wait<List<Map<String, dynamic>>>([
      DoctorsManageApiService.getTypes(),
      DoctorsManageApiService.getCo(),
      DoctorsManageApiService.getDiagnosis(),
      DoctorsManageApiService.getTtt(),
      DoctorsManageApiService.getDose(),
    ]);

    types = results[0];
    coItems = results[1];
    diagnosisItems = results[2];
    tttItems = results[3];
    doseItems = results[4];
  }

  void _fillMedical() {
    final m = medical;
    if (m == null) return;

    ageController.text = _stringValue(m, 'age');
    weightController.text = _stringValue(m, 'weight');
    heightController.text = _stringValue(m, 'height');
    temperatureController.text = _stringValue(m, 'temp');
    hcController.text = _stringValue(m, 'HC');
    coController.text = _stringValue(m, 'c_o');
    investigationController.text = _stringValue(m, 'Medical_Tests');
    previousTttController.text = _stringValue(m, 'Previous_TTT');
    diagnosisController.text = _stringValue(m, 'Diagnosis');
    notesController.text = _stringValue(m, 'Notes');
    noteController.text = _stringValue(m, 'Notes');

    selectedTypeId = _intValue(m, 'Type');

    final dod = _dateValue(m, 'DOD');
    if (dod != null) selectedDate = dod;

    final revision = _dateValue(m, 'DOBack');
    if (revision != null) dayOfRevision = revision;

    tttRows.clear();
    final existing = _stringValue(m, 'New_TTT').trim();
    if (existing.isEmpty) return;

    for (final line in existing.split(RegExp(r'[\r\n]+'))) {
      final value = line.trim();
      if (value.isEmpty) continue;

      final parts = value.split('|');
      tttRows.add(
        _TttRow(
          treatment: parts.first.trim(),
          dose: parts.length > 1 ? parts.sublist(1).join('|').trim() : '',
        ),
      );
    }
  }

  Future<void> _pickDate({required bool revision}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: revision ? dayOfRevision : selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (revision) {
        dayOfRevision = picked;
      } else {
        selectedDate = picked;
      }
    });
  }

  Future<void> _addCo() async {
    final value = selectedCo?.trim() ?? '';
    if (value.isEmpty) {
      _showMessage('Select a C/O first.');
      return;
    }

    try {
      final result = await DoctorsManageApiService.addCo(value);
      final name = _stringValue(result, 'name').isEmpty
          ? value
          : _stringValue(result, 'name');

      setState(() {
        final old = coController.text.trim();
        coController.text = old.isEmpty ? name : '$old, $name';
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _addDiagnosis() async {
    final value = selectedDiagnosis?.trim() ?? '';
    if (value.isEmpty) {
      _showMessage('Select a diagnosis first.');
      return;
    }

    try {
      final result = await DoctorsManageApiService.addDiagnosis(value);
      final name = _stringValue(result, 'name').isEmpty
          ? value
          : _stringValue(result, 'name');

      setState(() {
        final old = diagnosisController.text.trim();
        diagnosisController.text = old.isEmpty ? name : '$old, $name';
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _addTttRow() {
    final treatment = selectedTtt?.trim() ?? '';
    if (treatment.isEmpty) {
      _showMessage('Select TTT first.');
      return;
    }

    setState(() {
      tttRows.add(
        _TttRow(
          treatment: treatment,
          dose: selectedDose?.trim() ?? '',
        ),
      );
      selectedTtt = null;
      selectedDose = null;
    });
  }

  void _deleteTttRow(int index) {
    if (index < 0 || index >= tttRows.length) return;
    setState(() => tttRows.removeAt(index));
  }

  String _serializeTtt() {
    return tttRows
        .map((row) {
      final treatment = row.treatment.trim();
      final dose = row.dose.trim();
      if (dose.isEmpty) return treatment;
      return '$treatment | $dose';
    })
        .where((value) => value.isNotEmpty)
        .join('\n');
  }

  Future<void> _save({bool recent = false}) async {
    if (patientId == null || patientId! <= 0) {
      _showMessage('Patient ID is missing.');
      return;
    }

    setState(() {
      saving = true;
      message = null;
    });

    try {
      final data = <String, dynamic>{
        'patientId': patientId,
        'typeId': selectedTypeId,
        'dod': selectedDate.toIso8601String(),
        'age': ageController.text.trim(),
        'weight': weightController.text.trim(),
        'height': heightController.text.trim(),
        'temperature': temperatureController.text.trim(),
        'previousTtt': previousTttController.text.trim(),
        'investigations': investigationController.text.trim(),
        'co': coController.text.trim(),
        'diagnosis': diagnosisController.text.trim(),
        'newTtt': _serializeTtt(),
        'dayOfRevision': dayOfRevision.toIso8601String(),
        'notes': notesController.text.trim().isEmpty
            ? noteController.text.trim()
            : notesController.text.trim(),
        'hc': hcController.text.trim(),
      };

      if (medId == null) {
        final newId = await DoctorsManageApiService.createMedical(data);
        medId = newId > 0 ? newId : null;
      } else {
        await DoctorsManageApiService.updateMedical(medId!, data);
      }

      if (medId != null) {
        final result = await DoctorsManageApiService.getMedical(medId!);
        medical = _asMap(result['medical']);
        patient = _asMap(result['patient']) ?? patient;
        await _loadHistory();
      }

      if (!mounted) return;
      setState(() {
        message = recent
            ? 'Medical record saved successfully.'
            : 'Medical record saved successfully.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => saving = false);
    }
  }

  Future<void> _deleteMedical() async {
    if (medId == null) {
      _showMessage('There is no saved medical record to delete.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppTranslations.tr('Delete Medical Record')),
        content: Text(AppTranslations.tr('Are you sure you want to delete this medical record?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppTranslations.tr('Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppTranslations.tr('Delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await DoctorsManageApiService.deleteMedical(medId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.tr('Medical record deleted.'))),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _loadHistory() async {
    if (patientId == null) return;

    if (mounted) {
      setState(() => loadingHistory = true);
    } else {
      loadingHistory = true;
    }

    try {
      history = await DoctorsManageApiService.getHistory(patientId!);
    } catch (e) {
      message = e.toString();
    } finally {
      loadingHistory = false;
    }

    if (mounted) setState(() {});
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  dynamic _findValue(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  String _stringValue(Map<String, dynamic>? map, String key) {
    final value = _findValue(map, key);
    return value == null ? '' : value.toString();
  }

  int? _intValue(Map<String, dynamic>? map, String key) {
    final value = _findValue(map, key);
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  DateTime? _dateValue(Map<String, dynamic>? map, String key) {
    final value = _findValue(map, key);
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _patientValue(List<String> keys) {
    for (final key in keys) {
      final value = _findValue(patient, key);
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  String _itemName(Map<String, dynamic> item) {
    final value = _findValue(item, 'name');
    return value?.toString() ?? '';
  }

  int? _itemId(Map<String, dynamic> item) {
    final value = _findValue(item, 'id');
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d-$m-${date.year}';
  }

  String _formatApiDate(dynamic value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value.toString());
    return date == null ? value.toString() : _formatDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Doctors Manage')),
        actions: [
          IconButton(
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPatientDetails(),
              SizedBox(height: 12),
              _buildNewMedical(),
              SizedBox(height: 12),
              _buildHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientDetails() {
    return _section(
      title: 'Patient Details',
      child: Column(
        children: [
          _infoRow('ID', patientId?.toString() ?? ''),
          _infoRow('Name', _patientValue(['Name', 'name'])),
          _infoRow('Address', _patientValue(['Address', 'address'])),
          _infoRow(
            'Date Of Birth',
            _patientValue([
              'DateOfBirth',
              'Date_Of_Birth',
              'date_of_birth',
              'DOB',
              'BirthDate',
              'dateOfBirth',
            ]),
          ),
          _infoRow(
            'Phone',
            _patientValue(['Phone', 'phone', 'Phone1', 'phone1']),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMedical() {
    return _section(
      title: 'New Medical',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field('Note', noteController, maxLines: 2),
          SizedBox(height: 10),
          _dateField('Date', selectedDate, () => _pickDate(revision: false)),
          SizedBox(height: 10),
          _dropdownInt(
            label: 'Type',
            value: selectedTypeId,
            items: types,
            onChanged: (value) => setState(() => selectedTypeId = value),
          ),
          SizedBox(height: 10),
          _infoRow('Added By', _stringValue(medical, 'user_id')),
          SizedBox(height: 10),
          _fieldRow([
            _field('Age', ageController),
            _field('Weight', weightController),
            _field('Height', heightController),
            _field('Temperature', temperatureController),
            _field('H.C.', hcController),
          ]),
          SizedBox(height: 10),
          _masterAddRow(
            label: 'C / O',
            items: coItems,
            value: selectedCo,
            onChanged: (value) => setState(() => selectedCo = value),
            onAdd: _addCo,
            controller: coController,
          ),
          SizedBox(height: 10),
          _field('Investigations', investigationController, maxLines: 2),
          SizedBox(height: 10),
          _field('Previous TTT', previousTttController, maxLines: 2),
          SizedBox(height: 10),
          _masterAddRow(
            label: 'Diagnosis',
            items: diagnosisItems,
            value: selectedDiagnosis,
            onChanged: (value) => setState(() => selectedDiagnosis = value),
            onAdd: _addDiagnosis,
            controller: diagnosisController,
          ),
          SizedBox(height: 10),
          _buildTttSection(),
          SizedBox(height: 10),
          _field('Notes', notesController, maxLines: 3),
          SizedBox(height: 10),
          _dateField(
            'Day Of Revision',
            dayOfRevision,
                () => _pickDate(revision: true),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: saving ? null : () => _save(),
                  child: saving
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(AppTranslations.tr('Save')),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: saving ? null : () => _save(recent: true),
                  child: Text(AppTranslations.tr('Save Recent')),
                ),
              ),
              if (medId != null) ...[
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving ? null : _deleteMedical,
                    child: Text(AppTranslations.tr('Delete')),
                  ),
                ),
              ],
            ],
          ),
          if (message != null) ...[
            SizedBox(height: 10),
            Text(
              message!,
              style: TextStyle(
                color: message!.toLowerCase().contains('success')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldRow(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: fields
                .map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: field,
            ))
                .toList(),
          );
        }

        return Row(
          children: fields
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == fields.length - 1 ? 0 : 6,
                ),
                child: entry.value,
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _buildTttSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdownString(
                  label: 'TTT',
                  value: selectedTtt,
                  items: tttItems,
                  onChanged: (value) => setState(() => selectedTtt = value),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _dropdownString(
                  label: 'Dose',
                  value: selectedDose,
                  items: doseItems,
                  onChanged: (value) => setState(() => selectedDose = value),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTttRow,
                child: Text(AppTranslations.tr('Add')),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
            ),
            child: Column(
              children: [
                Container(
                  height: 44,
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      _HeaderCell(title: 'TTT', flex: 3),
                      _HeaderCell(title: 'Dose', flex: 3),
                      _HeaderCell(title: 'Delete', flex: 1),
                    ],
                  ),
                ),
                if (tttRows.isEmpty)
                  SizedBox(
                    height: 80,
                    child: Center(child: Text(AppTranslations.tr('No TTT added'))),
                  )
                else
                  ...tttRows.asMap().entries.map(
                        (entry) => Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(entry.value.treatment),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(entry.value.dose),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () => _deleteTttRow(entry.key),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return _section(
      title: 'Medical History',
      child: loadingHistory
          ? SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 900,
          child: Column(
            children: [
              Container(
                height: 48,
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    _HeaderCell(title: 'Type', flex: 2),
                    _HeaderCell(title: 'Date', flex: 2),
                    _HeaderCell(title: 'W', flex: 1),
                    _HeaderCell(title: 'Investigation', flex: 3),
                    _HeaderCell(title: 'Diagnosis', flex: 3),
                    _HeaderCell(title: 'TTT', flex: 3),
                    _HeaderCell(title: 'By Dr', flex: 2),
                  ],
                ),
              ),
              if (history.isEmpty)
                _emptyHistoryRows()
              else
                ...history.map(_historyRow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHistoryRows() {
    return Column(
      children: List.generate(
        6,
            (_) => Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              right: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> row) {
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
          _DataCell(text: _stringValue(row, 'typeName'), flex: 2),
          _DataCell(text: _formatApiDate(_findValue(row, 'dod')), flex: 2),
          _DataCell(text: _stringValue(row, 'weight'), flex: 1),
          _DataCell(text: _stringValue(row, 'investigation'), flex: 3),
          _DataCell(text: _stringValue(row, 'diagnosis'), flex: 3),
          _DataCell(text: _stringValue(row, 'treatment'), flex: 3),
          _DataCell(text: _stringValue(row, 'byDoctor'), flex: 2),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'None' : value,
              style: TextStyle(color: value.isEmpty ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppTranslations.tr(label),
          border: const OutlineInputBorder(),
        ),
        child: Text(_formatDate(date)),
      ),
    );
  }

  Widget _dropdownInt({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
  }) {
    final ids = items.map(_itemId).whereType<int>().toSet();
    final validValue = value != null && ids.contains(value) ? value : null;

    return DropdownButtonFormField<int>(
      initialValue: validValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        final id = _itemId(item);
        if (id == null) return null;
        return DropdownMenuItem<int>(
          value: id,
          child: Text(_itemName(item)),
        );
      }).whereType<DropdownMenuItem<int>>().toList(),
      onChanged: onChanged,
    );
  }

  Widget _dropdownString({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final names = items.map(_itemName).where((v) => v.isNotEmpty).toSet();
    final validValue = value != null && names.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppTranslations.tr(label),
        border: const OutlineInputBorder(),
      ),
      items: names
          .map(
            (name) => DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _masterAddRow({
    required String label,
    required List<Map<String, dynamic>> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required VoidCallback onAdd,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dropdownString(
                label: label,
                value: value,
                items: items,
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              child: Text(AppTranslations.tr('Add')),
            ),
          ],
        ),
        SizedBox(height: 8),
        _field(label, controller, maxLines: 2),
      ],
    );
  }
}

class _TttRow {
  final String treatment;
  final String dose;

  _TttRow({required this.treatment, required this.dose});
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
