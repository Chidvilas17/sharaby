import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/internal_patients_edit_api_service.dart';

class ManagementInpatientDataEditsScreen
    extends StatefulWidget {
  const ManagementInpatientDataEditsScreen({
    super.key,
  });

  @override
  State<ManagementInpatientDataEditsScreen>
  createState() =>
      _ManagementInpatientDataEditsScreenState();
}

class _ManagementInpatientDataEditsScreenState
    extends State<ManagementInpatientDataEditsScreen> {
  int? selectedRow;

  List<Map<String, dynamic>> inpatientData = [];

  bool loading = false;

  // =========================================================
  // INITIAL LOAD
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadPatients();
  }

  // =========================================================
  // LOAD DATA
  // =========================================================

  Future<void> _loadPatients() async {
    setState(() {
      loading = true;
      selectedRow = null;
    });

    try {
      final result =
      await InternalPatientsEditApiService
          .getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        inpatientData = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        inpatientData = [];
      });

      _showMessage(
        'Failed to load inpatient data.\n$e',
      );
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
  // HEADER CELL
  // =========================================================

  Widget _headerCell(
      String text,
      double width,
      ) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // DATA CELL
  // =========================================================

  Widget _dataCell(
      int row,
      String text,
      double width,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = row;
        });
      },
      child: Container(
        width: width,
        height: 38,
        alignment: Alignment.center,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        color: selectedRow == row
            ? Theme.of(context)
            .colorScheme
            .primaryContainer
            : Colors.transparent,
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // =========================================================
  // TABLE
  // =========================================================

  Widget _buildTable() {
    const int emptyRows = 20;

    const double nameWidth = 220;
    const double phoneWidth = 160;
    const double dobWidth = 180;

    final int rowCount =
    inpatientData.isEmpty
        ? emptyRows
        : inpatientData.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          width: 1,
        ),

        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,

        columnWidths: const {
          0: FixedColumnWidth(
            nameWidth,
          ),
          1: FixedColumnWidth(
            phoneWidth,
          ),
          2: FixedColumnWidth(
            dobWidth,
          ),
        },

        children: [
          // ===================================================
          // HEADER
          // ===================================================

          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              _headerCell(
                'Name',
                nameWidth,
              ),
              _headerCell(
                'Phone',
                phoneWidth,
              ),
              _headerCell(
                'Date of Birth',
                dobWidth,
              ),
            ],
          ),

          // ===================================================
          // DATA
          // ===================================================

          for (
          int row = 0;
          row < rowCount;
          row++
          )
            TableRow(
              children: [
                _dataCell(
                  row,
                  row < inpatientData.length
                      ? (
                      inpatientData[row]
                      ['name'] ??
                          inpatientData[row]
                          ['Name'] ??
                          ''
                  ).toString()
                      : '',
                  nameWidth,
                ),

                _dataCell(
                  row,
                  row < inpatientData.length
                      ? (
                      inpatientData[row]
                      ['phone'] ??
                          inpatientData[row]
                          ['Phone'] ??
                          ''
                  ).toString()
                      : '',
                  phoneWidth,
                ),

                // There is currently NO DOB
                // column in InternalPatients.
                _dataCell(
                  row,
                  '',
                  dobWidth,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Edit Inpatient Data'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              if (loading)
                Padding(
                  padding:
                  EdgeInsets.all(12),
                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                ),

              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }
}