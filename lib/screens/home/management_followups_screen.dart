import 'package:flutter/material.dart';
import 'maintenance_screen.dart';
import 'counter_activity_screen.dart';
import 'staff_screen.dart';
import 'general_expenses_screen.dart';
import 'sterilization_screen.dart';

class ManagementFollowupsScreen extends StatelessWidget {
  const ManagementFollowupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Management Follow-ups',
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
              // 1. MAINTENANCE
              // ==========================================

              _menuButton(
                title: 'Maintenance',
                icon: Icons.build_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 2. COUNTER ACTIVITY
              // ==========================================

              _menuButton(
                title: 'Counter Activity',
                icon: Icons.point_of_sale_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CounterActivityScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 3. STAFF
              // ==========================================

              _menuButton(
                title: 'Staff',
                icon: Icons.groups_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 4. OTHER INCOME
              // ==========================================

              _menuButton(
                title: 'Other Income',
                icon: Icons.account_balance_wallet_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // ==========================================
              // 5. GENERAL EXPENSES
              // ==========================================

              _menuButton(
                title: 'General Expenses',
                icon: Icons.money_off_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralExpensesScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 6. STERILIZATION
              // ==========================================

              _menuButton(
                title: 'Sterilization',
                icon: Icons.clean_hands_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SterilizationScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 7. OXYGEN
              // ==========================================

              _menuButton(
                title: 'Oxygen',
                icon: Icons.air_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // ==========================================
              // 8. INPATIENT
              // ==========================================

              _menuButton(
                title: 'Inpatient',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // ==========================================
              // 9. NURSERY
              // ==========================================

              _menuButton(
                title: 'Nursery',
                icon: Icons.child_care_outlined,
                onPressed: () {
                  // We will build this next
                },
              ),

              // ==========================================
              // 10. STATEMENTS
              // ==========================================

              _menuButton(
                title: 'Statements',
                icon: Icons.receipt_long_outlined,
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

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
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