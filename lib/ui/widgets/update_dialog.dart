import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_localizations.dart';
import '../../services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog untuk menampilkan informasi update dan progress download.
class UpdateDialog extends StatefulWidget {
  final AppVersionInfo versionInfo;
  final String currentVersion;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    required this.currentVersion,
  });

  /// Menampilkan dialog update. Returns true jika user memilih update.
  static Future<void> show(
    BuildContext context, {
    required AppVersionInfo versionInfo,
    required String currentVersion,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !versionInfo.forceUpdate,
      builder: (_) => UpdateDialog(
        versionInfo: versionInfo,
        currentVersion: currentVersion,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  Future<void> _startUpdate() async {
    final url = Uri.parse(widget.versionInfo.downloadUrl);
    final fallbackUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.dxbytes.motopos');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open update link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.versionInfo.forceUpdate,
      child: AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.system_update,
                  color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('update_available'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.txtHigh,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'v${widget.currentVersion} → v${widget.versionInfo.versionName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtMid,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Release notes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('whats_new'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.txtMid,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.versionInfo.releaseNotes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.txtHigh,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.versionInfo.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.get('later'),
                style: const TextStyle(color: AppColors.txtMid),
              ),
            ),
          ElevatedButton(
            onPressed: _startUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              AppLocalizations.get('update_now'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
