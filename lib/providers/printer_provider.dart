import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import '../services/bluetooth_printer_service.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transaction_item_model.dart';

/// Provider that manages Bluetooth printer connection state
/// and receipt printing functionality.
class PrinterProvider with ChangeNotifier {
  final BluetoothClassic _bluetooth = BluetoothClassic();
  StreamSubscription<int>? _statusSubscription;

  // ─── State ──────────────────────────────────────────────────────────────
  bool _isConnected = false;
  bool _isPrintReceiptEnabled = false;
  String _connectedDeviceName = '';
  bool _isPrinting = false;

  // ─── Getters ────────────────────────────────────────────────────────────
  bool get isConnected => _isConnected;
  bool get isPrintReceiptEnabled => _isPrintReceiptEnabled;
  String get connectedDeviceName => _connectedDeviceName;
  bool get isPrinting => _isPrinting;

  // ─── Bluetooth State Check ──────────────────────────────────────────────

  /// Check if Bluetooth is enabled on the device.
  /// Also requests necessary permissions.
  /// Returns true if Bluetooth is ON and permissions are granted.
  Future<bool> isBluetoothEnabled() async {
    try {
      bool permissionsGranted = await _bluetooth.initPermissions();
      return permissionsGranted;
    } catch (e) {
      debugPrint('Error checking Bluetooth state: $e');
      return false;
    }
  }

  // ─── Get Paired Devices ─────────────────────────────────────────────────

  /// Get list of paired/bonded Bluetooth devices.
  Future<List<Device>> getPairedDevices() async {
    try {
      List<Device> devices = await _bluetooth.getPairedDevices();
      return devices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }

  // ─── Connect to Device ──────────────────────────────────────────────────

  /// Connect to a Bluetooth device by its address.
  /// Uses SPP UUID (Serial Port Profile) for thermal printers.
  Future<bool> connectToDevice(Device device) async {
    try {
      // SPP UUID for serial communication with thermal printers
      const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";
      bool success = await _bluetooth.connect(device.address, sppUuid);

      if (success) {
        _isConnected = true;
        _connectedDeviceName = device.name ?? 'Unknown Device';
        notifyListeners();

        // Listen for device status changes (connection/disconnection)
        _statusSubscription?.cancel();
        _statusSubscription = _bluetooth.onDeviceStatusChanged().listen((status) {
          // status values: 0 = disconnected, 1 = connecting, 2 = connected
          if (status == 0) {
            _onDisconnected();
          }
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      _isConnected = false;
      _connectedDeviceName = '';
      notifyListeners();
      return false;
    }
  }

  // ─── Disconnect ─────────────────────────────────────────────────────────

  /// Disconnect from the currently connected device.
  Future<void> disconnect() async {
    try {
      _statusSubscription?.cancel();
      _statusSubscription = null;
      await _bluetooth.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
    _onDisconnected();
  }

  /// Handle disconnection event
  void _onDisconnected() {
    _isConnected = false;
    _connectedDeviceName = '';
    _isPrintReceiptEnabled = false;
    notifyListeners();
  }

  // ─── Print Receipt Toggle ───────────────────────────────────────────────

  /// Toggle the print receipt option.
  /// Only works if printer is connected.
  void setPrintReceiptEnabled(bool enabled) {
    if (_isConnected) {
      _isPrintReceiptEnabled = enabled;
      notifyListeners();
    }
  }

  // ─── Print Receipt ──────────────────────────────────────────────────────

  /// Print a transaction receipt to the connected Bluetooth printer.
  Future<bool> printReceipt({
    required TransactionModel transaction,
    required List<TransactionItemModel> items,
    required int transactionId,
  }) async {
    if (!_isConnected) {
      debugPrint('Printer not connected');
      return false;
    }

    _isPrinting = true;
    notifyListeners();

    try {
      final Uint8List receiptBytes = BluetoothPrinterService.generateReceipt(
        transaction: transaction,
        items: items,
        transactionId: transactionId,
      );

      // Use writeBytes to send raw ESC/POS commands as bytes
      bool success = await _bluetooth.writeBytes(receiptBytes);

      _isPrinting = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      _isPrinting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
