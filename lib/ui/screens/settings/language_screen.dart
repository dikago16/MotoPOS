import '../../../core/constants/app_colors.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/app_localizations.dart';









class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLang = AppLocalizations.currentLang;
  String _savedLang = AppLocalizations.currentLang;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'en';
    setState(() {
      _selectedLang = lang;
      _savedLang = lang;
    });
  }

  void _selectLanguage(String lang) {
    setState(() {
      _selectedLang = lang;
    });
  }

  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLang);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedLang == 'en' ? 'Language Changed' : 'Bahasa Diubah',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.txtHigh,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          _selectedLang == 'en'
              ? 'Please close and reopen the app for changes to take effect across all screens.'
              : 'Silakan tutup dan buka kembali aplikasi agar perubahan diterapkan di semua halaman.',
          style: const TextStyle(fontSize: 13, color: AppColors.txtMid, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(AppLocalizations.get('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChanges = _selectedLang != _savedLang;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: hasChanges ? Colors.white : Colors.white38,
            ),
            onPressed: hasChanges ? _saveLanguage : null,
            tooltip: AppLocalizations.get('save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildLanguageOption(
                    title: AppLocalizations.get('english'),
                    value: 'en',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildLanguageOption(
                    title: AppLocalizations.get('bahasa_indonesia'),
                    value: 'id',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({required String title, required String value}) {
    final isSelected = _selectedLang == value;
    return ListTile(
      onTap: () => _selectLanguage(value),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.txtHigh,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.accent)
          : const Icon(Icons.radio_button_unchecked, color: AppColors.border),
    );
  }
}
