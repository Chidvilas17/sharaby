import 'package:flutter/material.dart';
import '../../services/hdan_patients_api_service.dart';

class NurseryNewScreen extends StatefulWidget {
  const NurseryNewScreen({super.key});

  @override
  State<NurseryNewScreen> createState() => _NurseryNewScreenState();
}

class _NurseryNewScreenState extends State<NurseryNewScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController guardianIdController =
  TextEditingController();

  final TextEditingController phone1Controller =
  TextEditingController();

  final TextEditingController phone2Controller =
  TextEditingController();

  final TextEditingController phone3Controller =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController cardHolderController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  // ============================================================
  // DROPDOWN VALUES
  // ============================================================

  String? transferredFromDoctor;
  String? neonatologyDoctor;
  String? consultingDoctor;
  String? birthDoctor;
  String? treatmentType;

  // ============================================================
  // TIME VALUES
  // ============================================================

  int? birthHour;
  int? birthMinute;
  int? birthAmPm;

  int? admissionHour;
  int? admissionMinute;
  int? admissionAmPm;

  // ============================================================
  // DATES
  // ============================================================

  DateTime? birthDate;
  DateTime? admissionDate;

  // ============================================================
  // DATABASE DATA
  // ============================================================

  List<Map<String, dynamic>> patients = [];

  bool loadingPatients = false;
  bool saving = false;

  int? selectedRow;

  // ============================================================
  // TABLE HEADERS
  // ============================================================

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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadPatients();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

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

  // ============================================================
  // LOAD PATIENTS
  // ============================================================

  Future<void> _loadPatients() async {
    setState(() {
      loadingPatients = true;
    });

    try {
      final result =
      await HdanPatientsApiService.getPatients();

      if (!mounted) return;

      setState(() {
        patients = result;
        loadingPatients = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingPatients = false;
      });

      _showMessage(
        'Failed to load nursery patients: $e',
      );
    }
  }

  // ============================================================
  // PICK DATE
  // ============================================================

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

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // CONVERT SELECTED TIME TO DATETIME
  // ============================================================

  DateTime? _buildDateTime({
    required DateTime? date,
    required int? hour,
    required int? minute,
    required int? amPm,
  }) {
    if (date == null) {
      return null;
    }

    int finalHour = hour ?? 0;

    if (amPm == 1) {
      if (finalHour < 12) {
        finalHour += 12;
      }
    } else {
      if (finalHour == 12) {
        finalHour = 0;
      }
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      finalHour,
      minute ?? 0,
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (saving) return;

    final name =
    nameController.text.trim();

    final phone1 =
    phone1Controller.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter the patient name.',
      );
      return;
    }

    if (phone1.isEmpty) {
      _showMessage(
        'Please enter Phone 1.',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final admissionDateTime =
      _buildDateTime(
        date: admissionDate,
        hour: admissionHour,
        minute: admissionMinute,
        amPm: admissionAmPm,
      );

      final birthDateTime =
      _buildDateTime(
        date: birthDate,
        hour: birthHour,
        minute: birthMinute,
        amPm: birthAmPm,
      );

      await HdanPatientsApiService.addPatient(
        name: name,

        address:
        addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),

        phone: phone1,

        phone2:
        phone2Controller.text.trim().isEmpty
            ? null
            : phone2Controller.text.trim(),

        phone3:
        phone3Controller.text.trim().isEmpty
            ? null
            : phone3Controller.text.trim(),

        card:
        guardianIdController.text.trim().isEmpty
            ? null
            : guardianIdController.text.trim(),

        fromDr:
        transferredFromDoctor == null ||
            transferredFromDoctor == 'SELECT'
            ? null
            : transferredFromDoctor,

        shiftDr:
        neonatologyDoctor == null ||
            neonatologyDoctor == 'SELECT'
            ? null
            : neonatologyDoctor,

        managerDr:
        consultingDoctor == null ||
            consultingDoctor == 'SELECT'
            ? null
            : consultingDoctor,

        timeOfIn: admissionDateTime,

        doctorsOfBorn:
        birthDoctor == null ||
            birthDoctor == 'SELECT'
            ? null
            : birthDoctor,

        timeOfBorn: birthDateTime,

        type:
        treatmentType == null ||
            treatmentType == 'SELECT'
            ? null
            : treatmentType,

        cardOwner:
        cardHolderController.text.trim().isEmpty
            ? null
            : cardHolderController.text.trim(),
      );

      if (!mounted) return;

      await _loadPatients();

      _clearForm();

      _showMessage(
        'Nursery patient added successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save patient: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void _clearForm() {
    nameController.clear();
    guardianIdController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    phone3Controller.clear();
    addressController.clear();
    cardHolderController.clear();
    notesController.clear();

    setState(() {
      transferredFromDoctor = null;
      neonatologyDoctor = null;
      consultingDoctor = null;
      birthDoctor = null;
      treatmentType = null;

      birthHour = null;
      birthMinute = null;
      birthAmPm = null;

      admissionHour = null;
      admissionMinute = null;
      admissionAmPm = null;

      birthDate = null;
      admissionDate = null;

      selectedRow = null;
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteSelected() async {
    if (selectedRow == null) {
      _showMessage(
        'Please select a patient first.',
      );
      return;
    }

    if (selectedRow! < 0 ||
        selectedRow! >= patients.length) {
      _showMessage(
        'Invalid patient selection.',
      );
      return;
    }

    final patient =
    patients[selectedRow!];

    final id = patient['id'] ??
        patient['ID'];

    if (id == null) {
      _showMessage(
        'Patient ID was not found.',
      );
      return;
    }

    try {
      await HdanPatientsApiService.deletePatient(
        int.parse(id.toString()),
      );

      if (!mounted) return;

      setState(() {
        selectedRow = null;
      });

      await _loadPatients();

      _showMessage(
        'Patient deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete patient: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
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

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
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

  // ============================================================
  // NUMBER DROPDOWN
  // ============================================================

  Widget _numberDropdown({
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
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
            item.toString().padLeft(2, '0'),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(
              Icons.calendar_month,
            ),
          ),
          child: Text(
            value == null
                ? 'Select date'
                : _formatDate(value),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TIME SECTION
  // ============================================================

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
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                  items: List.generate(
                    12,
                        (index) => index + 1,
                  ),
                  onChanged: onHourChanged,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _numberDropdown(
                  label: 'Minute',
                  value: minute,
                  items: List.generate(
                    60,
                        (index) => index,
                  ),
                  onChanged: onMinuteChanged,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: DropdownButtonFormField<int>(
                  value: amPm,
                  isExpanded: true,
                  decoration:
                  const InputDecoration(
                    labelText: 'AM / PM',
                    border:
                    OutlineInputBorder(),
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
                  onChanged:
                  onAmPmChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable() {
    if (loadingPatients) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(130),
        border: TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
            ),
            children:
            tableHeaders.map((header) {
              return Container(
                height: 48,
                alignment: Alignment.center,
                padding:
                const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          // ------------------------------------------------------
          // DATABASE ROWS
          // ------------------------------------------------------

          if (patients.isEmpty)
            ...List.generate(
              15,
                  (rowIndex) {
                return TableRow(
                  children:
                  tableHeaders
                      .map((header) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRow =
                              rowIndex;
                        });
                      },
                      child: Container(
                        height: 42,
                        alignment:
                        Alignment.center,
                        color: selectedRow ==
                            rowIndex
                            ? Colors.blue
                            .withOpacity(
                          0.12,
                        )
                            : Colors
                            .transparent,
                        child: Text(
                          header == 'No.'
                              ? '${rowIndex + 1}'
                              : '',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          else
            ...patients
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final patient =
                  entry.value;

              final selected =
                  selectedRow == index;

              String value(
                  String key,
                  ) {
                final result =
                patient[key];

                if (result == null) {
                  return '';
                }

                return result.toString();
              }

              return TableRow(
                children: [
                  _tableCell(
                    '${index + 1}',
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('name') != ''
                        ? value('name')
                        : value('Name'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('address') != ''
                        ? value('address')
                        : value('Address'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('phone') != ''
                        ? value('phone')
                        : value('Phone'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('phone2'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('phone3'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('age'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('card'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('from_Dr'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('shift_Dr'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('manager_Dr'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),

                  _tableCell(
                    value('card_owner'),
                    selected,
                        () {
                      setState(() {
                        selectedRow =
                            index;
                      });
                    },
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE CELL
  // ============================================================

  Widget _tableCell(
      String text,
      bool selected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        color: selected
            ? Colors.blue.withOpacity(0.12)
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Add Nursery Case'),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            // ==================================================
            // PATIENT INFORMATION
            // ==================================================

            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _textField(
              label: 'Name',
              controller:
              nameController,
            ),

            _textField(
              label: 'Guardian ID',
              controller:
              guardianIdController,
              keyboardType:
              TextInputType.number,
            ),

            _textField(
              label: 'Phone 1',
              controller:
              phone1Controller,
              keyboardType:
              TextInputType.phone,
            ),

            _textField(
              label: 'Phone 2',
              controller:
              phone2Controller,
              keyboardType:
              TextInputType.phone,
            ),

            _textField(
              label: 'Phone 3',
              controller:
              phone3Controller,
              keyboardType:
              TextInputType.phone,
            ),

            _textField(
              label: 'Address',
              controller:
              addressController,
            ),

            _textField(
              label: 'Card Holder Name',
              controller:
              cardHolderController,
            ),

            const SizedBox(height: 8),

            // ==================================================
            // DOCTOR INFORMATION
            // ==================================================

            const Text(
              'Doctor Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _dropdown(
              label:
              'Transferred From Doctor',
              value:
              transferredFromDoctor,
              onChanged: (value) {
                setState(() {
                  transferredFromDoctor =
                      value;
                });
              },
            ),

            _dropdown(
              label:
              'Neonatology Doctor',
              value:
              neonatologyDoctor,
              onChanged: (value) {
                setState(() {
                  neonatologyDoctor =
                      value;
                });
              },
            ),

            _dropdown(
              label:
              'Consulting Doctor',
              value:
              consultingDoctor,
              onChanged: (value) {
                setState(() {
                  consultingDoctor =
                      value;
                });
              },
            ),

            _dropdown(
              label: 'Birth Doctor',
              value: birthDoctor,
              onChanged: (value) {
                setState(() {
                  birthDoctor =
                      value;
                });
              },
            ),

            const SizedBox(height: 8),

            // ==================================================
            // BIRTH INFORMATION
            // ==================================================

            const Text(
              'Birth Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _dateField(
              label: 'Birth Date',
              value: birthDate,
              onTap: () {
                _pickDate(
                  isBirthDate: true,
                );
              },
            ),

            _timeSection(
              title: 'Birth Time',
              hour: birthHour,
              minute: birthMinute,
              amPm: birthAmPm,
              onHourChanged:
                  (value) {
                setState(() {
                  birthHour =
                      value;
                });
              },
              onMinuteChanged:
                  (value) {
                setState(() {
                  birthMinute =
                      value;
                });
              },
              onAmPmChanged:
                  (value) {
                setState(() {
                  birthAmPm =
                      value;
                });
              },
            ),

            const SizedBox(height: 8),

            // ==================================================
            // ADMISSION INFORMATION
            // ==================================================

            const Text(
              'Admission Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _dateField(
              label:
              'Admission Date',
              value:
              admissionDate,
              onTap: () {
                _pickDate(
                  isBirthDate: false,
                );
              },
            ),

            _timeSection(
              title:
              'Admission Time',
              hour:
              admissionHour,
              minute:
              admissionMinute,
              amPm:
              admissionAmPm,
              onHourChanged:
                  (value) {
                setState(() {
                  admissionHour =
                      value;
                });
              },
              onMinuteChanged:
                  (value) {
                setState(() {
                  admissionMinute =
                      value;
                });
              },
              onAmPmChanged:
                  (value) {
                setState(() {
                  admissionAmPm =
                      value;
                });
              },
            ),

            _dropdown(
              label:
              'Treatment Type',
              value:
              treatmentType,
              onChanged: (value) {
                setState(() {
                  treatmentType =
                      value;
                });
              },
            ),

            _textField(
              label: 'Notes',
              controller:
              notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 8),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              height: 50,
              child:
              ElevatedButton.icon(
                onPressed:
                saving
                    ? null
                    : _save,
                icon: saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : const Icon(
                  Icons.save,
                ),
                label: Text(
                  saving
                      ? 'Saving...'
                      : 'Save',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // NURSERY CASES
            // ==================================================

            const Text(
              'Nursery Cases',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildTable(),

            const SizedBox(height: 16),

            // ==================================================
            // DELETE
            // ==================================================

            SizedBox(
              height: 48,
              child:
              ElevatedButton.icon(
                onPressed:
                _deleteSelected,
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label:
                const Text(
                  'Delete Selected',
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}