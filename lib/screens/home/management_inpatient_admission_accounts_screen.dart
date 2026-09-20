import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/internal_patients_api_service.dart';

class ManagementInpatientAdmissionAccountsScreen
    extends StatefulWidget {
  const ManagementInpatientAdmissionAccountsScreen({
    super.key,
  });

  @override
  State<ManagementInpatientAdmissionAccountsScreen>
  createState() =>
      _ManagementInpatientAdmissionAccountsScreenState();
}

class _ManagementInpatientAdmissionAccountsScreenState
    extends State<ManagementInpatientAdmissionAccountsScreen> {
  int? selectedRow;

  // =========================================================
  // PATIENT DATA
  // =========================================================

  List<Map<String, dynamic>> patients = [];

  bool loadingPatients = true;

  String? errorMessage;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadPatients();
  }

  // =========================================================
  // LOAD PATIENTS
  // =========================================================

  Future<void> _loadPatients() async {
    setState(() {
      loadingPatients = true;
      errorMessage = null;
    });

    try {
      final result =
      await InternalPatientsApiService
          .getPatients();

      if (!mounted) {
        return;
      }

      setState(() {
        patients = result;
        loadingPatients = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingPatients = false;
        errorMessage = e.toString();
      });
    }
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
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Text(
        AppTranslations.tr(text),
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
        padding: const EdgeInsets.symmetric(
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
  // BUILD TABLE
  // =========================================================

  Widget _buildTable() {
    const double nameWidth = 220;
    const double addressWidth = 180;
    const double phone1Width = 140;
    const double phone2Width = 140;
    const double cardNumberWidth = 150;

    final int rowCount =
    patients.isEmpty ? 20 : patients.length;

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
          0: FixedColumnWidth(nameWidth),
          1: FixedColumnWidth(addressWidth),
          2: FixedColumnWidth(phone1Width),
          3: FixedColumnWidth(phone2Width),
          4: FixedColumnWidth(cardNumberWidth),
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
                'Address',
                addressWidth,
              ),
              _headerCell(
                'Phone 1',
                phone1Width,
              ),
              _headerCell(
                'Phone 2',
                phone2Width,
              ),
              _headerCell(
                'Card Number',
                cardNumberWidth,
              ),
            ],
          ),

          // ===================================================
          // DATA / EMPTY ROWS
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
                  row < patients.length
                      ? (patients[row]['name'] ??
                      patients[row]['Name'] ??
                      '')
                      .toString()
                      : '',
                  nameWidth,
                ),

                _dataCell(
                  row,
                  row < patients.length
                      ? (patients[row]['address'] ??
                      patients[row]['Address'] ??
                      '')
                      .toString()
                      : '',
                  addressWidth,
                ),

                _dataCell(
                  row,
                  row < patients.length
                      ? (patients[row]['phone'] ??
                      patients[row]['Phone'] ??
                      '')
                      .toString()
                      : '',
                  phone1Width,
                ),

                _dataCell(
                  row,
                  row < patients.length
                      ? (patients[row]['phone2'] ??
                      patients[row]['Phone2'] ??
                      '')
                      .toString()
                      : '',
                  phone2Width,
                ),

                _dataCell(
                  row,
                  row < patients.length
                      ? (patients[row]['cardNumber'] ??
                      patients[row]['CardNumber'] ??
                      '')
                      .toString()
                      : '',
                  cardNumberWidth,
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
        title: Text(AppTranslations.tr('Current Inpatient Cases'),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPatients,

          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                // =================================================
                // LOADING
                // =================================================

                if (loadingPatients)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  ),

                // =================================================
                // ERROR
                // =================================================

                if (errorMessage != null)
                  Container(
                    margin:
                    const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                      ),
                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          errorMessage!,
                          textAlign:
                          TextAlign.center,
                          style:
                          const TextStyle(
                            color: Colors.red,
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        ElevatedButton(
                          onPressed:
                          _loadPatients,
                          child:
                          Text(AppTranslations.tr('Retry')),
                        ),
                      ],
                    ),
                  ),

                // =================================================
                // TABLE
                // =================================================

                _buildTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}