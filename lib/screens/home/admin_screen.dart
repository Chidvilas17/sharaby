import 'package:flutter/material.dart';
import '../../services/user_api_service.dart';

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

  bool _isSaving = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    password2Controller.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE ADMIN DETAILS
  // ============================================================

  Future<void> _saveAdminDetails() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final password2 = password2Controller.text;

    if (username.isEmpty) {
      _showMessage('Please enter User name.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter a password.');
      return;
    }

    if (password2.isEmpty) {
      _showMessage('Please enter Password 2.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await UserApiService.updateAdminDetails(
        userName: username,
        password: password,
        password2: password2,
      );

      if (!mounted) return;

      _showMessage(
        'Admin details saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ============================================================
  // USER NAME SAVE
  //
  // The original Admin screen has no Save button beside
  // User name, so we keep the same layout.
  //
  // The User name is saved together with the Password
  // and Password 2 when either Save button is pressed.
  // ============================================================

  void _savePassword() {
    _saveAdminDetails();
  }

  void _savePassword2() {
    _saveAdminDetails();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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

            _buildRow(
              label: 'User name',
              controller: usernameController,
            ),

            const SizedBox(height: 24),

            _buildRowWithSave(
              label: 'Password',
              controller: passwordController,
              onSave: _savePassword,
            ),

            const SizedBox(height: 24),

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

  // ============================================================
  // USER NAME ROW
  // ============================================================

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
            enabled: !_isSaving,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASSWORD ROW
  // ============================================================

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
            enabled: !_isSaving,
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
            onPressed: _isSaving ? null : onSave,
            child: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }
}