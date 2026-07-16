import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_localizations.dart';
import '../../../../providers/printer_provider.dart';

class PairedDevicesDialog extends StatefulWidget {
  final PrinterProvider printerProvider;

  const PairedDevicesDialog({super.key, required this.printerProvider});

  @override
  State<PairedDevicesDialog> createState() => _PairedDevicesDialogState();
}

class _PairedDevicesDialogState extends State<PairedDevicesDialog> {
  List<Device> _devices = [];
  bool _isLoading = true;
  bool _isConnecting = false;
  String _connectingAddress = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await widget.printerProvider.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToDevice(Device device) async {
    setState(() {
      _isConnecting = true;
      _connectingAddress = device.address;
    });

    final success = await widget.printerProvider.connectToDevice(device);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.name ?? 'printer'}'),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isConnecting = false;
          _connectingAddress = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ${device.name ?? 'printer'}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            child: const Icon(Icons.bluetooth, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.get('select_printer'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtHigh,
                  ),
                ),
                Text(
                  AppLocalizations.get('saved_bluetooth_devices'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.txtMid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _devices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bluetooth_searching,
                            size: 36, color: AppColors.txtLow),
                        SizedBox(height: 10),
                        Text(
                          'No saved devices.\n\nPair a printer through\nyour device\'s Bluetooth settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.txtMid,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _devices.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final bool isThisConnecting =
                          _isConnecting && _connectingAddress == device.address;

                      return InkWell(
                        onTap: _isConnecting
                            ? null
                            : () => _connectToDevice(device),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.print,
                                size: 20,
                                color: isThisConnecting
                                    ? AppColors.accent
                                    : AppColors.txtMid,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name ?? AppLocalizations.get('unknown_device'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.txtHigh,
                                      ),
                                    ),
                                    Text(
                                      device.address,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.txtLow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isThisConnecting)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.txtLow,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.pop(context),
          child: Text(
            AppLocalizations.get('cancel'),
            style: const TextStyle(color: AppColors.txtLow, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
