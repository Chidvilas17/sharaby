import 'package:flutter/material.dart';

import '../../services/patiants_api_service.dart';

class StatementsEditDataScreen
    extends StatefulWidget {
  const StatementsEditDataScreen({
    super.key,
  });

  @override
  State<StatementsEditDataScreen>
  createState() =>
      _StatementsEditDataScreenState();
}

class _StatementsEditDataScreenState
    extends State<StatementsEditDataScreen> {
  final TextEditingController
  searchController =
  TextEditingController();

  int? selectedRow;

  bool loading = false;

  List<Map<String, dynamic>>
  allPatients = [];

  List<Map<String, dynamic>>
  displayedPatients = [];

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadPatients();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD ALL
  // =========================================================

  Future<void> _loadPatients() async {
    setState(() {
      loading = true;
      selectedRow = null;
    });

    try {
      final result =
      await PatiantsApiService
          .getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        allPatients = result;
        displayedPatients =
        List<Map<String, dynamic>>.from(
          result,
        );
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        allPatients = [];
        displayedPatients = [];
      });

      _showMessage(
        'Failed to load patients.\n$e',
      );
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _search() {
    final search =
    searchController.text
        .trim()
        .toLowerCase();

    setState(() {
      selectedRow = null;

      if (search.isEmpty) {
        displayedPatients =
        List<Map<String, dynamic>>.from(
          allPatients,
        );

        return;
      }

      displayedPatients =
          allPatients.where((patient) {
            final name =
                patient['name'] ??
                    patient['Name'] ??
                    '';

            return name
                .toString()
                .toLowerCase()
                .contains(search);
          }).toList();
    });
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================================
  // GET VALUES
  // =========================================================

  String _value(
      Map<String, dynamic> patient,
      String key,
      ) {
    return patient[key]?.toString() ?? '';
  }

  // =========================================================
  // DATE
  // =========================================================

  String _formatDate(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final date =
    DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    return '$day-$month-${date.year}';
  }

  // =========================================================
  // SELECT ROW
  // =========================================================

  void _selectRow(int index) {
    setState(() {
      selectedRow = index;
    });
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> _deleteRow(
      int index,
      ) async {
    if (index >=
        displayedPatients.length) {
      return;
    }

    final patient =
    displayedPatients[index];

    final idValue =
        patient['patiantId'] ??
            patient['PatiantId'] ??
            patient['patiant_id'];

    final id =
    int.tryParse(
      idValue.toString(),
    );

    if (id == null) {
      _showMessage(
        'Invalid patient ID.',
      );
      return;
    }

    final name =
    _value(
      patient,
      'name',
    ).isNotEmpty
        ? _value(
      patient,
      'name',
    )
        : _value(
      patient,
      'Name',
    );

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          const Text('Delete Patient'),

          content: Text(
            'Are you sure you want to delete "$name"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await PatiantsApiService
          .deletePatient(id);

      if (!mounted) {
        return;
      }

      _showMessage(
        'Patient deleted successfully.',
      );

      await _loadPatients();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      _showMessage(
        'Delete failed.\n$e',
      );
    }
  }

  // =========================================================
  // DETAILS / EDIT
  // =========================================================

  Future<void> _showDetails(
      int index,
      ) async {
    if (index >=
        displayedPatients.length) {
      return;
    }

    setState(() {
      selectedRow = index;
    });

    final patient =
    displayedPatients[index];

    final idValue =
        patient['patiantId'] ??
            patient['PatiantId'] ??
            patient['patiant_id'];

    final id =
    int.tryParse(
      idValue.toString(),
    );

    if (id == null) {
      _showMessage(
        'Invalid patient ID.',
      );
      return;
    }

    try {
      final latest =
      await PatiantsApiService
          .getById(id);

      if (!mounted) {
        return;
      }

      await _showEditDialog(
        latest,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to load patient details.\n$e',
      );
    }
  }

  // =========================================================
  // EDIT DIALOG
  // =========================================================

  Future<void> _showEditDialog(
      Map<String, dynamic> patient,
      ) async {
    final nameController =
    TextEditingController(
      text: _value(
        patient,
        'name',
      ),
    );

    final phoneController =
    TextEditingController(
      text: _value(
        patient,
        'phone',
      ),
    );

    final addressController =
    TextEditingController(
      text: _value(
        patient,
        'address',
      ),
    );

    final importantNoteController =
    TextEditingController(
      text: _value(
        patient,
        'importantNote',
      ),
    );

    final noteForScController =
    TextEditingController(
      text: _value(
        patient,
        'noteForSc',
      ),
    );

    DateTime? selectedDob =
    DateTime.tryParse(
      _value(
        patient,
        'dob',
      ),
    );

    final idValue =
        patient['patiantId'] ??
            patient['PatiantId'] ??
            patient['patiant_id'];

    final id =
    int.tryParse(
      idValue.toString(),
    );

    final userIdValue =
        patient['userId'] ??
            patient['UserId'] ??
            patient['user_id'];

    final userId =
    int.tryParse(
      userIdValue?.toString() ?? '',
    );

    final dor =
    DateTime.tryParse(
      _value(
        patient,
        'dor',
      ),
    );

    if (id == null) {
      nameController.dispose();
      phoneController.dispose();
      addressController.dispose();
      importantNoteController.dispose();
      noteForScController.dispose();

      _showMessage(
        'Invalid patient ID.',
      );

      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder:
              (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title:
              const Text(
                'Patient Details / Edit',
              ),

              content: SizedBox(
                width: 500,

                child:
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [
                      TextField(
                        controller:
                        nameController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Name',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextField(
                        controller:
                        phoneController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Phone',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextField(
                        controller:
                        addressController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Address',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      InkWell(
                        onTap:
                        saving
                            ? null
                            : () async {
                          final picked =
                          await showDatePicker(
                            context:
                            context,
                            initialDate:
                            selectedDob ??
                                DateTime.now(),
                            firstDate:
                            DateTime(
                              1900,
                            ),
                            lastDate:
                            DateTime(
                              2100,
                            ),
                          );

                          if (picked !=
                              null) {
                            setDialogState(
                                  () {
                                selectedDob =
                                    picked;
                              },
                            );
                          }
                        },

                        child:
                        InputDecorator(
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Date of Birth',
                            border:
                            OutlineInputBorder(),
                            suffixIcon:
                            Icon(
                              Icons
                                  .calendar_month,
                            ),
                          ),

                          child:
                          Text(
                            selectedDob ==
                                null
                                ? ''
                                : _formatDate(
                              selectedDob,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextField(
                        controller:
                        importantNoteController,
                        maxLines: 2,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Important Note',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextField(
                        controller:
                        noteForScController,
                        maxLines: 2,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Notes',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed:
                  saving
                      ? null
                      : () async {
                    if (nameController
                        .text
                        .trim()
                        .isEmpty) {
                      ScaffoldMessenger
                          .of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Name is required.',
                          ),
                        ),
                      );

                      return;
                    }

                    setDialogState(
                          () {
                        saving = true;
                      },
                    );

                    try {
                      await PatiantsApiService
                          .updatePatient(
                        id: id,
                        name:
                        nameController
                            .text
                            .trim(),
                        phone:
                        phoneController
                            .text
                            .trim(),
                        address:
                        addressController
                            .text
                            .trim(),
                        dob:
                        selectedDob,
                        userId:
                        userId,
                        dor:
                        dor,
                        importantNote:
                        importantNoteController
                            .text
                            .trim(),
                        noteForSc:
                        noteForScController
                            .text
                            .trim(),
                      );

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      _showMessage(
                        'Patient updated successfully.',
                      );

                      await _loadPatients();
                    } catch (e) {
                      setDialogState(
                            () {
                          saving = false;
                        },
                      );

                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger
                          .of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            'Update failed.\n$e',
                          ),
                        ),
                      );
                    }
                  },

                  child: saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    importantNoteController.dispose();
    noteForScController.dispose();
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _headerCell(
      String text,
      ) {
    return Container(
      height: 48,
      alignment:
      Alignment.center,
      padding:
      const EdgeInsets.all(6),
      color:
      const Color(0xFF4D88B5),

      child: Text(
        text,
        textAlign:
        TextAlign.center,

        style:
        const TextStyle(
          color: Colors.white,
          fontWeight:
          FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // =========================================================
  // DATA CELL
  // =========================================================

  Widget _dataCell({
    required int rowIndex,
    required String text,
  }) {
    return GestureDetector(
      onTap: () {
        _selectRow(rowIndex);
      },

      child: Container(
        height: 42,

        alignment:
        Alignment.center,

        color:
        selectedRow ==
            rowIndex
            ? Colors.blue
            .withOpacity(
          0.12,
        )
            : const Color(
          0xFFD3DFE9,
        ),

        child: Text(
          text,
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }

  // =========================================================
  // ACTION CELL
  // =========================================================

  Widget _actionCell({
    required int rowIndex,
    required bool delete,
  }) {
    return Container(
      height: 42,

      alignment:
      Alignment.center,

      color:
      selectedRow ==
          rowIndex
          ? Colors.blue
          .withOpacity(
        0.12,
      )
          : const Color(
        0xFFD3DFE9,
      ),

      child: TextButton(
        onPressed: loading
            ? null
            : () {
          if (delete) {
            _deleteRow(
              rowIndex,
            );
          } else {
            _showDetails(
              rowIndex,
            );
          }
        },

        style:
        TextButton.styleFrom(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),

          minimumSize:
          Size.zero,

          tapTargetSize:
          MaterialTapTargetSize
              .shrinkWrap,
        ),

        child: Text(
          delete
              ? 'Delete'
              : 'Details',

          style:
          const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    if (loading &&
        displayedPatients.isEmpty) {
      return const Padding(
        padding:
        EdgeInsets.all(30),

        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (displayedPatients
        .isEmpty) {
      return const Padding(
        padding:
        EdgeInsets.all(30),

        child: Center(
          child: Text(
            'No patients found.',
            style:
            TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,

      child: Table(
        defaultColumnWidth:
        const FixedColumnWidth(
          130,
        ),

        border:
        TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),

        children: [
          // ===================================================
          // HEADER
          // ===================================================

          TableRow(
            children: [
              _headerCell('No.'),
              _headerCell('Name'),
              _headerCell('Phone'),
              _headerCell(
                'Date of Birth',
              ),
              _headerCell('Address'),
              _headerCell('Notes'),
              _headerCell('Delete'),
              _headerCell('Details'),
            ],
          ),

          // ===================================================
          // REAL DATABASE ROWS
          // ===================================================

          ...List.generate(
            displayedPatients.length,
                (index) {
              final patient =
              displayedPatients[
              index];

              final id =
                  patient[
                  'patiantId'] ??
                      patient[
                      'PatiantId'] ??
                      patient[
                      'patiant_id'];

              final name =
                  patient['name'] ??
                      patient['Name'] ??
                      '';

              final phone =
                  patient['phone'] ??
                      patient['Phone'] ??
                      '';

              final dob =
                  patient['dob'] ??
                      patient['Dob'] ??
                      patient['DOB'];

              final address =
                  patient['address'] ??
                      patient['Address'] ??
                      '';

              final notes =
                  patient[
                  'noteForSc'] ??
                      patient[
                      'NoteForSc'] ??
                      '';

              return TableRow(
                children: [
                  _dataCell(
                    rowIndex: index,
                    text: id.toString(),
                  ),

                  _dataCell(
                    rowIndex: index,
                    text:
                    name.toString(),
                  ),

                  _dataCell(
                    rowIndex: index,
                    text:
                    phone.toString(),
                  ),

                  _dataCell(
                    rowIndex: index,
                    text:
                    _formatDate(
                      dob,
                    ),
                  ),

                  _dataCell(
                    rowIndex: index,
                    text:
                    address.toString(),
                  ),

                  _dataCell(
                    rowIndex: index,
                    text:
                    notes.toString(),
                  ),

                  _actionCell(
                    rowIndex: index,
                    delete: true,
                  ),

                  _actionCell(
                    rowIndex: index,
                    delete: false,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Edit Data',
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [
            const Text(
              'Search by Name',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
              searchController,

              textInputAction:
              TextInputAction.search,

              decoration:
              const InputDecoration(
                labelText: 'Name',
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(
                  Icons.person_search,
                ),
              ),

              onSubmitted: (_) {
                _search();
              },
            ),

            const SizedBox(
              height: 12,
            ),

            ElevatedButton.icon(
              onPressed:
              loading
                  ? null
                  : _search,

              icon:
              const Icon(
                Icons.search,
              ),

              label:
              const Text(
                'Search',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}