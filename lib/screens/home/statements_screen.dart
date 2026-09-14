import 'package:flutter/material.dart';
import 'statements_today_account_screen.dart';
import 'statements_edit_data_screen.dart';
import 'statements_delete_list_screen.dart';
import 'statements_screen_data_screen.dart';
import 'statements_discover_screen.dart';


class StatementsScreen extends StatelessWidget {
  const StatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuButton(
              title: 'Today\'s Account',
              icon: Icons.today_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StatementsTodayAccountScreen(),
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
                    const StatementsEditDataScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Delete List',
              icon: Icons.delete_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StatementsDeleteListScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Screen Data',
              icon: Icons.edit_note_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StatementsScreenDataScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Discover',
              icon: Icons.search_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StatementsDiscoverScreen(),
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