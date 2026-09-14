import 'package:flutter/material.dart';

class FaultsScreen extends StatefulWidget {
  const FaultsScreen({super.key});

  @override
  State<FaultsScreen> createState() => _FaultsScreenState();
}

class _FaultsScreenState extends State<FaultsScreen> {
  bool isAddFaultMode = true;

  final TextEditingController deviceNameController =
  TextEditingController();

  final TextEditingController faultDetailsController =
  TextEditingController();

  final TextEditingController faultNumberController =
  TextEditingController();

  int? selectedFaultIndex;

  // Empty for now.
  // These records will come from the database through the API later.
  final List<Map<String, String>> faults = [];

  @override
  void dispose() {
    deviceNameController.dispose();
    faultDetailsController.dispose();
    faultNumberController.dispose();
    super.dispose();
  }

  void _showAddFaultMode() {
    setState(() {
      isAddFaultMode = true;
      selectedFaultIndex = null;
    });
  }

  void _showMaintainMode() {
    setState(() {
      isAddFaultMode = false;
      selectedFaultIndex = null;
    });
  }

  void _addFault() {
    final deviceName = deviceNameController.text.trim();
    final faultDetails = faultDetailsController.text.trim();

    if (deviceName.isEmpty) {
      _showMessage('Please enter the device name.');
      return;
    }

    if (faultDetails.isEmpty) {
      _showMessage('Please enter the fault details.');
      return;
    }

    // Database/API will be connected here later.
    _showMessage(
      'Fault information is valid. Database saving will be connected later.',
    );
  }

  void _maintainFault() {
    final faultNumber = faultNumberController.text.trim();

    if (faultNumber.isEmpty) {
      _showMessage('Please enter the fault number.');
      return;
    }

    // Database/API will be connected here later.
    _showMessage(
      'Fault number is valid. Maintenance will be connected later.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _topButton({
    required String title,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: selected ? 2 : 0,
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            backgroundColor: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.white,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _table() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          headingRowHeight: 52,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(
              label: Text(
                'No.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Device Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Fault Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Date Added',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Accountant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: List.generate(
            faults.length,
                (index) {
              final fault = faults[index];

              return DataRow(
                selected: selectedFaultIndex == index,
                onSelectChanged: (_) {
                  setState(() {
                    selectedFaultIndex = index;
                  });
                },
                cells: [
                  DataCell(
                    Text('${index + 1}'),
                  ),
                  DataCell(
                    Text(fault['deviceName'] ?? ''),
                  ),
                  DataCell(
                    Text(fault['faultDetails'] ?? ''),
                  ),
                  DataCell(
                    Text(fault['dateAdded'] ?? ''),
                  ),
                  DataCell(
                    Text(fault['accountant'] ?? ''),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addFaultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Add Fault'),

        const SizedBox(height: 14),

        _textField(
          controller: deviceNameController,
          label: 'Device Name',
        ),

        const SizedBox(height: 14),

        _textField(
          controller: faultDetailsController,
          label: 'Fault Details',
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _addFault,
            child: const Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _maintainFaultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        _textField(
          controller: faultNumberController,
          label: 'Fault Number',
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _maintainFault,
            child: const Text(
              'Maintain',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faults'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top buttons
              Row(
                children: [
                  _topButton(
                    title: 'Add Fault',
                    selected: isAddFaultMode,
                    onPressed: _showAddFaultMode,
                  ),
                  const SizedBox(width: 12),
                  _topButton(
                    title: 'Maintain Current Fault',
                    selected: !isAddFaultMode,
                    onPressed: _showMaintainMode,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Add Fault / Maintain Current Fault
              if (isAddFaultMode)
                _addFaultSection()
              else
                _maintainFaultSection(),

              const SizedBox(height: 24),

              // Current Faults
              _sectionTitle('Current Faults'),

              _table(),
            ],
          ),
        ),
      ),
    );
  }
}