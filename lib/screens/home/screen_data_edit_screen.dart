import 'package:flutter/material.dart';

import '../../services/tbl_flasha_api_service.dart';

class ScreenDataEditScreen extends StatefulWidget {
  const ScreenDataEditScreen({super.key});

  @override
  State<ScreenDataEditScreen> createState() =>
      _ScreenDataEditScreenState();
}

class _ScreenDataEditScreenState
    extends State<ScreenDataEditScreen> {
  final List<_FlashRow> _rows = [];

  bool _loading = true;
  bool _saving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data =
      await TblFlashaApiService.getAll();

      _disposeRows();

      for (final item in data) {
        _rows.add(
          _FlashRow(
            flashId: _toInt(item['flashID']),
            type: _toStringValue(item['type']),
            text1: _toStringValue(item['text1']),
            text2: _toStringValue(item['text2']),
            text3: _toStringValue(item['text3']),
            text4: _toStringValue(item['text4']),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_saving || _rows.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      final data = _rows.map((row) {
        return {
          'flashID': row.flashId,
          'type': _nullableText(
            row.typeController.text,
          ),
          'text1': _nullableText(
            row.text1Controller.text,
          ),
          'text2': _nullableText(
            row.text2Controller.text,
          ),
          'text3': _nullableText(
            row.text3Controller.text,
          ),
          'text4': _nullableText(
            row.text4Controller.text,
          ),
        };
      }).toList();

      await TblFlashaApiService.updateAll(data);

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ بيانات الشاشة بنجاح',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء الحفظ:\n$e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection(
      _FlashRow row,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEF6),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Column(
        children: [
          // ======================================================
          // TITLE
          // ======================================================

          _buildLabeledField(
            label: 'عنوان 1 :',
            controller: row.typeController,
            maxLines: 1,
          ),

          const SizedBox(height: 10),

          // ======================================================
          // POINT 1
          // ======================================================

          _buildLabeledField(
            label: 'نقطة 1 :',
            controller: row.text1Controller,
          ),

          const SizedBox(height: 10),

          // ======================================================
          // POINT 2
          // ======================================================

          _buildLabeledField(
            label: 'نقطة 2 :',
            controller: row.text2Controller,
          ),

          const SizedBox(height: 10),

          // ======================================================
          // POINT 3
          // ======================================================

          _buildLabeledField(
            label: 'نقطة 3 :',
            controller: row.text3Controller,
          ),

          const SizedBox(height: 10),

          // ======================================================
          // POINT 4
          // ======================================================

          _buildLabeledField(
            label: 'نقطة 4 :',
            controller: row.text4Controller,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABELED TEXT FIELD
  // ============================================================

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    int maxLines = 3,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 13,
            ),
            child: Text(
              label,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            minLines: 1,
            maxLines: maxLines,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تعديل بيانات الشاشة',
        ),
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),

              const SizedBox(height: 12),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loadData,
                child: const Text(
                  'إعادة المحاولة',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_rows.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'لا توجد بيانات للشاشة',
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  return _buildSection(
                    _rows[index],
                    index,
                  );
                },
              ),
            ),
          ),

          // ======================================================
          // SAVE BUTTON
          // ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              4,
              12,
              12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving
                    ? null
                    : _save,
                icon: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.save,
                ),
                label: Text(
                  _saving
                      ? 'جاري الحفظ...'
                      : 'حفظ',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String _toStringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String? _nullableText(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  void _disposeRows() {
    for (final row in _rows) {
      row.dispose();
    }

    _rows.clear();
  }

  @override
  void dispose() {
    _disposeRows();
    super.dispose();
  }
}

// ==================================================================
// FLASH ROW
// ==================================================================

class _FlashRow {
  final int flashId;

  final TextEditingController typeController;
  final TextEditingController text1Controller;
  final TextEditingController text2Controller;
  final TextEditingController text3Controller;
  final TextEditingController text4Controller;

  _FlashRow({
    required this.flashId,
    required String type,
    required String text1,
    required String text2,
    required String text3,
    required String text4,
  })  : typeController =
  TextEditingController(text: type),
        text1Controller =
        TextEditingController(text: text1),
        text2Controller =
        TextEditingController(text: text2),
        text3Controller =
        TextEditingController(text: text3),
        text4Controller =
        TextEditingController(text: text4);

  void dispose() {
    typeController.dispose();
    text1Controller.dispose();
    text2Controller.dispose();
    text3Controller.dispose();
    text4Controller.dispose();
  }
}