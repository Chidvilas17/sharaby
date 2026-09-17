import 'package:flutter/material.dart';
import '../../services/damages_api_service.dart';

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

  final TextEditingController accessNumberController =
  TextEditingController();

  final TextEditingController maintenanceCostController =
  TextEditingController();

  final TextEditingController maintenanceEngineerController =
  TextEditingController();

  final TextEditingController maintainFaultDetailsController =
  TextEditingController();

  int? selectedFaultIndex;

  int? maintainedFaultId;

  List<Map<String, dynamic>> faults = [];

  bool isLoadingFaults = false;
  bool isAddingFault = false;
  bool isLoadingMaintenanceFault = false;
  bool isSavingMaintenance = false;

  @override
  void initState() {
    super.initState();
    _loadFaults();
  }

  @override
  void dispose() {
    deviceNameController.dispose();
    faultDetailsController.dispose();
    faultNumberController.dispose();
    accessNumberController.dispose();
    maintenanceCostController.dispose();
    maintenanceEngineerController.dispose();
    maintainFaultDetailsController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD ALL FAULTS
  // =========================

  Future<void> _loadFaults() async {
    setState(() {
      isLoadingFaults = true;
    });

    try {
      final data =
      await DamagesApiService.getDamages();

      if (!mounted) return;

      setState(() {
        faults = data
            .map(
              (fault) =>
          Map<String, dynamic>.from(fault),
        )
            .toList();

        isLoadingFaults = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingFaults = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // ADD MODE
  // =========================

  void _showAddFaultMode() {
    setState(() {
      isAddFaultMode = true;
      selectedFaultIndex = null;
      maintainedFaultId = null;
    });
  }

  // =========================
  // MAINTAIN MODE
  // =========================

  void _showMaintainMode() {
    setState(() {
      isAddFaultMode = false;
      selectedFaultIndex = null;
    });
  }

  // =========================
  // ADD FAULT
  // =========================

  Future<void> _addFault() async {
    final deviceName =
    deviceNameController.text.trim();

    final faultDetails =
    faultDetailsController.text.trim();

    if (deviceName.isEmpty) {
      _showMessage(
        'Please enter the device name.',
      );
      return;
    }

    if (faultDetails.isEmpty) {
      _showMessage(
        'Please enter the fault details.',
      );
      return;
    }

    setState(() {
      isAddingFault = true;
    });

    try {
      await DamagesApiService.addDamage(
        deviceName: deviceName,
        damageDetails: faultDetails,
      );

      if (!mounted) return;

      deviceNameController.clear();
      faultDetailsController.clear();

      _showMessage(
        'Fault added successfully.',
      );

      await _loadFaults();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isAddingFault = false;
      });
    }
  }

  // =========================
  // LOAD FAULT FOR MAINTENANCE
  // =========================

  Future<void> _maintainFault() async {
    final faultNumberText =
    faultNumberController.text.trim();

    if (faultNumberText.isEmpty) {
      _showMessage(
        'Please enter the fault number.',
      );
      return;
    }

    final faultNumber =
    int.tryParse(faultNumberText);

    if (faultNumber == null) {
      _showMessage(
        'Fault number must be a number.',
      );
      return;
    }

    setState(() {
      isLoadingMaintenanceFault = true;
      maintainedFaultId = null;
    });

    try {
      final fault =
      await DamagesApiService.getDamage(
        faultNumber,
      );

      if (!mounted) return;

      final cost =
          fault['cost']?.toString() ?? '';

      final waslNo =
          fault['wasl_no']?.toString() ?? '';

      final byEng =
          fault['byEng']?.toString() ?? '';

      final damageDetails =
          fault['damageDetails']?.toString() ?? '';

      setState(() {
        maintainedFaultId =
        fault['id'] as int?;

        accessNumberController.text =
            waslNo;

        maintenanceCostController.text =
        cost == '0' ? '' : cost;

        maintenanceEngineerController.text =
            byEng;

        maintainFaultDetailsController.text =
            damageDetails;

        isLoadingMaintenanceFault = false;
      });

      _showMessage(
        'Fault loaded successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMaintenanceFault = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // SAVE MAINTENANCE
  // =========================

  Future<void> _saveMaintenance() async {
    if (maintainedFaultId == null) {
      _showMessage(
        'Please enter a fault number and click Maintain first.',
      );
      return;
    }

    final accessNumber =
    accessNumberController.text.trim();

    final costText =
    maintenanceCostController.text.trim();

    final engineer =
    maintenanceEngineerController.text.trim();

    final faultDetails =
    maintainFaultDetailsController.text.trim();

    int cost = 0;

    if (costText.isNotEmpty) {
      final parsedCost =
      int.tryParse(costText);

      if (parsedCost == null) {
        _showMessage(
          'Maintenance cost must be a number.',
        );
        return;
      }

      cost = parsedCost;
    }

    if (faultDetails.isEmpty) {
      _showMessage(
        'Please enter the fault details.',
      );
      return;
    }

    setState(() {
      isSavingMaintenance = true;
    });

    try {
      await DamagesApiService.maintainDamage(
        id: maintainedFaultId!,
        waslNo: accessNumber,
        cost: cost,
        byEng: engineer,
        damageDetails: faultDetails,
      );

      if (!mounted) return;

      _showMessage(
        'Fault maintained successfully.',
      );

      await _loadFaults();

      if (!mounted) return;

      setState(() {
        isSavingMaintenance = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSavingMaintenance = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================
  // TOP BUTTON
  // =========================

  Widget _topButton({
    required String title,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed:
          isAddingFault ||
              isLoadingMaintenanceFault ||
              isSavingMaintenance
              ? null
              : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: selected ? 2 : 0,
            side: BorderSide(
              color: selected
                  ? Theme.of(context)
                  .colorScheme
                  .primary
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            backgroundColor: selected
                ? Theme.of(context)
                .colorScheme
                .primaryContainer
                : Colors.white,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Theme.of(context)
                  .colorScheme
                  .primary
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

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

  // =========================
  // TEXT FIELD
  // =========================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType =
        TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  // =========================
  // CURRENT FAULTS TABLE
  // =========================

  Widget _table() {
    if (isLoadingFaults) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (faults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: const Center(
          child: Text(
            'No faults found.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

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

              final id =
                  fault['id']?.toString() ?? '';

              final deviceName =
                  fault['deviceName']?.toString() ??
                      '';

              final faultDetails =
                  fault['damageDetails']
                      ?.toString() ??
                      '';

              final dateAdded =
                  fault['timeOfAdd']?.toString() ??
                      '';

              final accountant =
                  fault['user_IdOfAdd']
                      ?.toString() ??
                      '';

              return DataRow(
                selected:
                selectedFaultIndex == index,
                onSelectChanged: (_) {
                  setState(() {
                    selectedFaultIndex = index;
                  });
                },
                cells: [
                  DataCell(Text(id)),
                  DataCell(Text(deviceName)),
                  DataCell(Text(faultDetails)),
                  DataCell(Text(dateAdded)),
                  DataCell(Text(accountant)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // ADD FAULT SECTION
  // =========================

  Widget _addFaultSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Add Fault'),

        const SizedBox(height: 14),

        _textField(
          controller: deviceNameController,
          label: 'Device Name',
          enabled: !isAddingFault,
        ),

        const SizedBox(height: 14),

        _textField(
          controller: faultDetailsController,
          label: 'Fault Details',
          enabled: !isAddingFault,
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed:
            isAddingFault
                ? null
                : _addFault,
            child: isAddingFault
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // MAINTAIN FAULT SECTION
  // =========================

  Widget _maintainFaultSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _textField(
                controller:
                faultNumberController,
                label: 'Fault Number',
                keyboardType:
                TextInputType.number,
                enabled:
                !isLoadingMaintenanceFault &&
                    !isSavingMaintenance,
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              width: 110,
              height: 48,
              child: ElevatedButton(
                onPressed:
                isLoadingMaintenanceFault ||
                    isSavingMaintenance
                    ? null
                    : _maintainFault,
                child:
                isLoadingMaintenanceFault
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Maintain',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (maintainedFaultId != null)
          _maintenanceDetailsSection(),
      ],
    );
  }

  // =========================
  // MAINTENANCE DETAILS
  // =========================

  Widget _maintenanceDetailsSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        _sectionTitle(
          'Maintain Current Fault',
        ),

        const SizedBox(height: 14),

        _textField(
          controller:
          maintainFaultDetailsController,
          label: 'Fault Details',
          enabled: !isSavingMaintenance,
        ),

        const SizedBox(height: 14),

        _textField(
          controller:
          accessNumberController,
          label: 'Access Number',
          enabled: !isSavingMaintenance,
        ),

        const SizedBox(height: 14),

        _textField(
          controller:
          maintenanceCostController,
          label: 'Maintenance Cost',
          keyboardType:
          TextInputType.number,
          enabled: !isSavingMaintenance,
        ),

        const SizedBox(height: 14),

        _textField(
          controller:
          maintenanceEngineerController,
          label: 'Maintenance Engineer',
          enabled: !isSavingMaintenance,
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed:
            isSavingMaintenance
                ? null
                : _saveMaintenance,
            child: isSavingMaintenance
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
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
        title: const Text('Faults'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _topButton(
                    title: 'Add Fault',
                    selected: isAddFaultMode,
                    onPressed:
                    _showAddFaultMode,
                  ),

                  const SizedBox(width: 12),

                  _topButton(
                    title:
                    'Maintain Current Fault',
                    selected:
                    !isAddFaultMode,
                    onPressed:
                    _showMaintainMode,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (isAddFaultMode)
                _addFaultSection()
              else
                _maintainFaultSection(),

              const SizedBox(height: 24),

              _sectionTitle(
                'Current Faults',
              ),

              _table(),
            ],
          ),
        ),
      ),
    );
  }
}