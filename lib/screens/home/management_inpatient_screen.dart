import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';
import 'management_inpatient_new_case_screen.dart';
import 'management_inpatient_admission_accounts_screen.dart';
import 'management_inpatient_today_accounts_screen.dart';
import 'management_inpatient_discharged_screen.dart';
import 'management_inpatient_data_edits_screen.dart';

class ManagementInpatientScreen extends StatelessWidget {
  const ManagementInpatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Inpatient'),
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
                icon: Icons.person_add_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ManagementInpatientNewCaseScreen(),
                    ),
                  );
                },
              ),

              // 2. Admission Accounts
              _menuButton(
                title: 'Admission Accounts',
                icon: Icons.account_balance_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ManagementInpatientAdmissionAccountsScreen(),
                    ),
                  );
                },
              ),

              // 3. Today's Accounts
              _menuButton(
                title: 'Today\'s Accounts',
                icon: Icons.today_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ManagementInpatientTodayAccountsScreen(),
                    ),
                  );
                },
              ),

              // 4. Discharged Case
              _menuButton(
                title: 'Discharged Cases',
                icon: Icons.exit_to_app_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ManagementInpatientDischargedScreen(),
                    ),
                  );
                },
              ),

              // 5. Data Edits
              _menuButton(
                title: 'Data Edits',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ManagementInpatientDataEditsScreen(),
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

            SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(ThemeController.instance.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}