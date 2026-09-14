import 'package:flutter/material.dart';
import 'staff_doctors_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff',
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
              // 1. Doctors
              _menuButton(
                title: 'Doctors',
                icon: Icons.medical_services_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffDoctorsScreen(),
                    ),
                  );
                },
              ),

              // 2. Nurses
              _menuButton(
                title: 'Nurses',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 3. Accounts and Laborers
              _menuButton(
                title: 'Accounts and Laborers',
                icon: Icons.groups_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 4. Adding and Editing Data
              _menuButton(
                title: 'Adding and Editing Data',
                icon: Icons.edit_note_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // 5. Discounts
              _menuButton(
                title: 'Discounts',
                icon: Icons.discount_outlined,
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