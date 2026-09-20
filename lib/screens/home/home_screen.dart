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
import '../settings/settings_screen.dart';
import '../../l10n/app_translations.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.tr('$screenName will be built next.')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // HAMBURGER SIDE MENU
      // ============================================================
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // ----------------------------------------------------
              // Drawer Header
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppTranslations.tr('Sharaby Center'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTranslations.tr('Patient Management System'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0284C7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ----------------------------------------------------
              // Doctor Screen
              // ----------------------------------------------------
              ListTile(
                leading: const Icon(
                  Icons.medical_services_outlined,
                ),
                title: Text(
                  AppTranslations.tr('Doctor Screen'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalFollowupsScreen(),
                    ),
                  );
                },
              ),

              // ----------------------------------------------------
              // Reception Screen
              // ----------------------------------------------------
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),
                title: Text(
                  AppTranslations.tr('Reception Screen'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagementFollowupsScreen(),
                    ),
                  );
                },
              ),

              // ----------------------------------------------------
              // Settings
              // ----------------------------------------------------
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                ),
                title: Text(
                  AppTranslations.tr('Settings'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              // ----------------------------------------------------
              // About
              // ----------------------------------------------------
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                ),
                title: Text(
                  AppTranslations.tr('About'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: null,
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        title: Text(
          AppTranslations.tr('Sharaby Center'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // FOLLOW-UPS
              // ==========================================
              Text(
                AppTranslations.tr('Follow-ups'),
                style: const TextStyle(
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
                      title: AppTranslations.tr('Medical\nFollow-ups'),
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
                      title: AppTranslations.tr('Management\nFollow-ups'),
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
              Text(
                AppTranslations.tr('Management'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // User
              _menuButton(
                title: AppTranslations.tr('User'),
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
                title: AppTranslations.tr('Screening Data'),
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
                title: AppTranslations.tr('Nursery Rates'),
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
                title: AppTranslations.tr('Inpatient Rates'),
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
                title: AppTranslations.tr('Salaries'),
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
                title: AppTranslations.tr('Other'),
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
                title: AppTranslations.tr('Screening Time'),
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
                title: AppTranslations.tr('Backup'),
                icon: Icons.backup_outlined,
                onPressed: () {
                  _showComingSoon(context, AppTranslations.tr('Backup'));
                },
              ),

              // Screen Data
              _menuButton(
                title: AppTranslations.tr('Screen Data'),
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
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330EA5E9),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
    final isArabic = ThemeController.instance.isArabic;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x330EA5E9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0EA5E9),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Icon(
                  isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF0EA5E9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}