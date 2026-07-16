import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_localizations.dart';
import '../../../services/google_drive_service.dart';
import '../../../data/database_service.dart';
import '../../widgets/app_loading.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  late final GoogleDriveService _driveService;
  bool _isLoading = true;
  bool _isActionLoading = false;
  List<drive.File> _backups = [];

  @override
  void initState() {
    super.initState();
    _driveService = GoogleDriveService(context.read<DatabaseService>());
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    setState(() => _isLoading = true);
    await _driveService.signInSilently();
    if (_driveService.currentUser != null) {
      await _loadBackups();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadBackups() async {
    final backups = await _driveService.getBackupList();
    setState(() {
      _backups = backups;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isActionLoading = true);
    final user = await _driveService.signIn();
    if (user != null) {
      await _loadBackups();
    }
    setState(() => _isActionLoading = false);
  }

  Future<void> _handleSignOut() async {
    setState(() => _isActionLoading = true);
    await _driveService.signOut();
    setState(() {
      _backups = [];
      _isActionLoading = false;
    });
  }

  Future<void> _handleBackup() async {
    setState(() => _isActionLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.get('backup_in_progress'))),
    );

    final success = await _driveService.backupData();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.get(success ? 'backup_success' : 'backup_failed'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        await _loadBackups();
      }
    }
    setState(() => _isActionLoading = false);
  }

  Future<void> _handleRestore(String fileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.get('restore_confirm_title')),
        content: Text(AppLocalizations.get('restore_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.get('restore')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.get('restore_in_progress'))),
    );

    final success = await _driveService.restoreData(fileId);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.get(
              success ? 'restore_success' : 'restore_failed',
            ),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
    setState(() => _isActionLoading = false);
  }

  Future<void> _handleDelete(String fileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.get('delete_backup')),
        content: Text(AppLocalizations.get('delete_backup_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.get('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    final success = await _driveService.deleteBackup(fileId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.get('backup_deleted'))),
      );
      await _loadBackups();
    }
    setState(() => _isActionLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          AppLocalizations.get('backup_restore'),
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
            ? const AppLoading(isFullScreen: true)
            : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAccountCard(),
                      if (_driveService.currentUser != null) ...[
                        const SizedBox(height: 16),
                        _buildBackupCard(),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.get('backup_history'),
                          style: const TextStyle(
                            color: AppColors.txtHigh,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBackupList(),
                      ],
                    ],
                  ),
                  if (_isActionLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const AppLoading(isFullScreen: true),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final user = _driveService.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                color: user != null ? Colors.green : Colors.grey,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? AppLocalizations.get('connected_as')
                          : AppLocalizations.get('not_connected'),
                      style: const TextStyle(
                        color: AppColors.txtMid,
                        fontSize: 12,
                      ),
                    ),
                    if (user != null)
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.txtHigh,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: user != null ? _handleSignOut : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: user != null
                    ? Colors.grey[200]
                    : AppColors.navy,
                foregroundColor: user != null
                    ? AppColors.txtHigh
                    : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                user != null
                    ? AppLocalizations.get('sign_out')
                    : AppLocalizations.get('sign_in_google'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_upload, color: AppColors.navy),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.get('backup_now'),
                      style: const TextStyle(
                        color: AppColors.txtHigh,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.get('backup_restore_desc'),
                      style: const TextStyle(
                        color: AppColors.txtMid,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleBackup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.get('backup_now')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList() {
    if (_backups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.get('no_backups'),
          style: const TextStyle(color: AppColors.txtMid),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _backups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = _backups[index];
        final createdTime = file.createdTime != null
            ? DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(file.createdTime!.toLocal())
            : AppLocalizations.get('unknown');

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            leading: const Icon(Icons.description, color: AppColors.navy),
            title: Text(
              createdTime,
              style: const TextStyle(
                color: AppColors.txtHigh,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              file.name ?? AppLocalizations.get('unknown'),
              style: const TextStyle(color: AppColors.txtMid, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () => _handleRestore(file.id!),
                  tooltip: AppLocalizations.get('restore'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _handleDelete(file.id!),
                  tooltip: AppLocalizations.get('delete_backup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
