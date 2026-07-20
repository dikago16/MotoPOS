import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('privacy_policy'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MotoPOS Privacy Policy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.txtHigh,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Last updated: July 20, 2026',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.txtLow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSection(
                  title: '1. Information We Collect',
                  content:
                      '• Device Information: We collect device-specific information (such as hardware model, OS version, unique identifiers) solely for validating your software license and preventing unauthorized use.\n\n'
                      '• Usage Data: We collect anonymous usage data via Google Firebase Analytics to improve our app performance and user experience.\n\n'
                      '• Crash Reports: In the event of an app crash, we collect crash logs via Firebase Crashlytics to help us fix bugs.\n\n'
                      '• Business Data: All your business data (products, transactions, customers) is stored LOCALLY on your device. We do not upload this to our servers.',
                ),
                
                _buildSection(
                  title: '2. Permissions We Request',
                  content:
                      'MotoPOS requires the following permissions to function correctly:\n\n'
                      '• Camera: Used strictly for scanning barcodes of products. We do not record or save photos/videos.\n\n'
                      '• Bluetooth & Location: Used strictly by the Android OS to detect and connect to Bluetooth thermal printers for receipt printing.\n\n'
                      '• Storage/Drive: Used when you explicitly choose to backup or restore your database to/from your personal Google Drive account.',
                ),
                
                _buildSection(
                  title: '3. How We Use Your Data',
                  content:
                      'We will only use your data for the following purposes:\n'
                      '• To activate and validate your application enterprise license.\n'
                      '• To provide and maintain the application\'s core features.\n'
                      '• To analyze usage and improve our services.\n'
                      '• To prevent fraud or abuse of our licensing system.',
                ),
                
                _buildSection(
                  title: '4. Third-Party Services',
                  content:
                      'We use third-party services that may collect information used to identify you, including:\n'
                      '• Google Play Services\n'
                      '• Google Analytics for Firebase\n'
                      '• Firebase Crashlytics\n\n'
                      'These services have their own Privacy Policies regarding how they handle data.',
                ),
                
                _buildSection(
                  title: '5. Contact Us',
                  content:
                      'If you have any questions or suggestions about our Privacy Policy, please contact us at support@dx-bytes.com.',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.txtMid,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
