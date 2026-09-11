import 'package:flutter/material.dart';

class SalariesScreen extends StatelessWidget {
  const SalariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salaries',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current for Doctors
              _menuButton(
                title: 'Current for Doctors',
                icon: Icons.medical_services_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Current for Nurses
              _menuButton(
                title: 'Current for Nurses',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Discounts
              _menuButton(
                title: 'Discounts',
                icon: Icons.discount_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Rates
              _menuButton(
                title: 'Rates',
                icon: Icons.price_check_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // Total Salaries
              _menuButton(
                title: 'Total Salaries',
                icon: Icons.payments_outlined,
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

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 75,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
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

            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

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