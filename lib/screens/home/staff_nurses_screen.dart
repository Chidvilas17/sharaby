import 'package:flutter/material.dart';
import 'staff_nurses_daily_monthly_screen.dart';
import 'staff_nurses_net_attendance_screen.dart';

class StaffNursesScreen extends StatelessWidget {
  const StaffNursesScreen({super.key});

  Widget _menuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurses'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuButton(
              context: context,
              title: 'Daily / Monthly',
              icon: Icons.calendar_month_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StaffNursesDailyMonthlyScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              context: context,
              title: 'Net Attendance',
              icon: Icons.fact_check_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StaffNursesNetAttendanceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}