import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../home/management_followups_screen.dart';
import '../home/medical_followups_screen.dart';
import '../../services/user_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      _showMessage('Please enter Username.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter Password.');
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final user = await UserApiService.login(
        logId: username,
        password: password,
      );

      if (!mounted) return;

      final manageId = user['ManageID'] ?? user['manageID'];

      // ========================================================
      // ADMIN
      // ManageID = 1
      // ========================================================

      if (manageId == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        return;
      }

      // ========================================================
      // DOCTOR
      // ManageID = 2
      // ========================================================

      if (manageId == 2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
            const MedicalFollowupsScreen(),
          ),
        );
        return;
      }

      // ========================================================
      // SECRETARY / RECEPTION
      // ManageID = 3
      // ========================================================

      if (manageId == 3) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
            const ManagementFollowupsScreen(),
          ),
        );
        return;
      }

      _showMessage(
        'This user does not have access to this login.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  // ============================================================
  // DEVELOPMENT BYPASS
  // ============================================================

  void _bypassLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
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
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 70,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Sharaby Center',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoggingIn,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoggingIn,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: _isLoggingIn
                                ? null
                                : () {
                              setState(() {
                                _obscurePassword =
                                !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                          _isLoggingIn ? null : _login,
                          child: _isLoggingIn
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                            CircularProgressIndicator(),
                          )
                              : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed:
                          _isLoggingIn ? null : _bypassLogin,
                          child: const Text(
                            'Bypass Login (Development)',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}