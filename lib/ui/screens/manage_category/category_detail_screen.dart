import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../data/db_helper.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kBorderMid = Color(0xFFCBD5E1);
const _kTxtHigh = Color(0xFF0F172A);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
// ──────────────────────────────────────────────────────────────────────────────

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel? category;

  const CategoryDetailScreen({super.key, this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  bool _autoCategoryCode = true;
  bool _isSaving = false;
  String _generatedCode = '';

  final _categoryCodeCtrl = TextEditingController();
  final _categoryNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _autoCategoryCode = false;
      _categoryCodeCtrl.text = widget.category!.categoryCode;
      _categoryNameCtrl.text = widget.category!.categoryName;
    } else {
      _fetchNextCode();
    }
  }

  Future<void> _fetchNextCode() async {
    String nextCode = await DBHelper.getNextCategoryCode();
    setState(() {
      _generatedCode = nextCode;
      if (_autoCategoryCode) {
        _categoryCodeCtrl.text = _generatedCode;
      }
    });
  }

  @override
  void dispose() {
    _categoryCodeCtrl.dispose();
    _categoryNameCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: _kTxtLow),
      labelStyle: const TextStyle(fontSize: 12, color: _kTxtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
        color: _kAccent,
        fontWeight: FontWeight.w600,
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          if (icon != null) ...[
            Icon(icon, size: 14, color: _kAccent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _kTxtMid,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: AppBar(
        backgroundColor: _kNavy,
        elevation: 0,
        toolbarHeight: 54,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEdit ? 'Edit Category' : 'New Category',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit ? 'Update Details' : 'Add New Category',
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kBgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel(
                            'Basic Information',
                            icon: Icons.info_outline,
                          ),
                          if (widget.category == null)
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _autoCategoryCode,
                                    activeColor: _kAccent,
                                    onChanged: (val) {
                                      setState(() {
                                        _autoCategoryCode = val ?? true;
                                        if (_autoCategoryCode) {
                                          _categoryCodeCtrl.text =
                                              _generatedCode;
                                        } else {
                                          _categoryCodeCtrl.text = '';
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Auto Code',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _kTxtMid,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Category Code
                      TextFormField(
                        controller: _categoryCodeCtrl,
                        readOnly: _autoCategoryCode,
                        style: const TextStyle(fontSize: 13, color: _kTxtMid),
                        decoration: _inputDeco('Category Code').copyWith(
                          fillColor: _autoCategoryCode ? _kBgPage : _kBgCard,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Name
                      TextFormField(
                        controller: _categoryNameCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco('Category Name'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _kBgCard,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _categoryCodeCtrl.clear();
                  _categoryNameCtrl.clear();
                  setState(() {
                    _autoCategoryCode = true;
                    _categoryCodeCtrl.text = _generatedCode;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBgPage,
                  foregroundColor: _kTxtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: _kBorderMid),
                  ),
                ),
                child: const Text(
                  'ABORT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_categoryNameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Category name cannot be empty!'),
                              backgroundColor: Colors.red.shade600,
                            ),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);

                        try {
                          final category = CategoryModel(
                            id: widget.category?.id,
                            categoryCode: _categoryCodeCtrl.text,
                            categoryName: _categoryNameCtrl.text,
                          );
                          if (widget.category != null) {
                            await DBHelper.updateCategory(category);
                          } else {
                            await DBHelper.insertCategory(category);
                          }
                          
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Category saved successfully!'),
                              backgroundColor: Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save category: $e'),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: _isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(
                  _isSaving ? 'SAVING...' : 'SAVE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
