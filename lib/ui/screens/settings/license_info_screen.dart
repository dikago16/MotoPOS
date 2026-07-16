import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_localizations.dart';









class LicenseInfoScreen extends StatefulWidget {
  const LicenseInfoScreen({super.key});

  @override
  State<LicenseInfoScreen> createState() => _LicenseInfoScreenState();
}

class _LicenseInfoScreenState extends State<LicenseInfoScreen> {
  String _licenseKey = "Loading...";
  String _statusMessage = "Checking license info...";
  String _deviceId = "Loading...";
  bool _isLoading = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _fetchLicenseInfo();
  }

  Future<void> _fetchLicenseInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('saved_license_key') ?? '';
    final deviceId = await ActivationService.getDeviceId();

    if (key.isEmpty) {
      setState(() {
        _licenseKey = AppLocalizations.get('no_license');
        _statusMessage = AppLocalizations.get('activate_first');
        _isLoading = false;
        _isValid = false;
      });
      return;
    }

    setState(() {
      _licenseKey = key;
      _deviceId = deviceId;
    });

    final result = await ActivationService.checkLicenseInfo(key);

    if (mounted) {
      setState(() {
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          final status = data['status'] == 'active' ? 'Active' : (data['status'] == 'expired' ? 'Expired' : data['status']);
          final expiresAt = data['expires_at'] != null ? data['expires_at'].toString().split('T')[0] : '-';
          
          _statusMessage = '${AppLocalizations.get('status')}: $status\n${AppLocalizations.get('valid_until')}: $expiresAt';
          _isValid = data['status'] == 'active';
        } else {
          _statusMessage = result['message'] ?? 'Unknown Status';
          _isValid = false;
        }
        _isLoading = false;
      });
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
          AppLocalizations.get('license_info'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isValid ? Icons.verified_user : Icons.gpp_bad,
                          size: 64,
                          color: _isValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.get('license_key'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.txtMid,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _licenseKey.isNotEmpty ? _licenseKey : AppLocalizations.get('no_license'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.txtHigh,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppColors.border),
                        ),
                        Text(
                          AppLocalizations.get('status_expiry'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.txtMid,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.txtHigh,
                            height: 1.5,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppColors.border),
                        ),
                        Text(
                          AppLocalizations.get('device_id').toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.txtMid,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _deviceId,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: AppColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}
