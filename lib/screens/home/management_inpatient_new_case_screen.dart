import 'package:flutter/material.dart';

class ManagementInpatientNewCaseScreen extends StatefulWidget {
  const ManagementInpatientNewCaseScreen({super.key});

  @override
  State<ManagementInpatientNewCaseScreen> createState() =>
      _ManagementInpatientNewCaseScreenState();
}

class _ManagementInpatientNewCaseScreenState
    extends State<ManagementInpatientNewCaseScreen> {
  // =========================
  // TEXT FIELDS
  // =========================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController guardianIdController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController phone1Controller =
  TextEditingController();

  final TextEditingController phone2Controller =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  // =========================
  // DATABASE DROPDOWNS
  // =========================

  String? transferFromDoctor;
  String? consultingDoctor;
  String? doctorReferral;
  String? treatmentType;

  // =========================
  // BIRTH DATE
  // =========================

  int birthDay = 1;
  int birthMonth = 1;
  int birthYear = 2000;

  // =========================
  // ADMISSION DATE
  // =========================

  DateTime admissionDate = DateTime.now();

  // =========================
  // ADMISSION TIME
  // =========================

  int admissionHour = 1;
  int admissionMinute = 0;
  String admissionPeriod = 'AM';

  @override
  void dispose() {
    nameController.dispose();
    guardianIdController.dispose();
    addressController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    notesController.dispose();

    super.dispose();
  }

  // =========================
  // DATE FORMAT
  // =========================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  // =========================
  // ADMISSION DATE PICKER
  // =========================

  Future<void> _selectAdmissionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: admissionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      admissionDate = picked;
    });
  }

  // =========================
  // SAVE
  // =========================

  void _save() {
    if (nameController.text.trim().isEmpty) {
      _showMessage('Please enter the patient name.');
      return;
    }

    if (phone1Controller.text.trim().isEmpty) {
      _showMessage('Please enter Phone 1.');
      return;
    }

    if (treatmentType == null) {
      _showMessage('Please select the treatment type.');
      return;
    }

    // Database/API connection will be added later.
    _showMessage(
      'Patient information is ready to be saved.',
    );
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================
  // TEXT FIELD
  // =========================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // =========================
  // DATABASE DROPDOWN
  // =========================

  Widget _databaseDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem<String>(
          value: 'SELECT',
          child: Text('Select'),
        ),
      ],
      onChanged: (value) {
        onChanged(value);
      },
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // BIRTH DATE
  // =========================

  Widget _birthDateSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Date of Birth'),

        Row(
          children: [
            // DAY
            Expanded(
              child: DropdownButtonFormField<int>(
                value: birthDay,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  31,
                      (index) {
                    final day = index + 1;

                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text('$day'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    birthDay = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            // MONTH
            Expanded(
              child: DropdownButtonFormField<int>(
                value: birthMonth,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  12,
                      (index) {
                    final month = index + 1;

                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text('$month'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    birthMonth = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            // YEAR
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                value: birthYear,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  101,
                      (index) {
                    final year = 2000 + index;

                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text('$year'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    birthYear = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // ADMISSION DATE
  // =========================

  Widget _admissionDateSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Admission Date'),

        InkWell(
          onTap: _selectAdmissionDate,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade500,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    _formatDate(admissionDate),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // ADMISSION TIME
  // =========================

  Widget _admissionTimeSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Admission Time'),

        Row(
          children: [
            // HOUR
            Expanded(
              child: DropdownButtonFormField<int>(
                value: admissionHour,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Hour',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  12,
                      (index) {
                    final hour = index + 1;

                    return DropdownMenuItem<int>(
                      value: hour,
                      child: Text('$hour'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    admissionHour = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            // MINUTE
            Expanded(
              child: DropdownButtonFormField<int>(
                value: admissionMinute,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Minute',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  60,
                      (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        index
                            .toString()
                            .padLeft(2, '0'),
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    admissionMinute = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            // AM / PM
            Expanded(
              child: DropdownButtonFormField<String>(
                value: admissionPeriod,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'AM',
                    child: Text('AM'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'PM',
                    child: Text('PM'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    admissionPeriod = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Internal Case',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              // =================================
              // PATIENT INFORMATION
              // =================================

              _sectionTitle(
                'Patient Information',
              ),

              _textField(
                label: 'Name',
                controller: nameController,
              ),

              const SizedBox(height: 14),

              _textField(
                label: 'Guardian ID',
                controller:
                guardianIdController,
              ),

              const SizedBox(height: 14),

              _textField(
                label: 'Address',
                controller:
                addressController,
              ),

              const SizedBox(height: 14),

              _textField(
                label: 'Phone 1',
                controller:
                phone1Controller,
                keyboardType:
                TextInputType.phone,
              ),

              const SizedBox(height: 14),

              _textField(
                label: 'Phone 2',
                controller:
                phone2Controller,
                keyboardType:
                TextInputType.phone,
              ),

              const SizedBox(height: 26),

              // =================================
              // DOCTOR INFORMATION
              // =================================

              _sectionTitle(
                'Doctor Information',
              ),

              _databaseDropdown(
                label: 'Transfer From Doctor',
                value: transferFromDoctor,
                onChanged: (value) {
                  setState(() {
                    transferFromDoctor =
                        value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _databaseDropdown(
                label: 'Consulting Doctor',
                value: consultingDoctor,
                onChanged: (value) {
                  setState(() {
                    consultingDoctor =
                        value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _databaseDropdown(
                label: 'Doctor Referral',
                value: doctorReferral,
                onChanged: (value) {
                  setState(() {
                    doctorReferral =
                        value;
                  });
                },
              ),

              const SizedBox(height: 26),

              // =================================
              // TREATMENT
              // =================================

              _sectionTitle(
                'Treatment',
              ),

              _databaseDropdown(
                label: 'Treatment Type',
                value: treatmentType,
                onChanged: (value) {
                  setState(() {
                    treatmentType =
                        value;
                  });
                },
              ),

              const SizedBox(height: 26),

              // =================================
              // DATE OF BIRTH
              // =================================

              _birthDateSection(),

              const SizedBox(height: 26),

              // =================================
              // ADMISSION DATE
              // =================================

              _admissionDateSection(),

              const SizedBox(height: 26),

              // =================================
              // ADMISSION TIME
              // =================================

              _admissionTimeSection(),

              const SizedBox(height: 26),

              // =================================
              // NOTES
              // =================================

              _sectionTitle(
                'Notes',
              ),

              _textField(
                label: 'Notes',
                controller:
                notesController,
              ),

              const SizedBox(height: 30),

              // =================================
              // SAVE
              // =================================

              SizedBox(
                height: 52,

                child: ElevatedButton(
                  onPressed: _save,

                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}