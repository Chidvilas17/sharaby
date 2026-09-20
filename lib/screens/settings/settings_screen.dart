import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;
    final isArabic = themeController.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // THEME MODE SECTION
              // ========================================================
              _buildSectionHeader(
                context,
                title: isArabic ? 'مظهر التطبيق' : 'App Theme',
                icon: Icons.palette_outlined,
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        activeColor: theme.colorScheme.primary,
                        title: Row(
                          children: [
                            const Icon(Icons.dark_mode_outlined, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              isArabic ? 'الوضع الأزرق الداكن (الفاخر)' : 'Dark Blue Glossy Mode',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          isArabic ? 'مظهر أزرق ملكي فاخر مع تأثيرات زجاجية' : 'Deep royal blue glassmorphism theme',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        value: ThemeMode.dark,
                        groupValue: themeController.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            setState(() {
                              themeController.setThemeMode(mode);
                            });
                          }
                        },
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      RadioListTile<ThemeMode>(
                        activeColor: theme.colorScheme.primary,
                        title: Row(
                          children: [
                            const Icon(Icons.light_mode_outlined, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              isArabic ? 'الوضع الفاتح' : 'Light Mode',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          isArabic ? 'مظهر أزرق سماوي هادئ وفاتح' : 'Subtle light blue healthcare theme',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        value: ThemeMode.light,
                        groupValue: themeController.themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            setState(() {
                              themeController.setThemeMode(mode);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ========================================================
              // LANGUAGE SECTION
              // ========================================================
              _buildSectionHeader(
                context,
                title: isArabic ? 'اللغة' : 'Language',
                icon: Icons.language_outlined,
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        activeColor: theme.colorScheme.primary,
                        title: const Row(
                          children: [
                            Text('🇺🇸', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 12),
                            Text(
                              'English',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        value: 'en',
                        groupValue: themeController.locale.languageCode,
                        onChanged: (lang) {
                          if (lang != null) {
                            setState(() {
                              themeController.setLocale(Locale(lang));
                            });
                          }
                        },
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      RadioListTile<String>(
                        activeColor: theme.colorScheme.primary,
                        title: const Row(
                          children: [
                            Text('🇪🇬', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 12),
                            Text(
                              'العربية (Arabic)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        value: 'ar',
                        groupValue: themeController.locale.languageCode,
                        onChanged: (lang) {
                          if (lang != null) {
                            setState(() {
                              themeController.setLocale(Locale(lang));
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ========================================================
              // ABOUT / APP INFO
              // ========================================================
              _buildSectionHeader(
                context,
                title: isArabic ? 'عن التطبيق' : 'About Application',
                icon: Icons.info_outline,
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sharaby Center',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? 'الإصدار 1.0.0' : 'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
