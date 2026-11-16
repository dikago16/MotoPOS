import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_localizations.dart';
import '../../core/services/security_pin_service.dart';
import '../../providers/auth_provider.dart';

class SecurityPinDialog {
  /// Prompt the user for the Owner Security PIN.
  /// Returns `true` if authorized, `false` otherwise.
  static Future<bool> verify(
    BuildContext context, {
    String? reason,
  }) async {
    // Bypass PIN prompt if the currently active user is already an Owner
    try {
      final auth = context.read<AuthProvider>();
      if (auth.isOwner) return true;
    } catch (_) {
      // AuthProvider not in widget tree (e.g., standalone test)
    }

    final bool isConfigured = await SecurityPinService.isPinSet();

    if (!context.mounted) return false;

    if (!isConfigured) {
      // First-time setup flow
      return await _showSetupDialog(context) ?? false;
    }

    // Normal verification flow
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _PinVerifyDialog(reason: reason),
        ) ??
        false;
  }

  /// Dialog to setup a new PIN when none exists yet
  static Future<bool?> _showSetupDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PinSetupDialog(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verification Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _PinVerifyDialog extends StatefulWidget {
  final String? reason;

  const _PinVerifyDialog({this.reason});

  @override
  State<_PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<_PinVerifyDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;
  bool _isChecking = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.get('required');
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    bool isValid = await SecurityPinService.verifyPin(pin);

    if (!isValid && mounted) {
      try {
        final auth = context.read<AuthProvider>();
        final pinHash = SecurityPinService.hashPin(pin);
        isValid = auth.activeUsers.any((u) => u.isOwner && u.pin == pinHash);
      } catch (_) {}
    }

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isChecking = false;
        _errorMessage = AppLocalizations.get('security_pin_incorrect');
        _pinController.clear();
      });
    }
  }

  void _showRecoveryDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PinRecoveryDialog(),
    ).then((recovered) {
      if (recovered == true && mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.navy, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.get('security_pin_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtHigh,
                  ),
                ),
                if (widget.reason != null)
                  Text(
                    widget.reason!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.txtMid,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              autofocus: true,
              obscureText: _obscureText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: const TextStyle(
                  letterSpacing: 6,
                  color: AppColors.txtLow,
                  fontSize: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                filled: true,
                fillColor: AppColors.bgPage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _errorMessage != null ? AppColors.red : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _errorMessage != null ? AppColors.red : AppColors.accent,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.txtLow,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _handleVerify(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppColors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showRecoveryDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.get('security_pin_forgot'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isChecking ? null : () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.get('cancel'),
            style: const TextStyle(color: AppColors.txtLow, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _isChecking ? null : _handleVerify,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: _isChecking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  AppLocalizations.get('confirm'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Setup Dialog (When PIN is not yet configured)
// ─────────────────────────────────────────────────────────────────────────────
class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (pin.length < 4 || pin.length > 6) {
      setState(() {
        _error = AppLocalizations.get('security_pin_min_digits');
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _error = AppLocalizations.get('security_pin_mismatch');
      });
      return;
    }

    await SecurityPinService.setPin(pin);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.get('security_pin_saved')),
        backgroundColor: AppColors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.get('security_pin_set_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.get('security_pin_set_desc'),
              style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinCtrl,
              autofocus: true,
              obscureText: _obscure,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: AppLocalizations.get('security_pin_new'),
                labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
                filled: true,
                fillColor: AppColors.bgPage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.txtLow,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscure,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: AppLocalizations.get('security_pin_confirm'),
                labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
                filled: true,
                fillColor: AppColors.bgPage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: (_) => _handleSave(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.get('cancel'),
            style: const TextStyle(color: AppColors.txtLow, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(
            AppLocalizations.get('save'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recovery Dialog (Reset PIN via License Key or Store Phone)
// ─────────────────────────────────────────────────────────────────────────────
class _PinRecoveryDialog extends StatefulWidget {
  const _PinRecoveryDialog();

  @override
  State<_PinRecoveryDialog> createState() => _PinRecoveryDialogState();
}

class _PinRecoveryDialogState extends State<_PinRecoveryDialog> {
  final _recoveryCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _isVerified = false;
  bool _isChecking = false;
  String? _error;

  @override
  void dispose() {
    _recoveryCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyIdentity() async {
    final input = _recoveryCtrl.text.trim();
    if (input.isEmpty) {
      setState(() => _error = AppLocalizations.get('required'));
      return;
    }

    setState(() {
      _isChecking = true;
      _error = null;
    });

    final success = await SecurityPinService.verifyRecovery(input);

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      if (success) {
        _isVerified = true;
      } else {
        _error = AppLocalizations.get('security_pin_recovery_invalid');
      }
    });
  }

  Future<void> _saveNewPin() async {
    final newPin = _newPinCtrl.text.trim();
    final confirm = _confirmPinCtrl.text.trim();

    if (newPin.length < 4 || newPin.length > 6) {
      setState(() => _error = AppLocalizations.get('security_pin_min_digits'));
      return;
    }

    if (newPin != confirm) {
      setState(() => _error = AppLocalizations.get('security_pin_mismatch'));
      return;
    }

    await SecurityPinService.setPin(newPin);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.get('security_pin_saved')),
        backgroundColor: AppColors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            child: const Icon(Icons.lock_reset, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.get('security_pin_recovery_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.txtHigh,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isVerified) ...[
              Text(
                AppLocalizations.get('security_pin_recovery_desc'),
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _recoveryCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_recovery_hint'),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onSubmitted: (_) => _verifyIdentity(),
              ),
            ] else ...[
              Text(
                AppLocalizations.get('security_pin_recovery_success'),
                style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_new'),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_confirm'),
                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.txtMid),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSubmitted: (_) => _saveNewPin(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.get('cancel'),
            style: const TextStyle(color: AppColors.txtLow, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _isChecking
              ? null
              : (_isVerified ? _saveNewPin : _verifyIdentity),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: _isChecking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _isVerified ? AppLocalizations.get('save') : AppLocalizations.get('confirm'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}
