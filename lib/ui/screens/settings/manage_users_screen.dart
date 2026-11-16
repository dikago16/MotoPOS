import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_localizations.dart';
import '../../../core/services/security_pin_service.dart';
import '../../../data/database_service.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = context.read<DatabaseService>();
    final users = await db.getUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String selectedRole = 'cashier';
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            AppLocalizations.get('add_user'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('staff_name'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('staff_role'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'cashier',
                      child: Text(AppLocalizations.get('role_cashier')),
                    ),
                    DropdownMenuItem(
                      value: 'owner',
                      child: Text(AppLocalizations.get('role_owner')),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRole = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('staff_pin'),
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
                final name = nameCtrl.text.trim();
                final pin = pinCtrl.text.trim();
                final confirm = confirmCtrl.text.trim();

                if (name.isEmpty) {
                  setDialogState(() => error = 'Nama tidak boleh kosong');
                  return;
                }
                if (pin.length < 4 || pin.length > 6) {
                  setDialogState(() => error = AppLocalizations.get('security_pin_min_digits'));
                  return;
                }
                if (pin != confirm) {
                  setDialogState(() => error = AppLocalizations.get('security_pin_mismatch'));
                  return;
                }

                final newUser = UserModel(
                  username: name,
                  pin: SecurityPinService.hashPin(pin),
                  role: selectedRole,
                  isActive: true,
                  createdAt: DateTime.now().toIso8601String(),
                );

                final db = context.read<DatabaseService>();
                final auth = context.read<AuthProvider>();
                final messenger = ScaffoldMessenger.of(context);

                await db.insertUser(newUser);
                await auth.refreshUsers();

                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                _loadUsers();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.get('user_saved')),
                    backgroundColor: AppColors.green,
                  ),
                );
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

  void _showEditUserDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.username);
    final pinCtrl = TextEditingController();
    String selectedRole = user.role;
    bool isActive = user.isActive;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            AppLocalizations.get('edit_user'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('staff_name'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.get('staff_role'),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'cashier',
                      child: Text(AppLocalizations.get('role_cashier')),
                    ),
                    DropdownMenuItem(
                      value: 'owner',
                      child: Text(AppLocalizations.get('role_owner')),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRole = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: 'PIN Baru (Kosongkan jika tidak diubah)',
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Status Aktif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: isActive,
                  activeThumbColor: AppColors.green,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => isActive = val),
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
                final name = nameCtrl.text.trim();
                final pin = pinCtrl.text.trim();

                if (name.isEmpty) {
                  setDialogState(() => error = 'Nama tidak boleh kosong');
                  return;
                }
                if (pin.isNotEmpty && (pin.length < 4 || pin.length > 6)) {
                  setDialogState(() => error = AppLocalizations.get('security_pin_min_digits'));
                  return;
                }

                final updatedUser = user.copyWith(
                  username: name,
                  role: selectedRole,
                  isActive: isActive,
                  pin: pin.isNotEmpty ? SecurityPinService.hashPin(pin) : user.pin,
                );

                final db = context.read<DatabaseService>();
                final auth = context.read<AuthProvider>();
                final messenger = ScaffoldMessenger.of(context);

                await db.updateUser(updatedUser);
                await auth.refreshUsers();

                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                _loadUsers();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.get('user_saved')),
                    backgroundColor: AppColors.green,
                  ),
                );
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

  void _confirmDeleteUser(UserModel user) {
    // Check if this is the only owner
    final ownerCount = _users.where((u) => u.isOwner).length;
    if (user.isOwner && ownerCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('cannot_delete_only_owner')),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(AppLocalizations.get('delete_user')),
        content: Text('Apakah Anda yakin ingin menghapus akun "${user.username}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = context.read<DatabaseService>();
              final auth = context.read<AuthProvider>();
              final messenger = ScaffoldMessenger.of(context);

              await db.deleteUser(user.id!);
              await auth.refreshUsers();

              if (ctx.mounted) Navigator.pop(ctx);
              if (!mounted) return;
              _loadUsers();

              messenger.showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.get('user_deleted')),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(AppLocalizations.get('delete')),
          ),
        ],
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
          AppLocalizations.get('manage_users'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final isOwner = user.isOwner;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOwner
                            ? AppColors.navy.withValues(alpha: 0.1)
                            : AppColors.green.withValues(alpha: 0.1),
                        child: Icon(
                          isOwner ? Icons.admin_panel_settings : Icons.person,
                          color: isOwner ? AppColors.navy : AppColors.green,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.txtHigh,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOwner ? AppColors.navy : AppColors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOwner
                                  ? AppLocalizations.get('role_owner')
                                  : AppLocalizations.get('role_cashier'),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!user.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Nonaktif',
                                style: TextStyle(fontSize: 9, color: AppColors.txtMid),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        'ID: ${user.id} • Dibuat: ${user.createdAt.split('T').first}',
                        style: const TextStyle(fontSize: 11, color: AppColors.txtLow),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: AppColors.txtMid),
                            onPressed: () => _showEditUserDialog(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                            onPressed: () => _confirmDeleteUser(user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
