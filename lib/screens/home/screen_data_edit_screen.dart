import 'package:flutter/material.dart';

class ScreenDataEditScreen extends StatefulWidget {
  const ScreenDataEditScreen({super.key});

  @override
  State<ScreenDataEditScreen> createState() =>
      _ScreenDataEditScreenState();
}

class _ScreenDataEditScreenState
    extends State<ScreenDataEditScreen> {
  // =========================
  // BOOKING
  // =========================

  final TextEditingController booking1Controller =
  TextEditingController(
    text: 'Entry by number',
  );

  final TextEditingController booking2Controller =
  TextEditingController(
    text: 'Booking by phone using individual number',
  );

  final TextEditingController booking3Controller =
  TextEditingController(
    text: 'Booking by attendance using spouse number',
  );

  final TextEditingController booking4Controller =
  TextEditingController();

  // =========================
  // ADMISSION
  // =========================

  final TextEditingController admission1Controller =
  TextEditingController(
    text:
    'Can book and attend, and when your turn is near the receptionist will contact you.',
  );

  final TextEditingController admission2Controller =
  TextEditingController(
    text:
    'Whoever is late for an appointment, the appointment is rescheduled 4 numbers from the first examination.',
  );

  final TextEditingController admission3Controller =
  TextEditingController();

  final TextEditingController admission4Controller =
  TextEditingController();

  // =========================
  // EXCEPTIONS
  // =========================

  final TextEditingController exception1Controller =
  TextEditingController(
    text: 'Newborn enters directly.',
  );

  final TextEditingController exception2Controller =
  TextEditingController(
    text: 'Newborns: maximum 4 examinations.',
  );

  final TextEditingController exception3Controller =
  TextEditingController(
    text: 'Emergency cases.',
  );

  final TextEditingController exception4Controller =
  TextEditingController(
    text: 'Medical doctors.',
  );

  @override
  void dispose() {
    booking1Controller.dispose();
    booking2Controller.dispose();
    booking3Controller.dispose();
    booking4Controller.dispose();

    admission1Controller.dispose();
    admission2Controller.dispose();
    admission3Controller.dispose();
    admission4Controller.dispose();

    exception1Controller.dispose();
    exception2Controller.dispose();
    exception3Controller.dispose();
    exception4Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Screen Data'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =====================================
            // BOOKING
            // =====================================

            _buildSection(
              title: 'Booking',
              children: [
                _buildPointField(
                  number: 1,
                  controller: booking1Controller,
                ),

                _buildPointField(
                  number: 2,
                  controller: booking2Controller,
                ),

                _buildPointField(
                  number: 3,
                  controller: booking3Controller,
                ),

                _buildPointField(
                  number: 4,
                  controller: booking4Controller,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================
            // ADMISSION
            // =====================================

            _buildSection(
              title: 'Admission',
              children: [
                _buildPointField(
                  number: 1,
                  controller: admission1Controller,
                ),

                _buildPointField(
                  number: 2,
                  controller: admission2Controller,
                ),

                _buildPointField(
                  number: 3,
                  controller: admission3Controller,
                ),

                _buildPointField(
                  number: 4,
                  controller: admission4Controller,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================
            // EXCEPTIONS
            // =====================================

            _buildSection(
              title: 'Exceptions',
              children: [
                _buildPointField(
                  number: 1,
                  controller: exception1Controller,
                ),

                _buildPointField(
                  number: 2,
                  controller: exception2Controller,
                ),

                _buildPointField(
                  number: 3,
                  controller: exception3Controller,
                ),

                _buildPointField(
                  number: 4,
                  controller: exception4Controller,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================
            // SAVE
            // =====================================

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =====================================
  // SECTION
  // =====================================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // =====================================
  // POINT FIELD
  // =====================================

  Widget _buildPointField({
    required int number,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Point $number',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter text',
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // SAVE
  // =====================================

  void _save() {
    // Database/API functionality will be connected later.
  }
}