import 'package:flutter/material.dart';

class ManagementInpatientScreen extends StatelessWidget {
  const ManagementInpatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inpatient',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. New Case
              _menuButton(
                title: 'New Case',
                icon: Icons.add_circle_outline,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 2. Admission Accounts
              _menuButton(
                title: 'Admission Accounts',
                icon: Icons.receipt_long_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 3. Today's Accounts
              _menuButton(
                title: "Today's Accounts",
                icon: Icons.today_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 4. Discharged Case
              _menuButton(
                title: 'Discharged Case',
                icon: Icons.exit_to_app_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 5. Data Edits
              _menuButton(
                title: 'Data Edits',
                icon: Icons.edit_note_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MENU BUTTON
  // =====================================================

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      constraints: const BoxConstraints(
        minHeight: 75,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}