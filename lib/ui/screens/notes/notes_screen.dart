import 'package:flutter/material.dart';
import '../../../data/db_helper.dart';
import '../../../data/models/note_model.dart';
import 'note_detail_screen.dart';

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

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteModel> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    final notes = await DBHelper.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kBgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTxtHigh,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this note?',
          style: TextStyle(fontSize: 13, color: _kTxtMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: _kTxtLow, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.deleteNote(id);
      _fetchNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _kAccent))
            : _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.note_alt_outlined, size: 48, color: _kTxtLow),
                        SizedBox(height: 12),
                        Text(
                          'No notes yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _kTxtMid, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        color: _kBgCard,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: _kBorder),
                        ),
                        elevation: 0,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteDetailScreen(note: note),
                              ),
                            );
                            _fetchNotes();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title.isNotEmpty ? note.title : 'Untitled Note',
                                        style: const TextStyle(
                                          color: _kTxtHigh,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note.content,
                                        style: const TextStyle(color: _kTxtMid, fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.createdAt,
                                        style: const TextStyle(color: _kTxtLow, fontSize: 10, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
                                  onPressed: () => _deleteNote(note.id!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
        children: const [
          Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Manage your notes',
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
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteDetailScreen(),
              ),
            );
            _fetchNotes();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
