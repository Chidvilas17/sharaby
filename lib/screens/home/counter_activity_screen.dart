import 'package:flutter/material.dart';

import 'daily_movement_screen.dart';

class CounterActivityScreen extends StatelessWidget {
  const CounterActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Counter Activity',
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
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // DAILY MOVEMENT
              // ==================================================

              _menuButton(
                title: 'Daily Movement',
                icon: Icons.today_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const DailyMovementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // MOVEMENT DURING THE PERIOD
              // ==================================================

              _menuButton(
                title:
                'Movement During the Period',
                icon: Icons.date_range_outlined,
                onPressed: () {
                  // We will build this screen next.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENU BUTTON
  // ============================================================

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 15),
      height: 75,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment:
          Alignment.centerLeft,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15),
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
                style:
                const TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w600,
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