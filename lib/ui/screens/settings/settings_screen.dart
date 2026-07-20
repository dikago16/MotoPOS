import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/services/app_localizations.dart';
import 'language_screen.dart';
import 'license_info_screen.dart';
import 'my_store_screen.dart';
import 'backup_restore_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('settings'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMenuTile(
              context,
              icon: Icons.store,
              title: AppLocalizations.get('my_store'),
              subtitle: AppLocalizations.get('store_information'),
              screen: const MyStoreScreen(),
            ),
            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.key,
              title: AppLocalizations.get('license'),
              subtitle: AppLocalizations.get('license_info'),
              screen: const LicenseInfoScreen(),
            ),
            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.language,
              title: AppLocalizations.get('language'),
              subtitle: AppLocalizations.get('choose_language'),
              screen: const LanguageScreen(),
            ),
            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.cloud_upload,
              title: AppLocalizations.get('backup_restore'),
              subtitle: AppLocalizations.get('backup_restore_desc'),
              screen: const BackupRestoreScreen(),
            ),

            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.info_outline,
              title: AppLocalizations.get('About'),
              subtitle: 'MotoPOS application information',
              screen: const AboutScreen(),
            ),
            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: AppLocalizations.get('privacy_policy'),
              subtitle: AppLocalizations.get('privacy_policy_desc'),
              screen: const PrivacyPolicyScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.navy),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.txtHigh,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.txtMid, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.txtMid),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}

