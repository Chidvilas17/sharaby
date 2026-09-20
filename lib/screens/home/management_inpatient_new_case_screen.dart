import 'package:flutter/material.dart';
import '../../services/hdan_patients_api_service.dart';

class ManagementInpatientNewCaseScreen extends StatefulWidget {
  const ManagementInpatientNewCaseScreen({super.key});

  @override
  State<ManagementInpatientNewCaseScreen> createState() =>
      _ManagementInpatientNewCaseScreenState();
}

class _ManagementInpatientNewCaseScreenState
    extends State<ManagementInpatientNewCaseScreen> {
  // =========================================================
  // TEXT FIELDS
  // =========================================================

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

  // =========================================================
  // DATABASE DROPDOWNS
  // =========================================================

  String? transferFromDoctor;
  String? consultingDoctor;
  String? doctorReferral;
  String? treatmentType;

  // =========================================================
  // DATABASE DATA
  // =========================================================

  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> treatmentTypes = [];

  bool loadingData = true;
  bool saving = false;

  // =========================================================
  // BIRTH DATE
  // =========================================================

  int birthDay = 1;
  int birthMonth = 1;
  int birthYear = 2000;

  // =========================================================
  // ADMISSION DATE
  // =========================================================

  DateTime admissionDate = DateTime.now();

  // =========================================================
  // ADMISSION TIME
  // =========================================================

  int admissionHour = 1;
  int admissionMinute = 0;
  String admissionPeriod = 'AM';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  // =========================================================
  // LOAD DOCTORS + TREATMENT TYPES
  // =========================================================

  Future<void> _loadDatabaseData() async {
    try {
      final results = await Future.wait([
        HdanPatientsApiService.getDoctors(),
        HdanPatientsApiService.getTreatmentTypes(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        doctors = results[0];
        treatmentTypes = results[1];
        loadingData = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingData = false;
      });

      _showMessage(
        'Failed to load doctors or treatment types.\n$e',
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    nameController.dispose();
    guardianIdController.dispose();
    addressController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    notesController;

    notesController.dispose();

    super.dispose();
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  // =========================================================
  // ADMISSION DATE PICKER
  // =========================================================

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

  // =========================================================
  // BUILD BIRTH DATE
  // =========================================================

  DateTime? _getBirthDate() {
    final date = DateTime(
      birthYear,
      birthMonth,
      birthDay,
    );

    // Prevent invalid dates such as 31-02-2000
    if (date.year != birthYear ||
        date.month != birthMonth ||
        date.day != birthDay) {
      return null;
    }

    return date;
  }

  // =========================================================
  // BUILD ADMISSION DATETIME
  // =========================================================

  DateTime _getAdmissionDateTime() {
    int hour = admissionHour;

    if (admissionPeriod == 'PM' && hour != 12) {
      hour += 12;
    }

    if (admissionPeriod == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      admissionDate.year,
      admissionDate.month,
      admissionDate.day,
      hour,
      admissionMinute,
    );
  }

  // =========================================================
  // SAVE
  // =========================================================

  Future<void> _save() async {
    if (saving) {
      return;
    }

    // ---------------------------------------------------------
    // NAME
    // ---------------------------------------------------------

    final name = nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter the patient name.',
      );
      return;
    }

    // ---------------------------------------------------------
    // PHONE 1
    // ---------------------------------------------------------

    final phone = phone1Controller.text.trim();

    if (phone.isEmpty) {
      _showMessage(
        'Please enter Phone 1.',
      );
      return;
    }

    // ---------------------------------------------------------
    // TREATMENT
    // ---------------------------------------------------------

    if (treatmentType == null ||
        treatmentType!.trim().isEmpty) {
      _showMessage(
        'Please select the treatment type.',
      );
      return;
    }

    // ---------------------------------------------------------
    // BIRTH DATE
    // ---------------------------------------------------------

    final birthDate = _getBirthDate();

    if (birthDate == null) {
      _showMessage(
        'Please select a valid date of birth.',
      );
      return;
    }

    // ---------------------------------------------------------
    // OTHER VALUES
    // ---------------------------------------------------------

    final guardianId =
    guardianIdController.text.trim();

    final address =
    addressController.text.trim();

    final phone2 =
    phone2Controller.text.trim();

    // Notes are kept in the UI.
    // The verified HdanPatients API currently has no Notes field,
    // so we do not send Notes into an unverified database column.

    // ---------------------------------------------------------
    // ADMISSION DATETIME
    // ---------------------------------------------------------

    final timeOfIn =
    _getAdmissionDateTime();

    // ---------------------------------------------------------
    // START SAVING
    // ---------------------------------------------------------

    setState(() {
      saving = true;
    });

    try {
      final result =
      await HdanPatientsApiService.addPatient(
        name: name,

        address: address.isEmpty
            ? null
            : address,

        phone: phone,

        phone2: phone2.isEmpty
            ? null
            : phone2,

        // Guardian ID -> HdanPatients.Card
        card: guardianId.isEmpty
            ? null
            : guardianId,

        // Transfer From Doctor -> From_Dr
        fromDr: transferFromDoctor,

        // Doctor Referral -> Shift_Dr
        shiftDr: doctorReferral,

        // Consulting Doctor -> Manager_Dr
        managerDr: consultingDoctor,

        // Admission date + time -> Time_of_in
        timeOfIn: timeOfIn,

        // Birth date -> Time_of_born
        timeOfBorn: birthDate,

        // Treatment Type -> type
        type: treatmentType,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      _showMessage(
        'Patient added successfully. ID: ${result['id'] ?? ''}',
      );

      // -------------------------------------------------------
      // CLEAR FORM AFTER SUCCESS
      // -------------------------------------------------------

      nameController.clear();
      guardianIdController.clear();
      addressController.clear();
      phone1Controller.clear();
      phone2Controller.clear();
      notesController.clear();

      setState(() {
        transferFromDoctor = null;
        consultingDoctor = null;
        doctorReferral = null;
        treatmentType = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      _showMessage(
        'Failed to save patient.\n$e',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

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

  // =========================================================
  // DOCTOR DROPDOWN
  // =========================================================

  Widget _doctorDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    if (loadingData) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: const SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: doctors.map((doctor) {
        final doctorName =
        (doctor['name'] ?? '').toString();

        if (doctorName.isEmpty) {
          return null;
        }

        return DropdownMenuItem<String>(
          value: doctorName,
          child: Text(
            doctorName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).whereType<DropdownMenuItem<String>>().toList(),
      onChanged: onChanged,
    );
  }

  // =========================================================
  // TREATMENT DROPDOWN
  // =========================================================

  Widget _treatmentDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    if (loadingData) {
      return InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Treatment Type',
          border: OutlineInputBorder(),
        ),
        child: const SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Treatment Type',
        border: OutlineInputBorder(),
      ),
      items: treatmentTypes.map((treatment) {
        final treatmentName =
        (treatment['type'] ?? '').toString();

        if (treatmentName.isEmpty) {
          return null;
        }

        return DropdownMenuItem<String>(
          value: treatmentName,
          child: Text(
            treatmentName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).whereType<DropdownMenuItem<String>>().toList(),
      onChanged: onChanged,
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

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

  // =========================================================
  // BIRTH DATE
  // =========================================================

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

  // =========================================================
  // ADMISSION DATE
  // =========================================================

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
              borderRadius:
              BorderRadius.circular(4),
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

  // =========================================================
  // ADMISSION TIME
  // =========================================================

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

  // =========================================================
  // BUILD
  // =========================================================

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
              // =================================================
              // PATIENT INFORMATION
              // =================================================

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

              // =================================================
              // DOCTOR INFORMATION
              // =================================================

              _sectionTitle(
                'Doctor Information',
              ),

              _doctorDropdown(
                label: 'Transfer From Doctor',
                value: transferFromDoctor,
                onChanged: (value) {
                  setState(() {
                    transferFromDoctor = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _doctorDropdown(
                label: 'Consulting Doctor',
                value: consultingDoctor,
                onChanged: (value) {
                  setState(() {
                    consultingDoctor = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _doctorDropdown(
                label: 'Doctor Referral',
                value: doctorReferral,
                onChanged: (value) {
                  setState(() {
                    doctorReferral = value;
                  });
                },
              ),

              const SizedBox(height: 26),

              // =================================================
              // TREATMENT
              // =================================================

              _sectionTitle(
                'Treatment',
              ),

              _treatmentDropdown(
                value: treatmentType,
                onChanged: (value) {
                  setState(() {
                    treatmentType = value;
                  });
                },
              ),

              const SizedBox(height: 26),

              // =================================================
              // DATE OF BIRTH
              // =================================================

              _birthDateSection(),

              const SizedBox(height: 26),

              // =================================================
              // ADMISSION DATE
              // =================================================

              _admissionDateSection(),

              const SizedBox(height: 26),

              // =================================================
              // ADMISSION TIME
              // =================================================

              _admissionTimeSection(),

              const SizedBox(height: 26),

              // =================================================
              // NOTES
              // =================================================

              _sectionTitle(
                'Notes',
              ),

              _textField(
                label: 'Notes',
                controller:
                notesController,
              ),

              const SizedBox(height: 30),

              // =================================================
              // SAVE
              // =================================================

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  saving ? null : _save,

                  child: saving
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
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