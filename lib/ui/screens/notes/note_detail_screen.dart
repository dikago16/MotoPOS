import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db_helper.dart';
import '../../../data/models/note_model.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────








// ──────────────────────────────────────────────────────────────────────────────

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('note_cannot_be_empty')),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    if (widget.note == null) {
      // Create new note
      final newNote = NoteModel(title: title, content: content, createdAt: now);
      await DBHelper.insertNote(newNote);
    } else {
      // Update existing note
      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: title,
        content: content,
        createdAt: now, // update to modification time
      );
      await DBHelper.updateNote(updatedNote);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.get('note_title'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.txtMid),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.txtHigh),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.get('enter_title_here'),
                    hintStyle: const TextStyle(color: AppColors.txtLow, fontSize: 14, fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.get('content'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.txtMid),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _contentController,
                  style: const TextStyle(fontSize: 13, color: AppColors.txtHigh, height: 1.5),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.get('write_your_note_here'),
                    hintStyle: const TextStyle(color: AppColors.txtLow, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  minLines: 8,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(AppLocalizations.get('save_note').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.navy,
      elevation: 0,
      toolbarHeight: 54,
      iconTheme: const IconThemeData(color: Colors.white, size: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Fill the details below',
            style: TextStyle(
              color: Color(0xFF90AAC8),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.white, size: 20),
          onPressed: _saveNote,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
