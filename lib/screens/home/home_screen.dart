import 'package:flutter/material.dart';
import 'medical_followups_screen.dart';
import 'user_screen.dart';
import 'screening_data_screen.dart';
import 'nursery_rates_screen.dart';
import 'salaries_screen.dart';
import 'other_screen.dart';
import 'management_followups_screen.dart';
import 'inpatient_rates_screen.dart';
import 'screening_time_screen.dart';
import 'screen_data_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$screenName will be built next.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sharaby Center',
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

              // ==========================================
              // FOLLOW-UPS
              // ==========================================

              const Text(
                'Follow-ups',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  // Medical Follow-ups
                  Expanded(
                    child: _mainButton(
                      title: 'Medical\nFollow-ups',
                      icon: Icons.medical_services_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicalFollowupsScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Management Follow-ups
                  Expanded(
                    child: _mainButton(
                      title: 'Management\nFollow-ups',
                      icon: Icons.manage_accounts_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const ManagementFollowupsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==========================================
              // MANAGEMENT
              // ==========================================

              const Text(
                'Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // User
              _menuButton(
                title: 'User',
                icon: Icons.person_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserScreen(),
                    ),
                  );
                },
              ),

              // Screening Data
              _menuButton(
                title: 'Screening Data',
                icon: Icons.screen_search_desktop_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreeningDataScreen(),
                    ),
                  );
                },
              ),

              // Nursery Rates
              _menuButton(
                title: 'Nursery Rates',
                icon: Icons.child_care_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NurseryRatesScreen(),
                    ),
                  );
                },
              ),

              // Inpatient Rates
              _menuButton(
                title: 'Inpatient Rates',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InpatientRatesScreen(),
                    ),
                  );
                },
              ),

              // Salaries
              _menuButton(
                title: 'Salaries',
                icon: Icons.payments_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SalariesScreen(),
                    ),
                  );
                },
              ),

              // Other
              _menuButton(
                title: 'Other',
                icon: Icons.more_horiz,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OtherScreen(),
                    ),
                  );
                },
              ),

              // Screening Time
              _menuButton(
                title: 'Screening Time',
                icon: Icons.access_time_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreeningTimeScreen(),
                    ),
                  );
                },
              ),

              // Backup
              _menuButton(
                title: 'Backup',
                icon: Icons.backup_outlined,
                onPressed: () {
                  _showComingSoon(context, 'Backup');
                },
              ),

              // Screen Data
              _menuButton(
                title: 'Screen Data',
                icon: Icons.edit_note_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenDataEditScreen(),
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

  // =====================================================
  // LARGE FOLLOW-UP BUTTON
  // =====================================================

  Widget _mainButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // NORMAL MENU BUTTON
  // =====================================================

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [

            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(width: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}