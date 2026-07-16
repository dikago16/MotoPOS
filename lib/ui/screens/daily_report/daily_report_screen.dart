import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db_helper.dart';
import '../../../core/services/app_localizations.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────













const _kAmber = Color(0xFFF59E0B);
// ──────────────────────────────────────────────────────────────────────────────

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _categorySummary = [];
  List<Map<String, dynamic>> _transactionDetails = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final summary = await DBHelper.getDailySummary(dateStr);
    final categories = await DBHelper.getDailyCategorySummary(dateStr);
    final details = await DBHelper.getTransactionDetailsByDate(dateStr);

    setState(() {
      _summary = summary;
      _categorySummary = categories;
      _transactionDetails = details;
      _isLoading = false;
    });
  }

  String _formatRupiah(dynamic v) {
    final val = (v is int) ? v.toDouble() : (v as double?) ?? 0.0;
    return 'Rp ${NumberFormat('#,###', 'id_ID').format(val)}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.txtHigh,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              AppLocalizations.get('daily_report'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(
                color: Color(0xFF90AAC8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            onPressed: _pickDate,
            tooltip: 'Pick Date',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.accent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 12),
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 12),
                      _buildTransactionList(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ── Summary KPI Cards ─────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    final totalTrx = (_summary['totalTransactions'] ?? 0) as int;
    final totalRevenue = (_summary['totalRevenue'] is int)
        ? (_summary['totalRevenue'] as int).toDouble()
        : (_summary['totalRevenue'] as double?) ?? 0.0;
    final avgTrx = (_summary['avgTransaction'] is int)
        ? (_summary['avgTransaction'] as int).toDouble()
        : (_summary['avgTransaction'] as double?) ?? 0.0;

    return Column(
      children: [
        // Revenue card (featured)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.navy, Color(0xFF1B2D45)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.trending_up, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.get('total_revenue').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF90AAC8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatRupiah(totalRevenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy').format(_selectedDate),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Small metric cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.receipt_long,
                iconColor: AppColors.accent,
                iconBg: AppColors.accentSoft,
                label: AppLocalizations.get('transactions'),
                value: '$totalTrx',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.analytics_outlined,
                iconColor: AppColors.green,
                iconBg: const Color(0xFFF0FDF4),
                label: AppLocalizations.get('avg_per_transaction'),
                value: _formatRupiah(avgTrx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.category_outlined,
                iconColor: _kAmber,
                iconBg: const Color(0xFFFFFBEB),
                label: AppLocalizations.get('categories'),
                value: '${_categorySummary.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.txtHigh,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.txtLow,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Category Breakdown ────────────────────────────────────────────────────

  Widget _buildCategoryBreakdown() {
    final totalAll = _categorySummary.fold<double>(
      0.0,
      (sum, c) {
        final amt = c['totalAmount'];
        return sum + ((amt is int) ? amt.toDouble() : (amt as double?) ?? 0.0);
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.pie_chart_outline, color: AppColors.accent, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.get('sales_by_category').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.txtMid,
                  ),
                ),
              ],
            ),
          ),

          if (_categorySummary.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 28, color: AppColors.txtLow),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.get('no_transactions_today'),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtLow),
                    ),
                  ],
                ),
              ),
            )
          else
            // Table header
            ...[
              Container(
                color: AppColors.tableHead,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: _ColHeader(AppLocalizations.get('category').toUpperCase())),
                    Expanded(flex: 2, child: _ColHeaderCenter(AppLocalizations.get('qty').toUpperCase())),
                    Expanded(flex: 2, child: _ColHeaderCenter(AppLocalizations.get('trx').toUpperCase())),
                    Expanded(flex: 3, child: _ColHeaderRight(AppLocalizations.get('amount').toUpperCase())),
                    Expanded(flex: 2, child: _ColHeaderRight('%')),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ...List.generate(_categorySummary.length, (idx) {
                final cat = _categorySummary[idx];
                final catName = (cat['category'] as String?) ?? 'Uncategorized';
                final qty = (cat['totalQty'] as int?) ?? 0;
                final trxCount = (cat['transactionCount'] as int?) ?? 0;
                final amount = (cat['totalAmount'] is int)
                    ? (cat['totalAmount'] as int).toDouble()
                    : (cat['totalAmount'] as double?) ?? 0.0;
                final pct = totalAll > 0 ? (amount / totalAll * 100) : 0.0;
                final isAlt = idx % 2 == 1;

                return Column(
                  children: [
                    Container(
                      color: isAlt ? AppColors.rowAlt : AppColors.bgCard,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(idx),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    catName.isEmpty ? AppLocalizations.get('uncategorized') : catName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.txtHigh,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                '$trxCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.txtMid,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatRupiah(amount),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.txtHigh,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(idx).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _getCategoryColor(idx),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (idx < _categorySummary.length - 1)
                      const Divider(height: 1, color: AppColors.border),
                  ],
                );
              }),
              // Category total footer
              Container(
                color: AppColors.tableHead,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        AppLocalizations.get('total').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.txtHigh,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          '${_categorySummary.fold<int>(0, (s, c) => s + ((c['totalQty'] as int?) ?? 0))}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          '${(_summary['totalTransactions'] ?? 0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.txtHigh,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatRupiah(totalAll),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.txtMid,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      AppColors.accent,
      AppColors.green,
      _kAmber,
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFFEF4444),
      Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  // ── Transaction List ──────────────────────────────────────────────────────

  Widget _buildTransactionList() {
    // Group transaction details by transaction id
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (var row in _transactionDetails) {
      final trxId = (row['id'] as int?) ?? 0;
      grouped.putIfAbsent(trxId, () => []);
      grouped[trxId]!.add(row);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.list_alt, color: AppColors.green, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.get('transaction_history').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.txtMid,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderMid),
                  ),
                  child: Text(
                    '${grouped.length} ${AppLocalizations.get('transactions')}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.txtMid,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (grouped.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 28, color: AppColors.txtLow),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.get('no_transactions_recorded'),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtLow),
                    ),
                  ],
                ),
              ),
            )
          else
            ...grouped.entries.toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final trxId = entry.value.key;
              final items = entry.value.value;
              final first = items.first;
              final totalAmount = (first['totalAmount'] is int)
                  ? (first['totalAmount'] as int).toDouble()
                  : (first['totalAmount'] as double?) ?? 0.0;
              final vehicleNo = first['vehicleNo'] as String?;
              final dateStr = first['transactionDate'] as String? ?? '';

              String timeStr = '';
              if (dateStr.length > 10) {
                try {
                  final dt = DateTime.parse(dateStr);
                  timeStr = DateFormat('HH:mm').format(dt);
                } catch (_) {
                  timeStr = '';
                }
              }

              return Column(
                children: [
                  if (idx > 0) const Divider(height: 1, color: AppColors.border),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$trxId',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (vehicleNo != null && vehicleNo.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.two_wheeler, size: 10, color: AppColors.accent),
                                    const SizedBox(width: 3),
                                    Text(
                                      vehicleNo,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            if (timeStr.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time, size: 10, color: AppColors.txtLow),
                                  const SizedBox(width: 3),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.txtLow,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _formatRupiah(totalAmount),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Items in this transaction
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgPage,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: List.generate(items.length, (i) {
                              final item = items[i];
                              final itemName = (item['itemName'] as String?) ?? AppLocalizations.get('unknown_item');
                              final category = (item['category'] as String?) ?? '';
                              final qty = (item['quantity'] as int?) ?? 0;
                              final subtotal = (item['subtotal'] is int)
                                  ? (item['subtotal'] as int).toDouble()
                                  : (item['subtotal'] as double?) ?? 0.0;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                itemName,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.txtHigh,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (category.isNotEmpty)
                                                Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    color: AppColors.txtLow,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            'x$qty',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.txtMid,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            _formatRupiah(subtotal),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.txtHigh,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < items.length - 1)
                                    const Divider(height: 1, color: AppColors.border),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ── Column Header Widgets ───────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.txtLow,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _ColHeaderCenter extends StatelessWidget {
  final String text;
  const _ColHeaderCenter(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.txtLow,
        letterSpacing: 0.9,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ColHeaderRight extends StatelessWidget {
  final String text;
  const _ColHeaderRight(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.txtLow,
        letterSpacing: 0.9,
      ),
      textAlign: TextAlign.right,
    );
  }
}
