import 'package:flutter/material.dart';

class ScreeningDataScreen extends StatelessWidget {
  const ScreeningDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Screening Data',
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
              // Diagnosis
              _menuButton(
                title: 'Diagnosis',
                icon: Icons.medical_information_outlined,
                onPressed: () {
                  // We will build Diagnosis next
                },
              ),

              // Treatment
              _menuButton(
                title: 'Treatment',
                icon: Icons.healing_outlined,
                onPressed: () {
                  // We will build Treatment next
                },
              ),

              // C/O
              _menuButton(
                title: 'C/O',
                icon: Icons.description_outlined,
                onPressed: () {
                  // We will build C/O next
                },
              ),

              // Payes
              _menuButton(
                title: 'Payes',
                icon: Icons.payments_outlined,
                onPressed: () {
                  // We will build Payes next
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