import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_service.dart';
import '../data/models/user_model.dart';
import '../core/services/security_pin_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService;
  static const String _activeUserIdPref = 'active_user_id';

  UserModel? _currentUser;
  List<UserModel> _activeUsers = [];
  bool _isInitialized = false;

  AuthProvider(this._dbService);

  UserModel? get currentUser => _currentUser;
  List<UserModel> get activeUsers => _activeUsers;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;
  bool get isOwner => _currentUser?.isOwner ?? false;
  bool get isCashier => _currentUser?.isCashier ?? false;
  bool get isMultiUserEnabled => _activeUsers.length > 1;

  Future<void> init() async {
    await refreshUsers();

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_activeUserIdPref);

    if (savedId != null) {
      final user = _activeUsers.where((u) => u.id == savedId).firstOrNull;
      if (user != null) {
        _currentUser = user;
      }
    }

    // Default to the first user if none is selected
    if (_currentUser == null && _activeUsers.isNotEmpty) {
      _currentUser = _activeUsers.first;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshUsers() async {
    List<UserModel> users = await _dbService.getActiveUsers();

    if (users.isEmpty) {
      // Seed initial Owner user
      final hasPin = await SecurityPinService.isPinSet();
      final pinHash = hasPin
          ? await _getStoredOwnerPinHash()
          : SecurityPinService.hashPin('123456');

      final owner = UserModel(
        username: 'Owner',
        pin: pinHash,
        role: 'owner',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
      );
      final id = await _dbService.insertUser(owner);
      users = [owner.copyWith(id: id)];

      if (!hasPin) {
        await SecurityPinService.setPin('123456');
      }
    }

    _activeUsers = users;

    // Refresh current user reference
    if (_currentUser != null) {
      final updated =
          _activeUsers.where((u) => u.id == _currentUser!.id).firstOrNull;
      _currentUser =
          updated ?? (_activeUsers.isNotEmpty ? _activeUsers.first : null);
    }

    notifyListeners();
  }

  Future<String> _getStoredOwnerPinHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('owner_security_pin_hash') ??
        SecurityPinService.hashPin('123456');
  }

  /// Verifies PIN and sets the target user as currently active
  Future<bool> verifyAndSwitchUser(
    UserModel targetUser,
    String enteredPin,
  ) async {
    final enteredHash = SecurityPinService.hashPin(enteredPin);
    if (targetUser.pin == enteredHash) {
      await switchUser(targetUser);
      return true;
    }
    return false;
  }

  Future<void> switchUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) {
      await prefs.setInt(_activeUserIdPref, user.id!);
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
