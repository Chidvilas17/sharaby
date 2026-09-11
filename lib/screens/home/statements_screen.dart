import 'package:flutter/material.dart';

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
                _showComingSoon(context);
              },
            ),

            _menuButton(
              title: 'Edit Data',
              icon: Icons.edit_outlined,
              onPressed: () {
                _showComingSoon(context);
              },
            ),

            _menuButton(
              title: 'Delete List',
              icon: Icons.delete_outline,
              onPressed: () {
                _showComingSoon(context);
              },
            ),

            _menuButton(
              title: 'Screen Data',
              icon: Icons.visibility_outlined,
              onPressed: () {
                _showComingSoon(context);
              },
            ),

            _menuButton(
              title: 'Discover',
              icon: Icons.search_outlined,
              onPressed: () {
                _showComingSoon(context);
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