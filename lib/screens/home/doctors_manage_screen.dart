import 'package:flutter/material.dart';

class DoctorsManageScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const DoctorsManageScreen({
    super.key,
    this.patient,
  });

  @override
  State<DoctorsManageScreen> createState() =>
      _DoctorsManageScreenState();
}

class _DoctorsManageScreenState
    extends State<DoctorsManageScreen> {
  // ============================================================
  // PATIENT DETAILS
  // ============================================================

  late String _patientId;
  late String _patientName;
  late String _patientAddress;
  late String _patientDateOfBirth;
  late String _patientPhone;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _noteController =
  TextEditingController();

  final TextEditingController _weightController =
  TextEditingController();

  final TextEditingController _heightController =
  TextEditingController();

  final TextEditingController _temperatureController =
  TextEditingController();

  final TextEditingController _hcController =
  TextEditingController();

  final TextEditingController _coTextController =
  TextEditingController();

  final TextEditingController _investigationController =
  TextEditingController();

  final TextEditingController _previousTttController =
  TextEditingController();

  final TextEditingController _diagnosisTextController =
  TextEditingController();

  final TextEditingController _tttTextController =
  TextEditingController();

  final TextEditingController _notesController =
  TextEditingController();

  // ============================================================
  // DATE
  // ============================================================

  DateTime _medicalDate = DateTime.now();
  DateTime _revisionDate = DateTime.now();

  // ============================================================
  // DROPDOWNS
  // ============================================================

  String? _type;

  String? _co;

  String? _diagnosis;

  String? _ttt;

  String? _dose;

  // ============================================================
  // AGE
  // ============================================================

  String _age = '';

  // ============================================================
  // TTT TEMPORARY LIST
  //
  // UI ONLY FOR NOW.
  // DATABASE MAPPING WILL BE DONE LATER.
  // ============================================================

  final List<Map<String, String>> _tttItems = [];

  // ============================================================
  // MEDICAL HISTORY TEMPORARY LIST
  //
  // UI ONLY FOR NOW.
  // ============================================================

  final List<Map<String, String>> _medicalHistory = [];

  // ============================================================
  // OPTIONS
  //
  // These are only UI placeholders for now.
  // We will replace them with real database values later.
  // ============================================================

  final List<String> _typeOptions = [
    'كشف',
    'كشف جديد',
  ];

  final List<String> _coOptions = [
    'Cough',
    'Fever',
    'Vomiting',
    'Headache',
  ];

  final List<String> _diagnosisOptions = [
    'Diagnosis 1',
    'Diagnosis 2',
  ];

  final List<String> _tttOptions = [
    'Treatment 1',
    'Treatment 2',
  ];

  final List<String> _doseOptions = [
    '1',
    '2',
    '3',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final patient = widget.patient;

    _patientId =
        _value(patient?['id'] ?? patient?['medId']);

    _patientName =
        _value(patient?['patientName'] ?? patient?['name']);

    _patientAddress =
        _value(patient?['address']);

    _patientDateOfBirth =
        _value(patient?['dateOfBirth']);

    _patientPhone =
        _value(patient?['phone']);

    _age = _value(patient?['age']);
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _noteController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _temperatureController.dispose();
    _hcController.dispose();
    _coTextController.dispose();
    _investigationController.dispose();
    _previousTttController.dispose();
    _diagnosisTextController.dispose();
    _tttTextController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectMedicalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _medicalDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _medicalDate = picked;
    });
  }

  Future<void> _selectRevisionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _revisionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _revisionDate = picked;
    });
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day-$month-$year';
  }

  // ============================================================
  // TTT ADD
  // ============================================================

  void _addTtt() {
    final selectedTtt =
        _ttt ?? _tttTextController.text.trim();

    final selectedDose =
        _dose ?? '';

    if (selectedTtt.isEmpty) {
      return;
    }

    setState(() {
      _tttItems.add({
        'ttt': selectedTtt,
        'dose': selectedDose,
      });

      _ttt = null;
      _dose = null;
      _tttTextController.clear();
    });
  }

  // ============================================================
  // TTT DELETE
  // ============================================================

  void _deleteTtt(int index) {
    setState(() {
      _tttItems.removeAt(index);
    });
  }

  // ============================================================
  // SAVE NOTE
  //
  // UI ONLY FOR NOW.
  // ============================================================

  void _saveNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Note saved locally for now.',
        ),
      ),
    );
  }

  // ============================================================
  // SAVE MEDICAL
  //
  // DATABASE CONNECTION WILL BE ADDED LATER.
  // ============================================================

  void _saveMedical() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Medical record save will be connected later.',
        ),
      ),
    );
  }

  // ============================================================
  // SAVE RECENT
  // ============================================================

  void _saveRecent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Save Recent will be connected later.',
        ),
      ),
    );
  }

  // ============================================================
  // ADD C/O
  // ============================================================

  void _addCo() {
    final value =
    _coTextController.text.trim();

    if (value.isEmpty) {
      return;
    }

    setState(() {
      _co = value;
      _coTextController.clear();
    });
  }

  // ============================================================
  // ADD DIAGNOSIS
  // ============================================================

  void _addDiagnosis() {
    final value =
    _diagnosisTextController.text.trim();

    if (value.isEmpty) {
      return;
    }

    setState(() {
      _diagnosis = value;
      _diagnosisTextController.clear();
    });
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DoctorsManage',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // PATIENT DETAILS
              // ==================================================

              _buildSection(
                title: 'Patient Details',
                titleColor: Colors.red,
                child: Column(
                  children: [
                    _buildReadOnlyField(
                      label: 'ID',
                      value: _patientId,
                    ),

                    _buildReadOnlyField(
                      label: 'Name',
                      value: _patientName,
                    ),

                    _buildReadOnlyField(
                      label: 'Address',
                      value: _patientAddress,
                    ),

                    _buildReadOnlyField(
                      label: 'Date Of Birth',
                      value: _patientDateOfBirth,
                    ),

                    _buildReadOnlyField(
                      label: 'Phone',
                      value: _patientPhone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // NEW MEDICAL
              // ==================================================

              _buildSection(
                title: 'New Medical',
                titleColor: Colors.blue,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [

                    // ------------------------------------------
                    // NOTE
                    // ------------------------------------------

                    const Text(
                      'Note',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                            _noteController,
                            decoration:
                            const InputDecoration(
                              border:
                              OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: _saveNote,
                          child:
                          const Text('Save'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // DATE + TYPE
                    // ------------------------------------------

                    _buildDateField(
                      label: 'Date',
                      date: _medicalDate,
                      onTap:
                      _selectMedicalDate,
                    ),

                    const SizedBox(height: 12),

                    _buildDropdown(
                      label: 'Type',
                      value: _type,
                      items: _typeOptions,
                      onChanged: (value) {
                        setState(() {
                          _type = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // ADDED BY
                    // ------------------------------------------

                    _buildDisplayLine(
                      label: 'Added By',
                      value: '',
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // AGE
                    // ------------------------------------------

                    _buildAgeSection(),

                    const SizedBox(height: 12),

                    // ------------------------------------------
                    // WEIGHT / HEIGHT
                    // ------------------------------------------

                    _buildInputField(
                      label: 'Weight',
                      controller:
                      _weightController,
                      keyboardType:
                      TextInputType.number,
                    ),

                    _buildInputField(
                      label: 'Height',
                      controller:
                      _heightController,
                      keyboardType:
                      TextInputType.number,
                    ),

                    _buildInputField(
                      label: 'Temperature',
                      controller:
                      _temperatureController,
                      keyboardType:
                      TextInputType.number,
                    ),

                    _buildInputField(
                      label: 'H.C.',
                      controller:
                      _hcController,
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // C/O
                    // ------------------------------------------

                    _buildRedLabel(
                      'C \\ O',
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildDropdown(
                            label: '',
                            value: _co,
                            items: _coOptions,
                            onChanged: (value) {
                              setState(() {
                                _co = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: _addCo,
                          child:
                          const Text('Add'),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller:
                            _coTextController,
                            decoration:
                            const InputDecoration(
                              border:
                              OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------
                    // INVESTIGATIONS
                    // ------------------------------------------

                    _buildInputField(
                      label: 'Investigations',
                      controller:
                      _investigationController,
                    ),

                    // ------------------------------------------
                    // PREVIOUS TTT
                    // ------------------------------------------

                    _buildInputField(
                      label: 'Previous TTT',
                      controller:
                      _previousTttController,
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // DIAGNOSIS
                    // ------------------------------------------

                    _buildRedLabel(
                      'Diagnosis',
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildDropdown(
                            label: '',
                            value: _diagnosis,
                            items:
                            _diagnosisOptions,
                            onChanged: (value) {
                              setState(() {
                                _diagnosis =
                                    value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed:
                          _addDiagnosis,
                          child:
                          const Text('Add'),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller:
                            _diagnosisTextController,
                            decoration:
                            const InputDecoration(
                              border:
                              OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------
                    // TTT
                    // ------------------------------------------

                    _buildRedLabel(
                      'T T T',
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildDropdown(
                            label: '',
                            value: _ttt,
                            items: _tttOptions,
                            onChanged: (value) {
                              setState(() {
                                _ttt = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: _addTtt,
                          child:
                          const Text('Add'),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller:
                            _tttTextController,
                            decoration:
                            const InputDecoration(
                              border:
                              OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // DOSE
                    // ------------------------------------------

                    _buildDropdown(
                      label: 'Dose',
                      value: _dose,
                      items: _doseOptions,
                      onChanged: (value) {
                        setState(() {
                          _dose = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // TTT TABLE
                    // ------------------------------------------

                    _buildTttTable(),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // NOTES
                    // ------------------------------------------

                    _buildInputField(
                      label: 'Notes',
                      controller:
                      _notesController,
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // DAY OF REVISION
                    // ------------------------------------------

                    _buildDateField(
                      label: 'Day Of Revision',
                      date: _revisionDate,
                      onTap:
                      _selectRevisionDate,
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------
                    // SAVE
                    // ------------------------------------------

                    Align(
                      alignment:
                      Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed:
                        _saveMedical,
                        child:
                        const Text('Save'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------
                    // SAVE RECENT
                    // ------------------------------------------

                    Align(
                      alignment:
                      Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed:
                        _saveRecent,
                        child:
                        const Text(
                          'Save Recent',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // MEDICAL HISTORY
              // ==================================================

              _buildSection(
                title: 'Medical History',
                titleColor: Colors.grey,
                child: _buildMedicalHistoryTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required Color titleColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label :',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'None' : value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPLAY LINE
  // ============================================================

  Widget _buildDisplayLine({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(
          '$label :',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AGE SECTION
  // ============================================================

  Widget _buildAgeSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment:
      WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Age :',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _age.isEmpty ? '-' : _age,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const Text(
          'Age Y',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),

        const Text(
          'Ag M',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),

        const Text(
          'Ag D',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label :',
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration:
              const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RED LABEL
  // ============================================================

  Widget _buildRedLabel(String label) {
    return Text(
      '$label :',
      style: const TextStyle(
        color: Colors.red,
        fontSize: 18,
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText:
        label.isEmpty ? null : label,
        border:
        const OutlineInputBorder(),
        isDense: true,
      ),
      items: items.map(
            (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow:
              TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border:
          const OutlineInputBorder(),
          suffixIcon:
          const Icon(Icons.calendar_today),
          isDense: true,
        ),
        child: Text(
          _formatDate(date),
        ),
      ),
    );
  }

  // ============================================================
  // TTT TABLE
  // ============================================================

  Widget _buildTttTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade500,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _TableHeader(
                    'TTT',
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: _TableHeader(
                    'Dose',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _TableHeader(
                    'Delete',
                  ),
                ),
              ],
            ),
          ),

          if (_tttItems.isEmpty)
            Container(
              height: 100,
              alignment:
              Alignment.center,
              child: const Text(
                '',
              ),
            )
          else
            ..._tttItems.asMap().entries.map(
                  (entry) {
                final index =
                    entry.key;
                final item =
                    entry.value;

                return SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child:
                        _TableCell(
                          item['ttt'] ?? '',
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child:
                        _TableCell(
                          item['dose'] ?? '',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child:
                        IconButton(
                          onPressed: () {
                            _deleteTtt(
                              index,
                            );
                          },
                          icon:
                          const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // MEDICAL HISTORY TABLE
  // ============================================================

  Widget _buildMedicalHistoryTable() {
    const headers = [
      'Type',
      'Date',
      'W',
      'Investigation',
      'Diagnosis',
      'TTT',
      'By Dr',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: SizedBox(
        width: 850,
        child: Column(
          children: [
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: Row(
                children:
                headers.asMap().entries.map(
                      (entry) {
                    return Expanded(
                      flex: _historyFlex(
                        entry.key,
                      ),
                      child:
                      _TableHeader(
                        entry.value,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

            if (_medicalHistory.isEmpty)
              ...List.generate(
                8,
                    (index) {
                  return Container(
                    height: 38,
                    decoration:
                    BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                        right: BorderSide(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                        bottom: BorderSide(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                    ),
                    child: Row(
                      children:
                      List.generate(
                        headers.length,
                            (column) {
                          return Expanded(
                            flex:
                            _historyFlex(
                              column,
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
              )
            else
              ..._medicalHistory
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                  final item =
                      entry.value;

                  final values = [
                    item['type'] ?? '',
                    item['date'] ?? '',
                    item['w'] ?? '',
                    item['investigation'] ??
                        '',
                    item['diagnosis'] ??
                        '',
                    item['ttt'] ?? '',
                    item['byDr'] ?? '',
                  ];

                  return Container(
                    height: 44,
                    child: Row(
                      children: values
                          .asMap()
                          .entries
                          .map(
                            (value) {
                          return Expanded(
                            flex:
                            _historyFlex(
                              value.key,
                            ),
                            child:
                            _TableCell(
                              value.value,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HISTORY COLUMN WIDTH
  // ============================================================

  int _historyFlex(int index) {
    switch (index) {
      case 0:
        return 2;

      case 1:
        return 2;

      case 2:
        return 1;

      case 3:
        return 4;

      case 4:
        return 4;

      case 5:
        return 4;

      case 6:
        return 3;

      default:
        return 2;
    }
  }
}

// ================================================================
// TABLE HEADER
// ================================================================

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================================================================
// TABLE CELL
// ================================================================

class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
          ),
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}