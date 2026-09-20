import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/damages_api_service.dart';

class FaultsArchiveScreen extends StatefulWidget {
  const FaultsArchiveScreen({super.key});

  @override
  State<FaultsArchiveScreen> createState() =>
      _FaultsArchiveScreenState();
}

class _FaultsArchiveScreenState
    extends State<FaultsArchiveScreen> {
  List<Map<String, dynamic>> archiveFaults = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  // =========================
  // LOAD ARCHIVE
  // =========================

  Future<void> _loadArchive() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data =
      await DamagesApiService.getDamagesArchive();

      if (!mounted) return;

      setState(() {
        archiveFaults = data
            .map(
              (fault) =>
          Map<String, dynamic>.from(fault),
        )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }

  // =========================
  // HEADER CELL
  // =========================

  Widget _headerCell(String text) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DATA CELL
  // =========================

  Widget _dataCell(String text) {
    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // =========================
  // TABLE
  // =========================

  Widget _table() {
    const List<String> columns = [
      'Device Name',
      'Fault Details',
      'Date Added',
      'Accountant',
      'Cost',
      'Access Number',
      'Maintenance Engineer',
      'Maintenance Time',
      'Accountant',
    ];

    const List<double> columnWidths = [
      150,
      220,
      120,
      120,
      90,
      120,
      170,
      140,
      120,
    ];

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment:
        TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        columnWidths: {
          for (int i = 0;
          i < columnWidths.length;
          i++)
            i: FixedColumnWidth(
              columnWidths[i],
            ),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              for (final column in columns)
                _headerCell(column),
            ],
          ),

          for (final fault in archiveFaults)
            TableRow(
              children: [
                _dataCell(
                  fault['deviceName']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['damageDetails']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['timeOfAdd']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['user_IdOfAdd']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['cost']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['wasl_no']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['byEng']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['timeOfRepair']
                      ?.toString() ??
                      '',
                ),
                _dataCell(
                  fault['user_idOfPay']
                      ?.toString() ??
                      '',
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Faults Archive'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40,
                alignment:
                Alignment.centerLeft,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                    Colors.grey.shade400,
                  ),
                  color:
                  Colors.grey.shade100,
                ),
                child: Text(AppTranslations.tr('Faults Archive'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              _table(),
            ],
          ),
        ),
      ),
    );
  }
}