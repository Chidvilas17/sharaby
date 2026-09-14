import 'package:flutter/material.dart';

class NurseryTodayAccountsScreen extends StatefulWidget {
  const NurseryTodayAccountsScreen({super.key});

  @override
  State<NurseryTodayAccountsScreen> createState() =>
      _NurseryTodayAccountsScreenState();
}

class _NurseryTodayAccountsScreenState
    extends State<NurseryTodayAccountsScreen> {
  final TextEditingController nameController = TextEditingController();

  int? selectedRow;

  final List<String> headers = [
    'No.',
    'Name',
    'Phone',
    'Exit Date',
    'Transferred To',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _search() {
    if (nameController.text.trim().isEmpty) {
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

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(150),
        border: TableBorder.all(
          color: Colors.grey,
          width: 0.7,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
            ),
            children: headers.map((header) {
              return Container(
                height: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          ...List.generate(20, (index) {
            return TableRow(
              children: headers.map((header) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRow = index;
                    });
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: selectedRow == index
                        ? Colors.blue.withOpacity(0.12)
                        : Colors.transparent,
                    child: Text(
                      header == 'No.'
                          ? '${index + 1}'
                          : '',
                    ),
                  ),
                );
              }).toList(),
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
        title: const Text('Today\'s Account'),
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
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),

            const SizedBox(height: 24),

            const Text(
              '--',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 24),

            _buildTable(),
          ],
        ),
      ),
    );
  }
}