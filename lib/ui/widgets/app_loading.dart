import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_localizations.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const AppLoading({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            strokeWidth: 3,
          ),
        ),
        if (message != null || isFullScreen) ...[
          const SizedBox(height: 16),
          Text(
            message ?? AppLocalizations.get('loading'),
            style: const TextStyle(
              color: AppColors.txtMid,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]
      ],
    );

    if (isFullScreen) {
      return Center(child: content);
    }
    return content;
  }
}
