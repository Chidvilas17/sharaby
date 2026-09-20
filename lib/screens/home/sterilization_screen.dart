import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';
import 'sterilization_material_income_screen.dart';
import 'sterilization_material_accounts_screen.dart';

class SterilizationScreen extends StatelessWidget {
  const SterilizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.tr('Sterilization'),
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
              // Sterilization Material → Income
              _menuButton(
                title: 'Sterilization Material income',
                icon: Icons.medical_services_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const SterilizationMaterialIncomeScreen(),
                    ),
                  );
                },
              ),

              // Sterilization Material Accounts
              _menuButton(
                title: 'Sterilization Material Accounts',
                icon: Icons.account_balance_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const SterilizationMaterialAccountsScreen(),
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