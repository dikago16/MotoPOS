import 'package:flutter/foundation.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transaction_item_model.dart';
import '../data/models/sale_item_model.dart';
import '../data/models/customer_model.dart';

class SellingProvider with ChangeNotifier {
  final List<SaleItemModel> _items = [];
  double _cash = 0.0;
  CustomerModel? _selectedCustomer;
  int? _editingTransactionId;
  TransactionModel? _editingTransaction;

  int? get editingTransactionId => _editingTransactionId;
  TransactionModel? get editingTransaction => _editingTransaction;

  List<SaleItemModel> get items => _items;
  double get cash => _cash;
  CustomerModel? get selectedCustomer => _selectedCustomer;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get changeAmount {
    final change = _cash - totalAmount;
    return change > 0 ? change : 0.0;
  }

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Whether any items in cart have invalid quantity (<= 0) or invalid price (< 0)
  bool get hasInvalidItems {
    return _items.isEmpty ||
        _items.any((item) => item.quantity <= 0 || item.price < 0);
  }

  /// Add item to cart with stock validation.
  /// Returns `true` if added successfully, `false` if stock is exceeded.
  bool addItem(SaleItemModel item) {
    if (item.quantity <= 0) return false;

    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      final targetQty = existing.quantity + item.quantity;
      if (item.isCountStock && targetQty > item.stockQty) {
        return false;
      }
      existing.quantity = targetQty;
    } else {
      if (item.isCountStock && item.quantity > item.stockQty) {
        return false;
      }
      _items.add(item);
    }
    notifyListeners();
    return true;
  }

  void removeItem(SaleItemModel item) {
    _items.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }

  /// Update item quantity with >= 1 and stock limit enforcement.
  /// Returns `true` if valid, `false` otherwise.
  bool updateQuantity(SaleItemModel item, int newQuantity) {
    if (newQuantity <= 0) return false;

    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      if (item.isCountStock && newQuantity > item.stockQty) {
        return false;
      }
      _items[existingIndex].quantity = newQuantity;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Supervisor Price Override: update unit price when authorized by Owner PIN
  void updateItemPrice(SaleItemModel item, double newPrice) {
    if (newPrice < 0) return;

    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      existing.price = newPrice;
      existing.isPriceOverridden = (newPrice != existing.originalPrice);
      notifyListeners();
    }
  }

  void updateCash(String cashStr) {
    _cash = double.tryParse(cashStr) ?? 0.0;
    notifyListeners();
  }

  void loadTransactionForEdit(
    TransactionModel txn,
    List<TransactionItemModel> txnItems,
    CustomerModel? customer,
  ) {
    _editingTransactionId = txn.id;
    _editingTransaction = txn;
    _selectedCustomer = customer;
    _cash = txn.cashAmount;
    _items.clear();
    for (var ti in txnItems) {
      _items.add(
        SaleItemModel(
          id: ti.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: ti.itemName,
          category: ti.category,
          price: ti.price,
          quantity: ti.quantity,
          originalPrice: ti.price,
        ),
      );
    }
    notifyListeners();
  }

  void clearTransaction() {
    _items.clear();
    _cash = 0.0;
    _selectedCustomer = null;
    _editingTransactionId = null;
    _editingTransaction = null;
    notifyListeners();
  }

  void setCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }
}
