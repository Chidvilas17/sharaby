import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';

import '../../services/screen_data_api_service.dart';

class StatementsScreenDataScreen extends StatefulWidget {
  const StatementsScreenDataScreen({super.key});

  @override
  State<StatementsScreenDataScreen> createState() =>
      _StatementsScreenDataScreenState();
}

class _StatementsScreenDataScreenState
    extends State<StatementsScreenDataScreen> {
  // =========================================================
  // BOOKING
  // =========================================================

  final TextEditingController bookingTitleController =
  TextEditingController();

  final TextEditingController bookingPoint1Controller =
  TextEditingController();

  final TextEditingController bookingPoint2Controller =
  TextEditingController();

  final TextEditingController bookingPoint3Controller =
  TextEditingController();

  final TextEditingController bookingPoint4Controller =
  TextEditingController();

  // =========================================================
  // ENTRY
  // =========================================================

  final TextEditingController entryTitleController =
  TextEditingController();

  final TextEditingController entryPoint1Controller =
  TextEditingController();

  final TextEditingController entryPoint2Controller =
  TextEditingController();

  final TextEditingController entryPoint3Controller =
  TextEditingController();

  final TextEditingController entryPoint4Controller =
  TextEditingController();

  // =========================================================
  // EXCEPTIONS
  // =========================================================

  final TextEditingController exceptionsTitleController =
  TextEditingController();

  final TextEditingController exceptionPoint1Controller =
  TextEditingController();

  final TextEditingController exceptionPoint2Controller =
  TextEditingController();

  final TextEditingController exceptionPoint3Controller =
  TextEditingController();

  final TextEditingController exceptionPoint4Controller =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadScreenData();
  }

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

  // =========================================================
  // LOAD DATABASE DATA
  // =========================================================

  Future<void> _loadScreenData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final rows =
      await ScreenDataApiService.getAll();

      for (final row in rows) {
        final id = int.tryParse(
          (
              row['flashID'] ??
                  row['FlashID'] ??
                  ''
          ).toString(),
        );

        final type =
        (
            row['type'] ??
                row['Type'] ??
                ''
        ).toString();

        final text1 =
        (
            row['text1'] ??
                row['Text1'] ??
                ''
        ).toString();

        final text2 =
        (
            row['text2'] ??
                row['Text2'] ??
                ''
        ).toString();

        final text3 =
        (
            row['text3'] ??
                row['Text3'] ??
                ''
        ).toString();

        final text4 =
        (
            row['text4'] ??
                row['Text4'] ??
                ''
        ).toString();

        if (id == 1) {
          bookingTitleController.text = type;
          bookingPoint1Controller.text = text1;
          bookingPoint2Controller.text = text2;
          bookingPoint3Controller.text = text3;
          bookingPoint4Controller.text = text4;
        }

        if (id == 2) {
          entryTitleController.text = type;
          entryPoint1Controller.text = text1;
          entryPoint2Controller.text = text2;
          entryPoint3Controller.text = text3;
          entryPoint4Controller.text = text4;
        }

        if (id == 3) {
          exceptionsTitleController.text = type;
          exceptionPoint1Controller.text = text1;
          exceptionPoint2Controller.text = text2;
          exceptionPoint3Controller.text = text3;
          exceptionPoint4Controller.text = text4;
        }
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Failed to load screen data.\n$e',
      );
    }
  }

  // =========================================================
  // SAVE ALL 3 ROWS
  // =========================================================

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      // Booking
      await ScreenDataApiService.update(
        id: 1,
        type: bookingTitleController.text.trim(),
        text1: bookingPoint1Controller.text.trim(),
        text2: bookingPoint2Controller.text.trim(),
        text3: bookingPoint3Controller.text.trim(),
        text4: bookingPoint4Controller.text.trim(),
      );

      // Entry
      await ScreenDataApiService.update(
        id: 2,
        type: entryTitleController.text.trim(),
        text1: entryPoint1Controller.text.trim(),
        text2: entryPoint2Controller.text.trim(),
        text3: entryPoint3Controller.text.trim(),
        text4: entryPoint4Controller.text.trim(),
      );

      // Exceptions
      await ScreenDataApiService.update(
        id: 3,
        type: exceptionsTitleController.text.trim(),
        text1: exceptionPoint1Controller.text.trim(),
        text2: exceptionPoint2Controller.text.trim(),
        text3: exceptionPoint3Controller.text.trim(),
        text4: exceptionPoint4Controller.text.trim(),
      );

      if (!mounted) return;

      _showMessage(
        'Screen data saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save screen data.\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: AppTranslations.tr(label),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          fontSize: 16,
          fontWeight:
          bold
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  // =========================================================
  // SECTION
  // =========================================================

  Widget _section({
    required String sectionName,
    required TextEditingController titleController,
    required List<TextEditingController> points,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Text(
          sectionName,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8),

        _textField(
          label: 'Title',
          controller: titleController,
          bold: true,
        ),

        ...List.generate(
          points.length,
              (index) {
            return _textField(
              label: 'Point ${index + 1}',
              controller: points[index],
            );
          },
        ),

        SizedBox(height: 14),
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
        title: Text(AppTranslations.tr('Screen Data'),
        ),
      ),
      body: SafeArea(
        child:
        isLoading
            ? Center(
          child:
          CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
            children: [
              // =========================
              // BOOKING
              // =========================

              _section(
                sectionName:
                'Booking',
                titleController:
                bookingTitleController,
                points: [
                  bookingPoint1Controller,
                  bookingPoint2Controller,
                  bookingPoint3Controller,
                  bookingPoint4Controller,
                ],
              ),

              const Divider(
                thickness: 1,
              ),

              SizedBox(
                height: 12,
              ),

              // =========================
              // ENTRY
              // =========================

              _section(
                sectionName:
                'Entry',
                titleController:
                entryTitleController,
                points: [
                  entryPoint1Controller,
                  entryPoint2Controller,
                  entryPoint3Controller,
                  entryPoint4Controller,
                ],
              ),

              const Divider(
                thickness: 1,
              ),

              SizedBox(
                height: 12,
              ),

              // =========================
              // EXCEPTIONS
              // =========================

              _section(
                sectionName:
                'Exceptions',
                titleController:
                exceptionsTitleController,
                points: [
                  exceptionPoint1Controller,
                  exceptionPoint2Controller,
                  exceptionPoint3Controller,
                  exceptionPoint4Controller,
                ],
              ),

              SizedBox(
                height: 8,
              ),

              // =========================
              // SAVE
              // =========================

              ElevatedButton.icon(
                onPressed:
                isSaving
                    ? null
                    : _save,
                icon:
                isSaving
                    ? SizedBox(
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
                  isSaving
                      ? 'Saving...'
                      : 'Save',
                ),
                style:
                ElevatedButton
                    .styleFrom(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 14,
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}