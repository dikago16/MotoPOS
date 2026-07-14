import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/supplier_model.dart';
import '../../../core/services/app_localizations.dart';
import 'purchase_invoice_constants.dart';

class PurchaseInvoiceInfoView extends StatelessWidget {
  final String invoiceCode;
  final DateTime invoiceDate;
  final SupplierModel? selectedSupplier;
  final List<SupplierModel> suppliers;
  final TextEditingController notesCtrl;
  final VoidCallback onPickDate;
  final ValueChanged<int?> onSupplierChanged;
  final VoidCallback onClearForm;
  final VoidCallback onNext;

  const PurchaseInvoiceInfoView({
    super.key,
    required this.invoiceCode,
    required this.invoiceDate,
    required this.selectedSupplier,
    required this.suppliers,
    required this.notesCtrl,
    required this.onPickDate,
    required this.onSupplierChanged,
    required this.onClearForm,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionLabel(AppLocalizations.get('invoice_information'), icon: Icons.receipt_long),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(fontSize: 13, color: kTxtMid),
                          decoration: inputDeco(AppLocalizations.get('invoice_code')).copyWith(
                            fillColor: kBgPage,
                          ),
                          controller: TextEditingController(text: invoiceCode),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: onPickDate,
                          borderRadius: BorderRadius.circular(6),
                          child: InputDecorator(
                            decoration: inputDeco(AppLocalizations.get('invoice_date')),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(invoiceDate),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kTxtHigh,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: kAccent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedSupplier?.id,
                    decoration: inputDeco(AppLocalizations.get('select_supplier')),
                    style: const TextStyle(fontSize: 13, color: kTxtHigh),
                    dropdownColor: kBgCard,
                    isExpanded: true,
                    items: suppliers.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(
                          '${s.supplierCode} — ${s.supplierName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onSupplierChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    decoration: inputDeco('Notes (Optional)'),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kBgCard,
        border: Border(top: BorderSide(color: kBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: onClearForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBgPage,
                  foregroundColor: kTxtMid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: kBorderMid),
                  ),
                ),
                child: const Text(
                  'ABORT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
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
