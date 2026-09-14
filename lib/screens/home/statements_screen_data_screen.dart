import 'package:flutter/material.dart';

class StatementsScreenDataScreen extends StatefulWidget {
  const StatementsScreenDataScreen({super.key});

  @override
  State<StatementsScreenDataScreen> createState() =>
      _StatementsScreenDataScreenState();
}

class _StatementsScreenDataScreenState
    extends State<StatementsScreenDataScreen> {
  final TextEditingController bookingTitleController =
  TextEditingController(text: 'احجز');

  final TextEditingController bookingPoint1Controller =
  TextEditingController(text: 'الدخول بالأرقام');

  final TextEditingController bookingPoint2Controller =
  TextEditingController(text: 'الحجز بالتليفون - بأخذ رقم فردي');

  final TextEditingController bookingPoint3Controller =
  TextEditingController(text: 'الحجز بالحضور - بأخذ رقم زوجي');

  final TextEditingController bookingPoint4Controller =
  TextEditingController();

  final TextEditingController entryTitleController =
  TextEditingController(text: 'الدخول');

  final TextEditingController entryPoint1Controller =
  TextEditingController(
    text: '1- ممكن تحجز وتمشي ولما يقرب دورك الريسبشن هيتصل بك.',
  );

  final TextEditingController entryPoint2Controller =
  TextEditingController(
    text: '2- من يتأخر عن دورة يتم ترحيل دورة 4 ارقام من اول كشف.',
  );

  final TextEditingController entryPoint3Controller =
  TextEditingController();

  final TextEditingController entryPoint4Controller =
  TextEditingController();

  final TextEditingController exceptionsTitleController =
  TextEditingController(text: 'الإستثناءات');

  final TextEditingController exceptionPoint1Controller =
  TextEditingController(
    text: '1- مولود اليوم يدخل مباشر.',
  );

  final TextEditingController exceptionPoint2Controller =
  TextEditingController(
    text: '2- حديثي الولادة 4 كشوفات بحد اقصى.',
  );

  final TextEditingController exceptionPoint3Controller =
  TextEditingController(
    text: '3- حالات الطوارئ.',
  );

  final TextEditingController exceptionPoint4Controller =
  TextEditingController(
    text: '4- الاطباء البشريين.',
  );

  @override
  void dispose() {
    bookingTitleController.dispose();
    bookingPoint1Controller.dispose();
    bookingPoint2Controller.dispose();
    bookingPoint3Controller.dispose();
    bookingPoint4Controller.dispose();

    entryTitleController.dispose();
    entryPoint1Controller.dispose();
    entryPoint2Controller.dispose();
    entryPoint3Controller.dispose();
    entryPoint4Controller.dispose();

    exceptionsTitleController.dispose();
    exceptionPoint1Controller.dispose();
    exceptionPoint2Controller.dispose();
    exceptionPoint3Controller.dispose();
    exceptionPoint4Controller.dispose();

    super.dispose();
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _section({
    required String sectionName,
    required TextEditingController titleController,
    required List<TextEditingController> points,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          sectionName,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        _textField(
          label: 'Title',
          controller: titleController,
          bold: true,
        ),

        ...List.generate(points.length, (index) {
          return _textField(
            label: 'Point ${index + 1}',
            controller: points[index],
          );
        }),

        const SizedBox(height: 14),
      ],
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Screen data saved locally. Database saving will be connected later.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section(
              sectionName: 'Booking',
              titleController: bookingTitleController,
              points: [
                bookingPoint1Controller,
                bookingPoint2Controller,
                bookingPoint3Controller,
                bookingPoint4Controller,
              ],
            ),

            const Divider(thickness: 1),

            const SizedBox(height: 12),

            _section(
              sectionName: 'Entry',
              titleController: entryTitleController,
              points: [
                entryPoint1Controller,
                entryPoint2Controller,
                entryPoint3Controller,
                entryPoint4Controller,
              ],
            ),

            const Divider(thickness: 1),

            const SizedBox(height: 12),

            _section(
              sectionName: 'Exceptions',
              titleController: exceptionsTitleController,
              points: [
                exceptionPoint1Controller,
                exceptionPoint2Controller,
                exceptionPoint3Controller,
                exceptionPoint4Controller,
              ],
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}