import 'package:flutter/material.dart';

class GeneralExpensesScreen extends StatelessWidget {
  const GeneralExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'General Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Household
              _menuButton(
                title: 'Household',
                icon: Icons.home_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Supplies
              _menuButton(
                title: 'Supplies',
                icon: Icons.inventory_2_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Electricity & Water
              _menuButton(
                title: 'Electricity & Water',
                icon: Icons.water_drop_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Cleaning Supply
              _menuButton(
                title: 'Cleaning Supply',
                icon: Icons.cleaning_services_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Other
              _menuButton(
                title: 'Other',
                icon: Icons.more_horiz,
                onPressed: () {
                  // We will build this next
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 75,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}