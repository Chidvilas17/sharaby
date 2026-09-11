import 'package:flutter/material.dart';
import 'doctor_screen.dart';
import 'secretary_screen.dart';
import 'admin_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuButton(
              title: 'Doctors',
              icon: Icons.medical_services_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Secretary',
              icon: Icons.person_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecretaryScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              title: 'Admin',
              icon: Icons.admin_panel_settings_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
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