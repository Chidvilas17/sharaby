import 'package:flutter/material.dart';

class OxygenSterilizationScreen extends StatefulWidget {
  const OxygenSterilizationScreen({super.key});

  @override
  State<OxygenSterilizationScreen> createState() =>
      _OxygenSterilizationScreenState();
}

class _OxygenSterilizationScreenState
    extends State<OxygenSterilizationScreen> {
  final TextEditingController oxygenPriceController =
  TextEditingController();

  final TextEditingController materialTypeController =
  TextEditingController();

  final TextEditingController unitPriceController =
  TextEditingController();

  @override
  void dispose() {
    oxygenPriceController.dispose();
    materialTypeController.dispose();
    unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oxygen & Sterilization Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =====================================
            // OXYGEN CYLINDER PRICE
            // =====================================

            _buildSection(
              title: 'Oxygen Cylinder Price',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: oxygenPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter oxygen cylinder price',
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================
            // ADD STERILIZATION MATERIAL
            // =====================================

            _buildSection(
              title: 'Add Sterilization Material',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: materialTypeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter material type',
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Unit Price',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: unitPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter unit price',
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================
            // CURRENT STERILIZATION MATERIALS
            // =====================================

            const Text(
              'Current Sterilization Materials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Unit Price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Empty for now.
                    // Data will come from the database later.
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No data',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}