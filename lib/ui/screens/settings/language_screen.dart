import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/app_localizations.dart';

const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);

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
        backgroundColor: _kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: _kAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedLang == 'en' ? 'Language Changed' : 'Bahasa Diubah',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTxtHigh,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          _selectedLang == 'en'
              ? 'Please close and reopen the app for changes to take effect across all screens.'
              : 'Silakan tutup dan buka kembali aplikasi agar perubahan diterapkan di semua halaman.',
          style: const TextStyle(fontSize: 13, color: _kTxtMid, height: 1.5),
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
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChanges = _selectedLang != _savedLang;

    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: _kNavy,
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
                color: _kBgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                children: [
                  _buildLanguageOption(
                    title: AppLocalizations.get('english'),
                    value: 'en',
                  ),
                  const Divider(height: 1, color: _kBorder),
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
          color: _kTxtHigh,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: _kAccent)
          : const Icon(Icons.radio_button_unchecked, color: _kBorder),
    );
  }
}
