import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/app_localizations.dart';
import '../../../services/update_service.dart';
import '../../widgets/update_dialog.dart';
import 'language_screen.dart';
import 'license_info_screen.dart';
import 'my_store_screen.dart';
import 'backup_restore_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentVersion = '...';
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _currentVersion = 'v${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdate = true);

    final result = await UpdateService.checkForUpdate();

    if (!mounted) return;
    setState(() => _isCheckingUpdate = false);

    if (result.updateAvailable && result.versionInfo != null) {
      UpdateDialog.show(
        context,
        versionInfo: result.versionInfo!,
        currentVersion: result.currentVersion ?? _currentVersion,
      );
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('update_not_available')),
        ),
      );
    }
  }

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
            // ── Version Tile (with check update action) ──
            _buildVersionTile(),
            const SizedBox(height: 10),
            _buildMenuTile(
              context,
              icon: Icons.info_outline,
              title: AppLocalizations.get('About'),
              subtitle: 'MotoPOS application information',
              screen: const AboutScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionTile() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: const Icon(Icons.system_update, color: AppColors.navy),
        title: Text(
          AppLocalizations.get('version'),
          style: const TextStyle(
            color: AppColors.txtHigh,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _isCheckingUpdate
              ? AppLocalizations.get('checking_update')
              : _currentVersion,
          style: const TextStyle(color: AppColors.txtMid, fontSize: 12),
        ),
        trailing: _isCheckingUpdate
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : TextButton(
                onPressed: _checkForUpdate,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.get('check_update'),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

