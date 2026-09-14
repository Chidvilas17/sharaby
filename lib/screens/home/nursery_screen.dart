import 'package:flutter/material.dart';
import 'nursery_new_screen.dart';
import 'nursery_reserved_cases_screen.dart';
import 'nursery_daily_accounts_screen.dart';
import 'nursery_today_accounts_screen.dart';
import 'nursery_edit_data_screen.dart';

class NurseryScreen extends StatelessWidget {
  const NurseryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nursery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuButton(
              title: 'New',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NurseryNewScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Reserved Cases',
              icon: Icons.event_available_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NurseryReservedCasesScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Discharged Cases',
              icon: Icons.account_balance_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NurseryDailyAccountsScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Today\'s Account',
              icon: Icons.today_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NurseryTodayAccountsScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Edit Data',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NurseryEditDataScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            title,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This section will be added next.'),
      ),
    );
  }
}