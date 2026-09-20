import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/staff_employees_api_service.dart';

class StaffAddEditScreen extends StatefulWidget {
  const StaffAddEditScreen({super.key});

  @override
  State<StaffAddEditScreen> createState() =>
      _StaffAddEditScreenState();
}

class _StaffAddEditScreenState
    extends State<StaffAddEditScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController phone1Controller =
  TextEditingController();

  final TextEditingController phone2Controller =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController cardNumberController =
  TextEditingController();

  final TextEditingController searchIdController =
  TextEditingController();

  // ============================================================
  // JOBS
  // ============================================================

  List<Map<String, dynamic>> categories = [];

  bool loadingCategories = false;

  String? selectedJob;
  String? searchJob;

  // ============================================================
  // EMPLOYEES
  // ============================================================

  List<StaffEmployee> employees = [];

  bool loadingEmployees = false;
  bool savingEmployee = false;
  bool deletingEmployee = false;

  int? selectedRow;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadCategories();
    _loadEmployees();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    addressController.dispose();
    cardNumberController.dispose();
    searchIdController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> _loadCategories() async {
    setState(() {
      loadingCategories = true;
    });

    try {
      final result =
      await StaffEmployeesApiService
          .getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingCategories = false;
      });

      _message(
        'Failed to load jobs.\n$e',
      );
    }
  }

  // ============================================================
  // LOAD EMPLOYEES
  // ============================================================

  Future<void> _loadEmployees() async {
    setState(() {
      loadingEmployees = true;
    });

    try {
      final result =
      await StaffEmployeesApiService
          .getEmployees();

      if (!mounted) return;

      setState(() {
        employees =
            result.map(
                  (item) {
                return StaffEmployee.fromJson(
                  item,
                  categories,
                );
              },
            ).toList();

        loadingEmployees = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingEmployees = false;
      });

      _message(
        'Failed to load employees.\n$e',
      );
    }
  }

  // ============================================================
  // CONVERT EMPLOYEE
  // ============================================================

  StaffEmployee _employeeFromJson(
      Map<String, dynamic> item,
      ) {
    return StaffEmployee.fromJson(
      item,
      categories,
    );
  }

  // ============================================================
  // SAVE EMPLOYEE
  // ============================================================

  Future<void> _saveEmployee() async {
    final name =
    nameController.text.trim();

    final phone1 =
    phone1Controller.text.trim();

    final phone2 =
    phone2Controller.text.trim();

    final address =
    addressController.text.trim();

    final cardNumber =
    cardNumberController.text.trim();

    if (name.isEmpty) {
      _message(
        'Please enter the employee name.',
      );
      return;
    }

    if (selectedJob == null ||
        selectedJob == 'SELECT') {
      _message(
        'Please select the job.',
      );
      return;
    }

    if (phone1.isEmpty) {
      _message(
        'Please enter Phone 1.',
      );
      return;
    }

    if (address.isEmpty) {
      _message(
        'Please enter the address.',
      );
      return;
    }

    if (cardNumber.isEmpty) {
      _message(
        'Please enter the card number.',
      );
      return;
    }

    final catId =
    int.tryParse(selectedJob!);

    if (catId == null) {
      _message(
        'Invalid job selected.',
      );
      return;
    }

    setState(() {
      savingEmployee = true;
    });

    try {
      final newId =
      await StaffEmployeesApiService
          .addEmployee(
        name: name,
        phone1: phone1,
        phone2: phone2,
        address: address,
        cardNumber: cardNumber,
        catId: catId,
      );

      if (!mounted) return;

      _clearNewEmployeeFields();

      await _loadEmployees();

      if (!mounted) return;

      setState(() {
        savingEmployee = false;
      });

      _message(
        'Employee added successfully. ID: $newId',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingEmployee = false;
      });

      _message(
        'Failed to save employee.\n$e',
      );
    }
  }

  // ============================================================
  // CLEAR NEW EMPLOYEE FIELDS
  // ============================================================

  void _clearNewEmployeeFields() {
    nameController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    addressController.clear();
    cardNumberController.clear();

    selectedJob = null;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    if (searchJob == null ||
        searchJob == 'SELECT') {
      _message(
        'Please select a field to search.',
      );
      return;
    }

    final catId =
    int.tryParse(searchJob!);

    if (catId == null) {
      _message(
        'Invalid job selected.',
      );
      return;
    }

    setState(() {
      loadingEmployees = true;
      selectedRow = null;
    });

    try {
      final result =
      await StaffEmployeesApiService
          .searchEmployees(
        catId: catId,
      );

      if (!mounted) return;

      setState(() {
        employees =
            result.map(
                  (item) {
                return _employeeFromJson(
                  item,
                );
              },
            ).toList();

        loadingEmployees = false;
      });

      _message(
        '${employees.length} employee(s) found.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingEmployees = false;
      });

      _message(
        'Search failed.\n$e',
      );
    }
  }

  // ============================================================
  // LOAD ALL
  // ============================================================

  Future<void> _loadAllEmployees() async {
    await _loadEmployees();

    if (!mounted) return;

    setState(() {
      searchJob = null;
      selectedRow = null;
    });
  }

  // ============================================================
  // EDIT SELECTED
  // ============================================================

  Future<void> _editSelected() async {
    int? employeeId;

    final typedId =
    int.tryParse(
      searchIdController.text.trim(),
    );

    if (typedId != null) {
      employeeId = typedId;
    } else if (selectedRow != null &&
        selectedRow! >= 0 &&
        selectedRow! < employees.length) {
      employeeId =
          employees[selectedRow!].id;
    }

    if (employeeId == null) {
      _message(
        'Please select an employee first.',
      );
      return;
    }

    final name =
    nameController.text.trim();

    final phone1 =
    phone1Controller.text.trim();

    final phone2 =
    phone2Controller.text.trim();

    final address =
    addressController.text.trim();

    final cardNumber =
    cardNumberController.text.trim();

    if (name.isEmpty ||
        selectedJob == null ||
        selectedJob == 'SELECT' ||
        phone1.isEmpty ||
        address.isEmpty ||
        cardNumber.isEmpty) {
      _message(
        'Enter the employee data above before pressing Edit.',
      );
      return;
    }

    final catId =
    int.tryParse(selectedJob!);

    if (catId == null) {
      _message(
        'Invalid job selected.',
      );
      return;
    }

    setState(() {
      savingEmployee = true;
    });

    try {
      await StaffEmployeesApiService
          .updateEmployee(
        id: employeeId,
        name: name,
        phone1: phone1,
        phone2: phone2,
        address: address,
        cardNumber: cardNumber,
        catId: catId,
      );

      if (!mounted) return;

      await _loadEmployees();

      if (!mounted) return;

      setState(() {
        savingEmployee = false;
        searchIdController.clear();
        selectedRow = null;
      });

      _message(
        'Employee updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        savingEmployee = false;
      });

      _message(
        'Failed to update employee.\n$e',
      );
    }
  }

  // ============================================================
  // DELETE SELECTED
  // ============================================================

  Future<void> _deleteSelected() async {
    int? employeeId;

    final typedId =
    int.tryParse(
      searchIdController.text.trim(),
    );

    if (typedId != null) {
      employeeId = typedId;
    } else if (selectedRow != null &&
        selectedRow! >= 0 &&
        selectedRow! < employees.length) {
      employeeId =
          employees[selectedRow!].id;
    }

    if (employeeId == null) {
      _message(
        'Please select an employee first.',
      );
      return;
    }

    String employeeName = '';

    for (final employee in employees) {
      if (employee.id == employeeId) {
        employeeName =
            employee.name;
        break;
      }
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTranslations.tr('Delete Employee'),
          ),
          content: Text(
            employeeName.isEmpty
                ? 'Are you sure you want to delete employee ID $employeeId?'
                : 'Are you sure you want to delete $employeeName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(AppTranslations.tr('Cancel'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(AppTranslations.tr('Delete'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      deletingEmployee = true;
    });

    try {
      await StaffEmployeesApiService
          .deleteEmployee(
        employeeId,
      );

      if (!mounted) return;

      await _loadEmployees();

      if (!mounted) return;

      setState(() {
        deletingEmployee = false;
        selectedRow = null;
        searchIdController.clear();
      });

      _clearNewEmployeeFields();

      _message(
        employeeName.isEmpty
            ? 'Employee deleted.'
            : '$employeeName deleted.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deletingEmployee = false;
      });

      _message(
        'Failed to delete employee.\n$e',
      );
    }
  }

  // ============================================================
  // LOAD SELECTED EMPLOYEE
  // ============================================================

  void _loadSelectedEmployee(
      int index,
      ) {
    if (index < 0 ||
        index >= employees.length) {
      return;
    }

    final employee =
    employees[index];

    setState(() {
      selectedRow = index;

      nameController.text =
          employee.name;

      phone1Controller.text =
          employee.phone1;

      phone2Controller.text =
          employee.phone2;

      addressController.text =
          employee.address;

      cardNumberController.text =
          employee.cardNumber;

      selectedJob =
          employee.catId.toString();

      searchIdController.text =
          employee.id.toString();
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration:
        InputDecoration(
          labelText: AppTranslations.tr(label),
          border:
          const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ============================================================
  // JOB DROPDOWN
  // ============================================================

  Widget _jobDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?>
    onChanged,
  }) {
    if (loadingCategories) {
      return Padding(
        padding:
        const EdgeInsets.only(
          bottom: 12,
        ),
        child: InputDecorator(
          decoration:
          InputDecoration(
            labelText: AppTranslations.tr(label),
            border:
            const OutlineInputBorder(),
          ),
          child: Center(
            child: Padding(
              padding:
              EdgeInsets.symmetric(
                vertical: 8,
              ),
              child:
              CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child:
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration:
        InputDecoration(
          labelText: AppTranslations.tr(label),
          border:
          const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem<String>(
            value: 'SELECT',
            child: Text(AppTranslations.tr('Select')),
          ),

          ...categories.map(
                (category) {
              return DropdownMenuItem<
                  String>(
                value:
                category['id']
                    .toString(),
                child: Text(
                  category['name']
                      ?.toString() ??
                      '',
                ),
              );
            },
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        AppTranslations.tr(title),
        textAlign:
        TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE TABLE
  // ============================================================

  Widget _employeeTable() {
    if (loadingEmployees) {
      return SizedBox(
        height: 300,
        child: Center(
          child:
          CircularProgressIndicator(),
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
          TableRow(
            decoration:
            const BoxDecoration(
              color:
              Color(0xFF4D88B5),
            ),
            children: [
              _HeaderCell('ID'),
              _HeaderCell('Name'),
              _HeaderCell('Phone 1'),
              _HeaderCell('Phone 2'),
              _HeaderCell(
                'Card Number',
              ),
              _HeaderCell(
                'Address',
              ),
            ],
          ),

          if (employees.isEmpty)
            ...List.generate(
              12,
                  (index) =>
                  _emptyRow(index),
            )
          else
            ...employees
                .asMap()
                .entries
                .map(
                  (entry) {
                final index =
                    entry.key;

                final employee =
                    entry.value;

                final selected =
                    selectedRow ==
                        index;

                return TableRow(
                  children: [
                    _dataCell(
                      '${employee.id}',
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),

                    _dataCell(
                      employee.name,
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),

                    _dataCell(
                      employee.phone1,
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),

                    _dataCell(
                      employee.phone2,
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),

                    _dataCell(
                      employee
                          .cardNumber,
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),

                    _dataCell(
                      employee.address,
                      selected,
                          () =>
                          _loadSelectedEmployee(
                            index,
                          ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY ROW
  // ============================================================

  TableRow _emptyRow(
      int index,
      ) {
    return TableRow(
      children:
      List.generate(
        6,
            (column) {
          return Container(
            height: 40,
            alignment:
            Alignment.center,
            child: column == 0
                ? Text(
              '${index + 1}',
            )
                : const Text(''),
          );
        },
      ),
    );
  }

  // ============================================================
  // DATA CELL
  // ============================================================

  Widget _dataCell(
      String text,
      bool selected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment:
        Alignment.center,
        padding:
        const EdgeInsets.all(5),
        color: selected
            ? Colors.blue
            .withValues(alpha: 0.15)
            : Colors.transparent,
        child: Text(
          AppTranslations.tr(text),
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Add / Edit Employee'),
        ),
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [
            // ==================================================
            // NEW EMPLOYEE
            // ==================================================

            _sectionTitle(
              'New Employee',
            ),

            _textField(
              label: 'Name',
              controller:
              nameController,
            ),

            _jobDropdown(
              label: 'Job',
              value: selectedJob,
              onChanged:
                  (value) {
                setState(() {
                  selectedJob =
                      value;
                });
              },
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
              label: 'Address',
              controller:
              addressController,
            ),

            _textField(
              label: 'Card Number',
              controller:
              cardNumberController,
              keyboardType:
              TextInputType.number,
            ),

            ElevatedButton.icon(
              onPressed:
              savingEmployee
                  ? null
                  : _saveEmployee,
              icon: savingEmployee
                  ? SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                ),
              )
                  : const Icon(
                Icons
                    .save_outlined,
              ),
              label: Text(
                savingEmployee
                    ? 'Saving...'
                    : 'Save',
              ),
            ),

            SizedBox(
              height: 30,
            ),

            // ==================================================
            // SEARCH
            // ==================================================

            _sectionTitle(
              'Search by Field',
            ),

            _jobDropdown(
              label:
              'Search by Job',
              value: searchJob,
              onChanged:
                  (value) {
                setState(() {
                  searchJob =
                      value;
                });
              },
            ),

            Row(
              children: [
                Expanded(
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    _search,
                    icon:
                    const Icon(
                      Icons.search,
                    ),
                    label:
                    Text(AppTranslations.tr('Search'),
                    ),
                  ),
                ),

                SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                  ElevatedButton(
                    onPressed:
                    _loadAllEmployees,
                    child:
                    Text(AppTranslations.tr('All'),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 20,
            ),

            // ==================================================
            // TABLE
            // ==================================================

            Container(
              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  Colors.grey,
                ),
              ),
              child:
              _employeeTable(),
            ),

            SizedBox(
              height: 16,
            ),

            // ==================================================
            // ID
            // ==================================================

            _textField(
              label: 'ID',
              controller:
              searchIdController,
              keyboardType:
              TextInputType.number,
            ),

            // ==================================================
            // EDIT / DELETE
            // ==================================================

            Row(
              children: [
                Expanded(
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    savingEmployee
                        ? null
                        : _editSelected,
                    icon:
                    const Icon(
                      Icons
                          .edit_outlined,
                    ),
                    label:
                    Text(AppTranslations.tr('Edit'),
                    ),
                  ),
                ),

                SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    deletingEmployee
                        ? null
                        : _deleteSelected,
                    icon:
                    deletingEmployee
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Icon(
                      Icons
                          .delete_outline,
                    ),
                    label:
                    Text(
                      deletingEmployee
                          ? 'Deleting...'
                          : 'Delete',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STAFF EMPLOYEE MODEL
// ================================================================

class StaffEmployee {
  final int id;
  final String name;
  final String phone1;
  final String phone2;
  final String address;
  final String cardNumber;
  final int? catId;
  final String job;

  StaffEmployee({
    required this.id,
    required this.name,
    required this.phone1,
    required this.phone2,
    required this.address,
    required this.cardNumber,
    required this.catId,
    required this.job,
  });

  factory StaffEmployee.fromJson(
      Map<String, dynamic> json,
      List<Map<String, dynamic>>
      categories,
      ) {
    final catId =
    json['catId'] as int?;

    String job = '';

    for (final category in categories) {
      if (category['id']
          .toString() ==
          catId?.toString()) {
        job =
            category['name']
                ?.toString() ??
                '';
        break;
      }
    }

    return StaffEmployee(
      id: json['id'] ?? 0,
      name:
      json['name']?.toString() ??
          '',
      phone1:
      json['phone1']
          ?.toString() ??
          '',
      phone2:
      json['phone2']
          ?.toString() ??
          '',
      address:
      json['address']
          ?.toString() ??
          '',
      cardNumber:
      json['cardNumber']
          ?.toString() ??
          '',
      catId: catId,
      job: job,
    );
  }
}

// ================================================================
// HEADER CELL
// ================================================================

class _HeaderCell
    extends StatelessWidget {
  final String text;

  const _HeaderCell(
      this.text,
      );

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 48,
      alignment:
      Alignment.center,
      padding:
      const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          color: Colors.white,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}