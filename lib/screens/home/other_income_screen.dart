import 'package:flutter/material.dart';

class OtherIncomeScreen extends StatefulWidget {
  const OtherIncomeScreen({super.key});

  @override
  State<OtherIncomeScreen> createState() => _OtherIncomeScreenState();
}

class _OtherIncomeScreenState extends State<OtherIncomeScreen> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  int? selectedRow;

  // Empty for now.
  // Real records will come from the database through the API later.
  final List<Map<String, String>> incomeRecords = [];

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _search() {
    setState(() {
      selectedRow = null;
    });

    _showMessage(
      'Search date: ${_formatDate(selectedDate)}',
    );
  }

  void _addIncome() {
    final type = typeController.text.trim();
    final price = priceController.text.trim();

    if (type.isEmpty) {
      _showMessage('Please enter the type.');
      return;
    }

    if (price.isEmpty) {
      _showMessage('Please enter the price.');
      return;
    }

    final parsedPrice = double.tryParse(price);

    if (parsedPrice == null) {
      _showMessage('Please enter a valid price.');
      return;
    }

    // Database insertion will be connected later.
    _showMessage(
      'Income information is valid.',
    );
  }

  void _deleteIncome() {
    if (selectedRow == null) {
      _showMessage('Please select an income record first.');
      return;
    }

    // Database deletion will be connected later.
    _showMessage(
      'Selected income record is ready for deletion.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatDate(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      height: 52,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(int row, String text, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = row;
        });
      },
      child: Container(
        width: width,
        height: 42,
        color: selectedRow == row
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTable() {
    const int emptyRows = 12;

    const double typeWidth = 180;
    const double priceWidth = 120;
    const double byWidth = 120;
    const double notesWidth = 240;

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
          0: FixedColumnWidth(typeWidth),
          1: FixedColumnWidth(priceWidth),
          2: FixedColumnWidth(byWidth),
          3: FixedColumnWidth(notesWidth),
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            children: [
              _headerCell('Type', typeWidth),
              _headerCell('Price', priceWidth),
              _headerCell('By', byWidth),
              _headerCell('Notes', notesWidth),
            ],
          ),

          // Empty rows
          for (int i = 0; i < emptyRows; i++)
            TableRow(
              children: [
                _dataCell(
                  i,
                  i < incomeRecords.length
                      ? incomeRecords[i]['type'] ?? ''
                      : '',
                  typeWidth,
                ),
                _dataCell(
                  i,
                  i < incomeRecords.length
                      ? incomeRecords[i]['price'] ?? ''
                      : '',
                  priceWidth,
                ),
                _dataCell(
                  i,
                  i < incomeRecords.length
                      ? incomeRecords[i]['by'] ?? ''
                      : '',
                  byWidth,
                ),
                _dataCell(
                  i,
                  i < incomeRecords.length
                      ? incomeRecords[i]['notes'] ?? ''
                      : '',
                  notesWidth,
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;

    for (final record in incomeRecords) {
      total += double.tryParse(
        record['price'] ?? '',
      ) ??
          0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Income'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================
              // ADD NEW INCOME
              // ==========================

              _sectionTitle('Add New Income'),

              const SizedBox(height: 16),

              _textField(
                controller: typeController,
                label: 'Type',
              ),

              const SizedBox(height: 14),

              _textField(
                controller: priceController,
                label: 'Price',
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 14),

              _textField(
                controller: notesController,
                label: 'Notes',
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _addIncome,
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==========================
              // SEARCH BY DATE
              // ==========================

              _sectionTitle('Search by Date'),

              const SizedBox(height: 14),

              _dateField(),

              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _search,
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (incomeRecords.isEmpty)
                const Center(
                  child: Text(
                    'No income for this date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // ==========================
              // EXCEL-LIKE TABLE
              // ==========================

              _buildTable(),

              const SizedBox(height: 16),

              // ==========================
              // DELETE
              // ==========================

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _deleteIncome,
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================
              // TOTAL
              // ==========================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _calculateTotal().toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}