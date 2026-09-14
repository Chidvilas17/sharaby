import 'package:flutter/material.dart';

class StaffAddEditScreen extends StatefulWidget {
  const StaffAddEditScreen({super.key});

  @override
  State<StaffAddEditScreen> createState() => _StaffAddEditScreenState();
}

class _StaffAddEditScreenState extends State<StaffAddEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController searchIdController = TextEditingController();

  String? selectedJob;
  String? searchJob;

  int? selectedRow;

  final List<StaffEmployee> employees = [];

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

  void _saveEmployee() {
    final name = nameController.text.trim();
    final phone1 = phone1Controller.text.trim();
    final address = addressController.text.trim();
    final cardNumber = cardNumberController.text.trim();

    if (name.isEmpty) {
      _message('Please enter the employee name.');
      return;
    }

    if (selectedJob == null || selectedJob == 'SELECT') {
      _message('Please select the job.');
      return;
    }

    if (phone1.isEmpty) {
      _message('Please enter Phone 1.');
      return;
    }

    if (address.isEmpty) {
      _message('Please enter the address.');
      return;
    }

    if (cardNumber.isEmpty) {
      _message('Please enter the card number.');
      return;
    }

    setState(() {
      employees.add(
        StaffEmployee(
          id: employees.length + 1,
          name: name,
          job: selectedJob!,
          phone1: phone1,
          phone2: phone2Controller.text.trim(),
          address: address,
          cardNumber: cardNumber,
        ),
      );

      _clearNewEmployeeFields();
    });

    _message('Employee added successfully.');
  }

  void _clearNewEmployeeFields() {
    nameController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    addressController.clear();
    cardNumberController.clear();

    selectedJob = null;
  }

  void _search() {
    if (searchJob == null || searchJob == 'SELECT') {
      _message('Please select a field to search.');
      return;
    }

    _message(
      'Search completed. Database results will appear after API connection.',
    );
  }

  void _editSelected() {
    if (selectedRow == null ||
        selectedRow! < 0 ||
        selectedRow! >= employees.length) {
      _message('Please select an employee first.');
      return;
    }

    final employee = employees[selectedRow!];

    final name = nameController.text.trim();
    final phone1 = phone1Controller.text.trim();
    final phone2 = phone2Controller.text.trim();
    final address = addressController.text.trim();
    final cardNumber = cardNumberController.text.trim();

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

    setState(() {
      employees[selectedRow!] = StaffEmployee(
        id: employee.id,
        name: name,
        job: selectedJob!,
        phone1: phone1,
        phone2: phone2,
        address: address,
        cardNumber: cardNumber,
      );
    });

    _message('Employee updated successfully.');
  }

  void _deleteSelected() {
    if (selectedRow == null ||
        selectedRow! < 0 ||
        selectedRow! >= employees.length) {
      _message('Please select an employee first.');
      return;
    }

    final employeeName = employees[selectedRow!].name;

    setState(() {
      employees.removeAt(selectedRow!);
      selectedRow = null;
    });

    _message('$employeeName deleted.');
  }

  void _loadSelectedEmployee(int index) {
    if (index < 0 || index >= employees.length) return;

    final employee = employees[index];

    setState(() {
      selectedRow = index;

      nameController.text = employee.name;
      phone1Controller.text = employee.phone1;
      phone2Controller.text = employee.phone2;
      addressController.text = employee.address;
      cardNumberController.text = employee.cardNumber;
      selectedJob = employee.job;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _jobDropdown({
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
          DropdownMenuItem<String>(
            value: 'SELECT',
            child: Text('Select'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _employeeTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(130),
        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF4D88B5),
            ),
            children: const [
              _HeaderCell('ID'),
              _HeaderCell('Name'),
              _HeaderCell('Phone 1'),
              _HeaderCell('Phone 2'),
              _HeaderCell('Card Number'),
              _HeaderCell('Address'),
            ],
          ),

          if (employees.isEmpty)
            ...List.generate(
              12,
                  (index) => _emptyRow(index),
            )
          else
            ...employees.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final employee = entry.value;
                final selected = selectedRow == index;

                return TableRow(
                  children: [
                    _dataCell(
                      '${employee.id}',
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                    _dataCell(
                      employee.name,
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                    _dataCell(
                      employee.phone1,
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                    _dataCell(
                      employee.phone2,
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                    _dataCell(
                      employee.cardNumber,
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                    _dataCell(
                      employee.address,
                      selected,
                          () => _loadSelectedEmployee(index),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  TableRow _emptyRow(int index) {
    return TableRow(
      children: List.generate(
        6,
            (column) => Container(
          height: 40,
          alignment: Alignment.center,
          child: column == 0
              ? Text('${index + 1}')
              : const Text(''),
        ),
      ),
    );
  }

  Widget _dataCell(
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
            ? Colors.blue.withOpacity(0.15)
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add / Edit Employee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NEW EMPLOYEE
            _sectionTitle('New Employee'),

            _textField(
              label: 'Name',
              controller: nameController,
            ),

            _jobDropdown(
              label: 'Job',
              value: selectedJob,
              onChanged: (value) {
                setState(() {
                  selectedJob = value;
                });
              },
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
              label: 'Address',
              controller: addressController,
            ),

            _textField(
              label: 'Card Number',
              controller: cardNumberController,
              keyboardType: TextInputType.number,
            ),

            ElevatedButton.icon(
              onPressed: _saveEmployee,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),

            const SizedBox(height: 30),

            // SEARCH
            _sectionTitle('Search by Field'),

            _jobDropdown(
              label: 'Search by Job',
              value: searchJob,
              onChanged: (value) {
                setState(() {
                  searchJob = value;
                });
              },
            ),

            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),

            const SizedBox(height: 20),

            // TABLE
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: _employeeTable(),
            ),

            const SizedBox(height: 16),

            // EDIT / DELETE
            _textField(
              label: 'ID',
              controller: searchIdController,
              keyboardType: TextInputType.number,
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editSelected,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class StaffEmployee {
  final int id;
  final String name;
  final String job;
  final String phone1;
  final String phone2;
  final String address;
  final String cardNumber;

  StaffEmployee({
    required this.id,
    required this.name,
    required this.job,
    required this.phone1,
    required this.phone2,
    required this.address,
    required this.cardNumber,
  });
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}