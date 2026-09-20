import 'package:flutter/material.dart';
import '../../l10n/app_translations.dart';
import '../../services/user_api_service.dart';

class SecretaryScreen extends StatefulWidget {
  const SecretaryScreen({super.key});

  @override
  State<SecretaryScreen> createState() => _SecretaryScreenState();
}

class _SecretaryScreenState extends State<SecretaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController searchController = TextEditingController();

  int? loadedUserId;

  bool loadingUsers = false;
  List<Map<String, dynamic>> secretaryUsers = [];

  // Current test database role mapping.
  static const int secretaryManageId = 3;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _loadAllSecretaries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Secretary Details')),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),

          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppTranslations.tr('All')),
              Tab(text: AppTranslations.tr('Add')),
              Tab(text: AppTranslations.tr('Edit')),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(),
                _buildAddTab(),
                _buildEditTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ALL TAB
  // ------------------------------------------------------------

  Widget _buildAllTab() {
    if (loadingUsers) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (secretaryUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppTranslations.tr('No secretary users found.'),
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAllSecretaries,
              icon: const Icon(Icons.refresh),
              label: Text(AppTranslations.tr('Refresh')),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(AppTranslations.tr('Log in ID'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(AppTranslations.tr('Password'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: secretaryUsers.length,
                itemBuilder: (context, index) {
                  final user = secretaryUsers[index];

                  return ListTile(
                    title: Text(
                      user['log_id']?.toString() ?? '',
                    ),
                    subtitle: Text(AppTranslations.tr('Password hidden'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ADD TAB
  // ------------------------------------------------------------

  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 20),

          _buildTextField(
            controller: loginController,
            label: 'Log In',
          ),

          SizedBox(height: 20),

          _buildTextField(
            controller: passwordController,
            label: 'Password',
            obscureText: true,
          ),

          SizedBox(height: 20),

          _buildTextField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            obscureText: true,
          ),

          SizedBox(height: 30),

          SizedBox(
            width: 130,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveUser,
              child: Text(AppTranslations.tr('Save'),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT TAB
  // ------------------------------------------------------------

  Widget _buildEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 30),

          Row(
            children: [
              Text(AppTranslations.tr('Search By Log in Id :'),
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(width: 12),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loadUser,
                  child: Text(AppTranslations.tr('Load')),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          if (loadedUserId != null) ...[
            _buildTextField(
              controller: loginController,
              label: 'Log In',
            ),

            SizedBox(height: 20),

            _buildTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: true,
            ),

            SizedBox(height: 20),

            _buildTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              obscureText: true,
            ),

            SizedBox(height: 30),

            SizedBox(
              width: 130,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateUser,
                child: Text(AppTranslations.tr('Save'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: 350,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOAD ALL SECRETARIES
  // ------------------------------------------------------------

  Future<void> _loadAllSecretaries() async {
    setState(() {
      loadingUsers = true;
    });

    try {
      final users = await UserApiService.getUsers();

      final secretaries = users
          .where(
            (user) =>
        user['ManageID'] == secretaryManageId ||
            user['manageID'] == secretaryManageId,
      )
          .map(
            (user) => Map<String, dynamic>.from(user),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        secretaryUsers = secretaries;
        loadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingUsers = false;
      });

      _showMessage(
        'Failed to load secretaries.\n$e',
      );
    }
  }

  // ------------------------------------------------------------
  // SAVE / ADD USER
  // ------------------------------------------------------------

  Future<void> _saveUser() async {
    final login = loginController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (login.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Password and Confirm Password do not match.',
      );
      return;
    }

    try {
      await UserApiService.addUser(
        userName: 'Reception',
        password: password,
        logId: login,
        manageId: secretaryManageId,
      );

      if (!mounted) return;

      _showMessage('Secretary user added successfully.');

      loginController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      await _loadAllSecretaries();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ------------------------------------------------------------
  // LOAD USER FOR EDIT
  // ------------------------------------------------------------

  Future<void> _loadUser() async {
    final login = searchController.text.trim();

    if (login.isEmpty) {
      _showMessage('Please enter a Log in ID.');
      return;
    }

    try {
      final user = await UserApiService.searchUser(login);

      final manageId = user['ManageID'] ?? user['manageID'];

      if (manageId != secretaryManageId) {
        _showMessage(
          'This user is not a Secretary user.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        loadedUserId = user['user_id'];

        // Windows uses log_id as the Log In ID.
        loginController.text =
            user['log_id']?.toString() ?? '';

        passwordController.clear();
        confirmPasswordController.clear();
      });

      _showMessage('Secretary user loaded.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ------------------------------------------------------------
  // UPDATE USER
  // ------------------------------------------------------------

  Future<void> _updateUser() async {
    if (loadedUserId == null) {
      _showMessage('Please load a user first.');
      return;
    }

    final login = loginController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (login.isEmpty) {
      _showMessage('Log in ID is required.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter a password.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Password and Confirm Password do not match.',
      );
      return;
    }

    try {
      await UserApiService.updateUser(
        userId: loadedUserId!,
        userName: 'Reception',
        password: password,
        logId: login,
        manageId: secretaryManageId,
      );

      if (!mounted) return;

      _showMessage('Secretary user updated successfully.');

      searchController.clear();
      loginController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      setState(() {
        loadedUserId = null;
      });

      await _loadAllSecretaries();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr(message)),
      ),
    );
  }
}