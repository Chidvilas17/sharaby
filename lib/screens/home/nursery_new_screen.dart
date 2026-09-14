import 'package:flutter/material.dart';

class NurseryNewScreen extends StatefulWidget {
  const NurseryNewScreen({super.key});

  @override
  State<NurseryNewScreen> createState() => _NurseryNewScreenState();
}

class _NurseryNewScreenState extends State<NurseryNewScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController guardianIdController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController phone3Controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? transferredFromDoctor;
  String? neonatologyDoctor;
  String? consultingDoctor;
  String? birthDoctor;
  String? treatmentType;

  int? birthHour;
  int? birthMinute;
  int? birthAmPm;

  int? admissionHour;
  int? admissionMinute;
  int? admissionAmPm;

  DateTime? birthDate;
  DateTime? admissionDate;

  int? selectedRow;

  final List<String> tableHeaders = [
    'No.',
    'Name',
    'Address',
    'Phone 1',
    'Phone 2',
    'Phone 3',
    'Age Today',
    'Card Number',
    'Transferred From',
    'Neonatology Doctor',
    'Consulting Doctor',
    'Card Holder',
  ];

  @override
  void dispose() {
    nameController.dispose();
    guardianIdController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    phone3Controller.dispose();
    addressController.dispose();
    cardHolderController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool isBirthDate,
  }) async {
    final initialDate = isBirthDate
        ? (birthDate ?? DateTime(2020, 1, 1))
        : (admissionDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isBirthDate) {
        birthDate = picked;
      } else {
        admissionDate = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  String _formatTime(
      int? hour,
      int? minute,
      int? amPm,
      ) {
    if (hour == null || minute == null || amPm == null) {
      return '';
    }

    final suffix = amPm == 0 ? 'AM' : 'PM';

    return '$hour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      _showMessage('Please enter the patient name.');
      return;
    }

    if (phone1Controller.text.trim().isEmpty) {
      _showMessage('Please enter Phone 1.');
      return;
    }

    if (treatmentType == null || treatmentType == 'SELECT') {
      _showMessage('Please select the treatment type.');
      return;
    }

    _showMessage(
      'Data validated successfully. Database saving will be connected later.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: 'SELECT',
            child: Text('Select'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _numberDropdown({
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    String Function(int)? textBuilder,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item,
          child: Text(
            textBuilder == null
                ? item.toString().padLeft(2, '0')
                : textBuilder(item),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_month),
          ),
          child: Text(
            value == null ? 'Select date' : _formatDate(value),
          ),
        ),
      ),
    );
  }

  Widget _timeSection({
    required String title,
    required int? hour,
    required int? minute,
    required int? amPm,
    required ValueChanged<int?> onHourChanged,
    required ValueChanged<int?> onMinuteChanged,
    required ValueChanged<int?> onAmPmChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _numberDropdown(
                  label: 'Hour',
                  value: hour,
                  items: List.generate(12, (index) => index + 1),
                  onChanged: onHourChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _numberDropdown(
                  label: 'Minute',
                  value: minute,
                  items: List.generate(60, (index) => index),
                  onChanged: onMinuteChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: amPm,
                  decoration: const InputDecoration(
                    labelText: 'AM / PM',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('AM'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('PM'),
                    ),
                  ],
                  onChanged: onAmPmChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(130),
        border: TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
            ),
            children: tableHeaders.map((header) {
              return Container(
                height: 48,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          ...List.generate(15, (rowIndex) {
            return TableRow(
              children: tableHeaders.map((header) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRow = rowIndex;
                    });
                  },
                  child: Container(
                    height: 42,
                    color: selectedRow == rowIndex
                        ? Colors.blue.withOpacity(0.12)
                        : Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      header == 'No.'
                          ? '${rowIndex + 1}'
                          : '',
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Nursery Case'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _textField(
              label: 'Name',
              controller: nameController,
            ),

            _textField(
              label: 'Guardian ID',
              controller: guardianIdController,
              keyboardType: TextInputType.number,
            ),

            _textField(
              label: 'Phone 1',
              controller: phone1Controller,
              keyboardType: TextInputType.phone,
            ),

            _textField(
              label: 'Phone 2',
              controller: phone2Controller,
              keyboardType: TextInputType.phone,
            ),

            _textField(
              label: 'Phone 3',
              controller: phone3Controller,
              keyboardType: TextInputType.phone,
            ),

            _textField(
              label: 'Address',
              controller: addressController,
            ),

            _textField(
              label: 'Card Holder Name',
              controller: cardHolderController,
            ),

            const SizedBox(height: 8),

            const Text(
              'Doctor Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _dropdown(
              label: 'Transferred From Doctor',
              value: transferredFromDoctor,
              onChanged: (value) {
                setState(() {
                  transferredFromDoctor = value;
                });
              },
            ),

            _dropdown(
              label: 'Neonatology Doctor',
              value: neonatologyDoctor,
              onChanged: (value) {
                setState(() {
                  neonatologyDoctor = value;
                });
              },
            ),

            _dropdown(
              label: 'Consulting Doctor',
              value: consultingDoctor,
              onChanged: (value) {
                setState(() {
                  consultingDoctor = value;
                });
              },
            ),

            _dropdown(
              label: 'Birth Doctor',
              value: birthDoctor,
              onChanged: (value) {
                setState(() {
                  birthDoctor = value;
                });
              },
            ),

            const SizedBox(height: 8),

            const Text(
              'Birth Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _dateField(
              label: 'Birth Date',
              value: birthDate,
              onTap: () {
                _pickDate(isBirthDate: true);
              },
            ),

            _timeSection(
              title: 'Birth Time',
              hour: birthHour,
              minute: birthMinute,
              amPm: birthAmPm,
              onHourChanged: (value) {
                setState(() {
                  birthHour = value;
                });
              },
              onMinuteChanged: (value) {
                setState(() {
                  birthMinute = value;
                });
              },
              onAmPmChanged: (value) {
                setState(() {
                  birthAmPm = value;
                });
              },
            ),

            const SizedBox(height: 8),

            const Text(
              'Admission Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _dateField(
              label: 'Admission Date',
              value: admissionDate,
              onTap: () {
                _pickDate(isBirthDate: false);
              },
            ),

            _timeSection(
              title: 'Admission Time',
              hour: admissionHour,
              minute: admissionMinute,
              amPm: admissionAmPm,
              onHourChanged: (value) {
                setState(() {
                  admissionHour = value;
                });
              },
              onMinuteChanged: (value) {
                setState(() {
                  admissionMinute = value;
                });
              },
              onAmPmChanged: (value) {
                setState(() {
                  admissionAmPm = value;
                });
              },
            ),

            _dropdown(
              label: 'Treatment Type',
              value: treatmentType,
              onChanged: (value) {
                setState(() {
                  treatmentType = value;
                });
              },
            ),

            _textField(
              label: 'Notes',
              controller: notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Nursery Cases',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}