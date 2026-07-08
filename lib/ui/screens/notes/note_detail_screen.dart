import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db_helper.dart';
import '../../../data/models/note_model.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
const _kTxtHigh = Color(0xFF0F172A);
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
        const SnackBar(
          content: Text('Note cannot be empty'),
          backgroundColor: Color(0xFFDC2626),
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
      backgroundColor: _kBgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _kBgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note Title',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTxtMid),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTxtHigh),
                  decoration: InputDecoration(
                    hintText: 'Enter title here',
                    hintStyle: const TextStyle(color: _kTxtLow, fontSize: 14, fontWeight: FontWeight.w400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kAccent, width: 1.5),
                    ),
                    filled: true,
                    fillColor: _kBgCard,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Content',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTxtMid),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _contentController,
                  style: const TextStyle(fontSize: 13, color: _kTxtHigh, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    hintStyle: const TextStyle(color: _kTxtLow, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: _kAccent, width: 1.5),
                    ),
                    filled: true,
                    fillColor: _kBgCard,
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
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('SAVE NOTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
      backgroundColor: _kNavy,
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
