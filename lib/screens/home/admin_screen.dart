import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController password2Controller =
  TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    password2Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // User name
            _buildRow(
              label: 'User name',
              controller: usernameController,
            ),

            const SizedBox(height: 24),

            // Password
            _buildRowWithSave(
              label: 'Password',
              controller: passwordController,
              onSave: _savePassword,
            ),

            const SizedBox(height: 24),

            // Password 2
            _buildRowWithSave(
              label: 'Password 2',
              controller: password2Controller,
              onSave: _savePassword2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowWithSave({
    required String label,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),

        const SizedBox(width: 44),

        SizedBox(
          width: 90,
          height: 45,
          child: ElevatedButton(
            onPressed: onSave,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }

  void _savePassword() {
    if (passwordController.text.isEmpty) {
      _showMessage('Please enter a password.');
      return;
    }

    // Database functionality will be added later.
    _showMessage('Password is ready to be saved.');
  }

  void _savePassword2() {
    if (password2Controller.text.isEmpty) {
      _showMessage('Please enter Password 2.');
      return;
    }

    // Database functionality will be added later.
    _showMessage('Password 2 is ready to be saved.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}