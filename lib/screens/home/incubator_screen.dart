import 'package:flutter/material.dart';
import 'incubator_add_new_screen.dart';
import 'incubator_view_current_screen.dart';
import 'incubator_view_history_screen.dart';

class IncubatorScreen extends StatelessWidget {
  const IncubatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Incubator',
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

              // Add New
              _menuButton(
                title: 'Add New',
                icon: Icons.person_add_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IncubatorAddNewScreen(),
                    ),
                  );
                },
              ),

              // View Current
              _menuButton(
                title: 'View Current',
                icon: Icons.people_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IncubatorViewCurrentScreen(),
                    ),
                  );
                },
              ),

              // View History
              _menuButton(
                title: 'View History',
                icon: Icons.history,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IncubatorViewHistoryScreen(),
                    ),
                  );
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