import 'package:flutter/material.dart';
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
        title: const Text(
          'Settings',
          style: TextStyle(
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
          Container(
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.store, color: _kNavy),
              title: const Text(
                'My Store',
                style: TextStyle(
                  color: _kTxtHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Store name, address & phone for receipts',
                style: TextStyle(color: _kTxtMid, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: _kTxtMid),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyStoreScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.key, color: _kNavy),
              title: const Text(
                'License',
                style: TextStyle(
                  color: _kTxtHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'License info',
                style: TextStyle(color: _kTxtMid, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: _kTxtMid),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicenseInfoScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
