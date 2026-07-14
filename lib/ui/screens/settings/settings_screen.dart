import 'package:flutter/material.dart';
import '../../../core/services/app_localizations.dart';
import 'language_screen.dart';
import 'license_info_screen.dart';
import 'my_store_screen.dart';

const _kNavy = Color(0xFF0D1B2A);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: _kNavy,
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
      body: ListView(
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
        ],
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
        color: _kBgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: _kNavy),
        title: Text(
          title,
          style: const TextStyle(
            color: _kTxtHigh,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: _kTxtMid, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: _kTxtMid),
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
