import 'package:flutter/material.dart';
import '../../services/internal_discharged_api_service.dart';

class ManagementInpatientDischargedScreen
    extends StatefulWidget {
  const ManagementInpatientDischargedScreen({
    super.key,
  });

  @override
  State<ManagementInpatientDischargedScreen>
  createState() =>
      _ManagementInpatientDischargedScreenState();
}

class _ManagementInpatientDischargedScreenState
    extends State<ManagementInpatientDischargedScreen> {
  final TextEditingController searchController =
  TextEditingController();

  int? selectedRow;

  List<Map<String, dynamic>> dischargedPatients = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // =========================================================
    // LOAD ALL DATA AUTOMATICALLY WHEN SCREEN OPENS
    // =========================================================
    _loadAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD ALL DISCHARGED CASES
  // =========================================================

  Future<void> _loadAll() async {
    setState(() {
      loading = true;
      selectedRow = null;
    });

    try {
      final result =
      await InternalDischargedApiService.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        dischargedPatients = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        dischargedPatients = [];
      });

      _showMessage(
        'Failed to load discharged cases.\n$e',
      );
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Future<void> _search() async {
    final name =
    searchController.text.trim();

    // =======================================================
    // EMPTY SEARCH = SHOW ALL DATA AGAIN
    // =======================================================

    if (name.isEmpty) {
      await _loadAll();
      return;
    }

    setState(() {
      loading = true;
      selectedRow = null;
    });

    try {
      final result =
      await InternalDischargedApiService.search(
        name,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        dischargedPatients = result;
        loading = false;
      });

      if (result.isEmpty) {
        _showMessage(
          'No discharged cases found.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      _showMessage(
        'Failed to search discharged cases.\n$e',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
  // TABLE
  // =========================================================

  Widget _buildTable() {
    const double nameWidth = 220;
    const double phoneWidth = 160;
    const double transferredWidth = 200;

    // When data exists, show ALL returned rows.
    // When there is no data, keep the empty grid.
    final int rowCount =
    dischargedPatients.isEmpty
        ? 20
        : dischargedPatients.length;

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
          1: FixedColumnWidth(phoneWidth),
          2: FixedColumnWidth(transferredWidth),
        },
        children: [
          // ===================================================
          // HEADER
          // ===================================================

          TableRow(
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
                'Transferred To',
                transferredWidth,
              ),
            ],
          ),

          // ===================================================
          // DATA ROWS
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
                  row < dischargedPatients.length
                      ? (
                      dischargedPatients[row]
                      ['name'] ??
                          dischargedPatients[row]
                          ['Name'] ??
                          ''
                  ).toString()
                      : '',
                  nameWidth,
                ),

                _dataCell(
                  row,
                  row < dischargedPatients.length
                      ? (
                      dischargedPatients[row]
                      ['phone'] ??
                          dischargedPatients[row]
                          ['Phone'] ??
                          ''
                  ).toString()
                      : '',
                  phoneWidth,
                ),

                _dataCell(
                  row,
                  row < dischargedPatients.length
                      ? (
                      dischargedPatients[row]
                      ['transferredTo'] ??
                          dischargedPatients[row]
                          ['TransferredTo'] ??
                          ''
                  ).toString()
                      : '',
                  transferredWidth,
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
        title: const Text(
          'Discharged Cases',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              // =================================================
              // SEARCH
              // =================================================

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius:
                  BorderRadius.circular(4),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [
                    const Text(
                      'Search by Name',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                      searchController,

                      textInputAction:
                      TextInputAction.search,

                      onSubmitted: (_) =>
                          _search(),

                      decoration:
                      const InputDecoration(
                        labelText: 'Name',
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      height: 48,

                      child: ElevatedButton(
                        onPressed:
                        loading
                            ? null
                            : _search,

                        child: loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Search',
                          style:
                          TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // TABLE
              // =================================================

              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }
}