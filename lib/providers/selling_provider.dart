import 'package:flutter/foundation.dart';
import '../data/models/sale_item_model.dart';
import '../data/models/customer_model.dart';

class SellingProvider with ChangeNotifier {
  final List<SaleItemModel> _items = [];
  double _cash = 0.0;
  CustomerModel? _selectedCustomer;

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

  void addItem(SaleItemModel item) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(SaleItemModel item) {
    _items.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }

  void updateQuantity(SaleItemModel item, int newQuantity) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity = newQuantity;
      notifyListeners();
    }
  }

  void updateCash(String cashStr) {
    _cash = double.tryParse(cashStr) ?? 0.0;
    notifyListeners();
  }

  void clearTransaction() {
    _items.clear();
    _cash = 0.0;
    _selectedCustomer = null;
    notifyListeners();
  }

  void setCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }
}
