import 'package:flutter/material.dart';
import 'staff_doctors_daily_attendance_screen.dart';
import 'staff_doctors_monthly_net_screen.dart';

class StaffDoctorsScreen extends StatelessWidget {
  const StaffDoctorsScreen({super.key});

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
        title: const Text('Doctors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuButton(
              context: context,
              title: 'Daily Attendance',
              icon: Icons.fact_check_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StaffDoctorsDailyAttendanceScreen(),
                  ),
                );
              },
            ),

            _menuButton(
              context: context,
              title: 'Monthly Net',
              icon: Icons.calculate_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const StaffDoctorsMonthlyNetScreen(),
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