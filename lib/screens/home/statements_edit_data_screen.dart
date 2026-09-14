import 'package:flutter/material.dart';

class StatementsEditDataScreen extends StatefulWidget {
  const StatementsEditDataScreen({super.key});

  @override
  State<StatementsEditDataScreen> createState() =>
      _StatementsEditDataScreenState();
}

class _StatementsEditDataScreenState
    extends State<StatementsEditDataScreen> {
  final TextEditingController searchController = TextEditingController();

  int? selectedRow;

  final List<String> headers = [
    'No.',
    'Name',
    'Phone',
    'Date of Birth',
    'Address',
    'Notes',
    'Delete',
    'Details',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _search() {
    final name = searchController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name to search.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Search will be connected to the database later.',
        ),
      ),
    );
  }

  void _deleteRow(int index) {
    setState(() {
      selectedRow = index;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text(
            'This operation will be connected to the database later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Delete will be completed after API connection.',
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDetails(int index) {
    setState(() {
      selectedRow = index;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Details - Row ${index + 1}'),
          content: const Text(
            'Patient details will be loaded from the database after API connection.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _headerCell(String text) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      color: const Color(0xFF4D88B5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _emptyCell({
    required int rowIndex,
    required String header,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = rowIndex;
        });
      },
      child: Container(
        height: 42,
        alignment: Alignment.center,
        color: selectedRow == rowIndex
            ? Colors.blue.withOpacity(0.12)
            : const Color(0xFFD3DFE9),
        child: Text(
          header == 'No.' ? '${rowIndex + 1}' : '',
        ),
      ),
    );
  }

  Widget _actionCell({
    required int rowIndex,
    required bool delete,
  }) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      color: selectedRow == rowIndex
          ? Colors.blue.withOpacity(0.12)
          : const Color(0xFFD3DFE9),
      child: TextButton(
        onPressed: () {
          if (delete) {
            _deleteRow(rowIndex);
          } else {
            _showDetails(rowIndex);
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          delete ? 'Delete' : 'Details',
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(130),
        border: TableBorder.all(
          color: Colors.black54,
          width: 0.7,
        ),
        children: [
          TableRow(
            children: [
              _headerCell('No.'),
              _headerCell('Name'),
              _headerCell('Phone'),
              _headerCell('Date of Birth'),
              _headerCell('Address'),
              _headerCell('Notes'),
              _headerCell('Delete'),
              _headerCell('Details'),
            ],
          ),

          ...List.generate(20, (index) {
            return TableRow(
              children: [
                _emptyCell(
                  rowIndex: index,
                  header: 'No.',
                ),
                _emptyCell(
                  rowIndex: index,
                  header: 'Name',
                ),
                _emptyCell(
                  rowIndex: index,
                  header: 'Phone',
                ),
                _emptyCell(
                  rowIndex: index,
                  header: 'Date of Birth',
                ),
                _emptyCell(
                  rowIndex: index,
                  header: 'Address',
                ),
                _emptyCell(
                  rowIndex: index,
                  header: 'Notes',
                ),
                _actionCell(
                  rowIndex: index,
                  delete: true,
                ),
                _actionCell(
                  rowIndex: index,
                  delete: false,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Search by Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
              onSubmitted: (_) {
                _search();
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),

            const SizedBox(height: 24),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}