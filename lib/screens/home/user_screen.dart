import 'package:flutter/material.dart';
import '../../services/user_api_service.dart';
import 'doctor_screen.dart';
import 'secretary_screen.dart';
import 'admin_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _loadingUsers = true;
  String? _errorMessage;
  int _userCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loadingUsers = true;
      _errorMessage = null;
    });

    try {
      final users = await UserApiService.getUsers();

      if (!mounted) return;

      setState(() {
        _userCount = users.length;
        _loadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingUsers = false;
        _errorMessage = e.toString();
      });
    }
  }

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
            // API connection test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _loadingUsers
                          ? const Text(
                        'Loading users...',
                        style: TextStyle(fontSize: 16),
                      )
                          : _errorMessage != null
                          ? Text(
                        'API error:\n$_errorMessage',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      )
                          : Text(
                        'Users in database: $_userCount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!_loadingUsers)
                      IconButton(
                        onPressed: _loadUsers,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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
}