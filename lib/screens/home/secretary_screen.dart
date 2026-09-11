import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secretary Details'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Add'),
              Tab(text: 'Edit'),
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
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Log in ID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Expanded(
              child: Center(
                child: Text(
                  'No user data loaded',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
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
          const SizedBox(height: 20),

          _buildTextField(
            controller: loginController,
            label: 'Log In',
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: passwordController,
            label: 'Password',
            obscureText: true,
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            obscureText: true,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: 130,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveUser,
              child: const Text(
                'Save',
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
          const SizedBox(height: 30),

          Row(
            children: [
              const Text(
                'Search By Log in Id :',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loadUser,
                  child: const Text('Load'),
                ),
              ),
            ],
          ),
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
  // SAVE
  // ------------------------------------------------------------

  void _saveUser() {
    if (loginController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Password and Confirm Password do not match.');
      return;
    }

    // SQL Server database connection will be added later.
    _showMessage('User is ready to be saved.');
  }

  // ------------------------------------------------------------
  // LOAD
  // ------------------------------------------------------------

  void _loadUser() {
    if (searchController.text.trim().isEmpty) {
      _showMessage('Please enter a Log in ID.');
      return;
    }

    // SQL Server database search will be added later.
    _showMessage(
      'Search is ready. Database connection will be added later.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}