import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_localizations.dart';
import '../../../core/services/security_pin_service.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  bool _isPinSet = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final isSet = await SecurityPinService.isPinSet();
    if (!mounted) return;
    setState(() {
      _isPinSet = isSet;
      _isLoading = false;
    });
  }

  void _showSetPinDialog() {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            AppLocalizations.get('security_pin_set_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_new'),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_confirm'),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(fontSize: 11, color: AppColors.red),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinCtrl.text.trim();
                final confirm = confirmCtrl.text.trim();
                if (pin.length < 4 || pin.length > 6) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_min_digits');
                  });
                  return;
                }
                if (pin != confirm) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_mismatch');
                  });
                  return;
                }
                await SecurityPinService.setPin(pin);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.get('security_pin_saved')),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(AppLocalizations.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            AppLocalizations.get('security_pin_change'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPinCtrl,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('security_pin_old'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('security_pin_new'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('security_pin_confirm'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(fontSize: 11, color: AppColors.red),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldPin = oldPinCtrl.text.trim();
                final newPin = newPinCtrl.text.trim();
                final confirm = confirmCtrl.text.trim();

                final isOldValid = await SecurityPinService.verifyPin(oldPin);
                if (!isOldValid) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_incorrect');
                  });
                  return;
                }

                if (newPin.length < 4 || newPin.length > 6) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_min_digits');
                  });
                  return;
                }

                if (newPin != confirm) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_mismatch');
                  });
                  return;
                }

                await SecurityPinService.setPin(newPin);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.get('security_pin_changed')),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(AppLocalizations.get('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisablePinDialog() {
    final pinCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            AppLocalizations.get('security_pin_disable'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Masukkan PIN saat ini untuk menonaktifkan proteksi PIN:',
                style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('security_pin_old'),
                  filled: true,
                  fillColor: AppColors.bgPage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(fontSize: 11, color: AppColors.red),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinCtrl.text.trim();
                final isValid = await SecurityPinService.verifyPin(pin);
                if (!isValid) {
                  setDialogState(() {
                    error = AppLocalizations.get('security_pin_incorrect');
                  });
                  return;
                }

                await SecurityPinService.removePin();
                if (ctx.mounted) Navigator.pop(ctx);
                _loadStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.get('security_pin_disabled')),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(AppLocalizations.get('confirm')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('security_pin'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isPinSet
                            ? AppColors.green.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isPinSet
                                ? AppColors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPinSet ? Icons.verified_user : Icons.gpp_maybe,
                            color: _isPinSet ? AppColors.green : AppColors.txtLow,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPinSet
                                    ? AppLocalizations.get('security_pin_status_active')
                                    : AppLocalizations.get('security_pin_status_inactive'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _isPinSet ? AppColors.green : AppColors.txtHigh,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isPinSet
                                    ? AppLocalizations.get('security_pin_status_active_desc')
                                    : AppLocalizations.get('security_pin_status_inactive_desc'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.txtMid,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Actions
                  if (!_isPinSet) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _showSetPinDialog,
                        icon: const Icon(Icons.lock, size: 18),
                        label: Text(
                          AppLocalizations.get('security_pin_enable_btn'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildActionTile(
                      icon: Icons.pin,
                      title: AppLocalizations.get('security_pin_change'),
                      subtitle: 'Ganti PIN keamanan pemilik dengan PIN baru',
                      onTap: _showChangePinDialog,
                    ),
                    const SizedBox(height: 10),
                    _buildActionTile(
                      icon: Icons.lock_open,
                      title: AppLocalizations.get('security_pin_disable'),
                      subtitle: 'Matikan proteksi PIN pada aplikasi',
                      isDestructive: true,
                      onTap: _showDisablePinDialog,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Explanation Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Fitur yang Terlindungi PIN:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildProtectedItem('Kelola Barang (Ubah Harga Jual/Beli & Stok)'),
                        _buildProtectedItem('Kelola Kategori & Data Supplier'),
                        _buildProtectedItem('Faktur Pembelian (Harga Modal Kulakan)'),
                        _buildProtectedItem('Laporan Harian (Omset & Total Penjualan)'),
                        _buildProtectedItem('Hapus & Ubah Transaksi di Riwayat'),
                        _buildProtectedItem('Pengaturan Toko, Lisensi & Cadangan Data'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProtectedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.txtMid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppColors.red : AppColors.navy),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.red : AppColors.txtHigh,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.txtMid, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.txtMid),
        onTap: onTap,
      ),
    );
  }
}
