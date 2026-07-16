import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../data/database_service.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────








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
  String? _codeError;

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
    String nextCode = await context.read<DatabaseService>().getNextCategoryCode();
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
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.txtLow),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.txtMid),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
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
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.txtMid,
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
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        toolbarHeight: 54,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEdit ? AppLocalizations.get('edit_category') : AppLocalizations.get('new_category'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isEdit ? AppLocalizations.get('update_details') : AppLocalizations.get('add_new_category'),
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
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel(
                            AppLocalizations.get('basic_information'),
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
                                    activeColor: AppColors.accent,
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
                                Text(
                                  AppLocalizations.get('auto_code'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.txtMid,
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
                        style: const TextStyle(fontSize: 13, color: AppColors.txtMid),
                        decoration: _inputDeco(AppLocalizations.get('category_code')).copyWith(
                          errorText: _codeError,
                          fillColor: _autoCategoryCode ? AppColors.bgPage : AppColors.bgCard,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Name
                      TextFormField(
                        controller: _categoryNameCtrl,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDeco(AppLocalizations.get('category_name')),
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
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
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
                  backgroundColor: AppColors.bgPage,
                  foregroundColor: AppColors.txtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppColors.borderMid),
                  ),
                ),
                child: Text(
                  AppLocalizations.get('abort'),
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
                              content: Text(AppLocalizations.get('category_name_empty')),
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
                            await context.read<DatabaseService>().updateCategory(category);
                          } else {
                            await context.read<DatabaseService>().insertCategory(category);
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.get('category_saved')),
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
                              content: Text('${AppLocalizations.get('category_save_failed')}: $e'),
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
                  _isSaving ? AppLocalizations.get('saving') : AppLocalizations.get('save'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
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
