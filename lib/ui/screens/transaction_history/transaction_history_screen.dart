import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/db_helper.dart';
import '../../../core/services/app_localizations.dart';

import 'transaction_detail_screen.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kAccentSoft = Color(0xFFEFF6FF);
const _kBgPage = Color(0xFFF1F5F9);
const _kBgCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE2E8F0);
const _kTableHead = Color(0xFFF8FAFC);
const _kTxtMid = Color(0xFF475569);
const _kTxtLow = Color(0xFF94A3B8);
const _kTxtHigh = Color(0xFF0F172A);

const _kColHeader = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: Color(0xFF94A3B8),
  letterSpacing: 0.9,
);
// ──────────────────────────────────────────────────────────────────────────────

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    final transactions = await DBHelper.getAllTransactions();
    setState(() {
      _allTransactions = transactions;
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kNavy,
              onPrimary: Colors.white,
              surface: _kBgCard,
              onSurface: _kTxtHigh,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatRupiah(double v) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

  InputDecoration _inputDeco(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      suffixIcon: suffixIcon,
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            Icon(icon, size: 12, color: _kAccent),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
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
    // Filter transactions
    final filteredTransactions = _allTransactions.where((txn) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = (txn.vehicleNo?.toLowerCase() ?? '').contains(query);
      }
      bool matchesDate = true;
      if (_selectedDate != null) {
        final txnDate = DateTime.parse(txn.transactionDate);
        matchesDate = txnDate.year == _selectedDate!.year &&
            txnDate.month == _selectedDate!.month &&
            txnDate.day == _selectedDate!.day;
      }
      return matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: _kBgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchCard(),
                    const SizedBox(height: 10),
                    _buildTransactionsList(filteredTransactions),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
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
            AppLocalizations.get('transaction_history'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            AppLocalizations.get('sales_records'),
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
          icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
          onPressed: _pickDate,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: _kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(AppLocalizations.get('search_transactions'), icon: Icons.search),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDeco(AppLocalizations.get('vehicle_no')),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _selectedDate != null ? _kAccent : _kAccentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _selectedDate != null
                          ? _kAccent
                          : _kAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: _selectedDate != null ? Colors.white : _kAccent,
                        size: 16,
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yy').format(_selectedDate!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> filteredTransactions) {
    return Container(
      decoration: BoxDecoration(
        color: _kBgCard,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _sectionLabel(
              AppLocalizations.get('sales_records'),
              icon: Icons.receipt,
            ),
          ),
          Container(
            color: _kTableHead,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(AppLocalizations.get('transaction').toUpperCase(), style: _kColHeader)),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.get('date').toUpperCase(), style: _kColHeader),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(AppLocalizations.get('total').toUpperCase(), style: _kColHeader),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: _kAccent)),
            )
          else if (filteredTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.receipt, size: 30, color: _kTxtLow.withValues(alpha: 0.5)),
                  const SizedBox(height: 7),
                  Text(
                    AppLocalizations.get('no_transactions_recorded'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kTxtLow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _kBorder),
              itemBuilder: (context, index) {
                final txn = filteredTransactions[index];
                final date = DateTime.parse(txn.transactionDate);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                          transaction: txn,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TXN #${txn.id}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kAccent,
                                ),
                              ),
                              if (txn.vehicleNo != null && txn.vehicleNo!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  txn.vehicleNo!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _kTxtMid,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat('dd MMM yyyy HH:mm').format(date),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _kTxtMid,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatRupiah(txn.totalAmount),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kTxtHigh,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
