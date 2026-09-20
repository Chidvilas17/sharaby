import 'package:flutter/material.dart';
import 'maintenance_screen.dart';
import 'counter_activity_screen.dart';
import 'staff_screen.dart';
import 'general_expenses_screen.dart';
import 'sterilization_screen.dart';
import 'oxygen_screen.dart';
import 'management_inpatient_screen.dart';
import 'nursery_screen.dart';
import 'statements_screen.dart';
import 'other_income_screen.dart';


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
                icon: Icons.attach_money_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OtherIncomeScreen(),
                    ),
                  );
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
              _menuButton(
                title: 'Oxygen',
                icon: Icons.air_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OxygenScreen(),
                    ),
                  );
                },
              ),
              // ==========================================



              // ==========================================
              // 8. INPATIENT
              // ==========================================

              _menuButton(
                title: 'Inpatient',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagementInpatientScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 9. NURSERY
              // ==========================================

              _menuButton(
                title: 'Nursery',
                icon: Icons.child_care_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NurseryScreen(),
                    ),
                  );
                },
              ),

              // ==========================================
              // 10. STATEMENTS
              // ==========================================

              _menuButton(
                title: 'Statements',
                icon: Icons.receipt_long_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatementsScreen(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x330EA5E9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0EA5E9),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: const Color(0xFF0284C7),
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Color(0xFF0EA5E9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}