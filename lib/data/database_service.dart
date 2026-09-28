import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'models/transaction_item_model.dart';
import 'models/supplier_model.dart';
import 'models/purchase_invoice_model.dart';
import 'models/purchase_invoice_item_model.dart';
import 'models/customer_model.dart';
import 'models/note_model.dart';
import 'models/store_info_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Database? _db;
  static const int _version = 11;
  static const String _tableName = 'products';
  static const String _categoryTable = 'categories';
  static const String _transactionTable = 'transactions';
  static const String _transactionItemsTable = 'transaction_items';
  static const String _supplierTable = 'suppliers';
  static const String _purchaseInvoiceTable = 'purchase_invoices';
  static const String _purchaseInvoiceItemsTable = 'purchase_invoice_items';
  static const String _customerTable = 'customers';
  static const String _notesTable = 'notes';
  static const String _storeInfoTable = 'store_info';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'motopos.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemCode TEXT,
            itemName TEXT,
            category TEXT DEFAULT 'uncategorized',
            buyingPrice REAL,
            packetBuyPrice REAL,
            packetBuyQty INTEGER,
            sellingPrice REAL,
            packetSellPrice REAL,
            packetSellQty INTEGER,
            discountType TEXT,
            discountValue REAL,
            unit TEXT,
            isCountStock INTEGER,
            stockQty INTEGER
          )
          ''');
        await db.execute('''
          CREATE TABLE $_categoryTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoryCode TEXT,
            categoryName TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_transactionTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionDate TEXT,
            totalAmount REAL,
            cashAmount REAL,
            changeAmount REAL,
            vehicleNo TEXT,
            customerId INTEGER,
            customerName TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_transactionItemsTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionId INTEGER,
            itemName TEXT,
            category TEXT,
            price REAL,
            quantity INTEGER,
            subtotal REAL
          )
          ''');
        await db.execute('''
          CREATE TABLE $_supplierTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            supplierCode TEXT,
            supplierName TEXT,
            phone TEXT,
            address TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_purchaseInvoiceTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceCode TEXT,
            invoiceDate TEXT,
            supplierId INTEGER,
            supplierName TEXT,
            totalAmount REAL,
            notes TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_purchaseInvoiceItemsTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceId INTEGER,
            productId INTEGER,
            itemCode TEXT,
            itemName TEXT,
            quantity INTEGER,
            buyingPrice REAL,
            subtotal REAL
          )
          ''');
        await db.execute('''
          CREATE TABLE $_customerTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerCode TEXT,
            name TEXT,
            phone TEXT,
            vehicleNo TEXT,
            vehicleType TEXT,
            address TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_notesTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            createdAt TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_storeInfoTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            storeName TEXT,
            address TEXT,
            phone TEXT
          )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE $_categoryTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              categoryCode TEXT,
              categoryName TEXT
            )
            ''');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN category TEXT DEFAULT "uncategorized"',
          );
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE $_transactionTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transactionDate TEXT,
              totalAmount REAL,
              cashAmount REAL,
              changeAmount REAL,
              vehicleNo TEXT
            )
            ''');
          await db.execute('''
            CREATE TABLE $_transactionItemsTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transactionId INTEGER,
              itemName TEXT,
              category TEXT,
              price REAL,
              quantity INTEGER,
              subtotal REAL
            )
            ''');
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE $_transactionTable ADD COLUMN vehicleNo TEXT',
          );
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE $_supplierTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              supplierCode TEXT,
              supplierName TEXT,
              phone TEXT,
              address TEXT
            )
            ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE $_purchaseInvoiceTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              invoiceCode TEXT,
              invoiceDate TEXT,
              supplierId INTEGER,
              supplierName TEXT,
              totalAmount REAL,
              notes TEXT
            )
            ''');
          await db.execute('''
            CREATE TABLE $_purchaseInvoiceItemsTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              invoiceId INTEGER,
              productId INTEGER,
              itemCode TEXT,
              itemName TEXT,
              quantity INTEGER,
              buyingPrice REAL,
              subtotal REAL
            )
            ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE $_customerTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customerCode TEXT,
              name TEXT,
              phone TEXT,
              vehicleNo TEXT,
              vehicleType TEXT,
              address TEXT
            )
            ''');
        }
        if (oldVersion < 9) {
          await db.execute(
            'ALTER TABLE $_transactionTable ADD COLUMN customerId INTEGER',
          );
          await db.execute(
            'ALTER TABLE $_transactionTable ADD COLUMN customerName TEXT',
          );
        }
        if (oldVersion < 10) {
          await db.execute('''
            CREATE TABLE $_notesTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              content TEXT,
              createdAt TEXT
            )
            ''');
        }
        if (oldVersion < 11) {
          await db.execute('''
            CREATE TABLE $_storeInfoTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              storeName TEXT,
              address TEXT,
              phone TEXT
            )
            ''');
        }
      },
    );
  }

  // --- Products ---

  Future<int> insertProduct(Product product) async {
    try {
      final dbClient = await db;
      return await dbClient.insert(
        _tableName,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DatabaseService error in insertProduct: $e');
      rethrow;
    }
  }

  Future<int> updateProduct(Product product) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        _tableName,
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in updateProduct: $e');
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in deleteProduct: $e');
      rethrow;
    }
  }

  Future<int> getProductCount() async {
    try {
      final dbClient = await db;
      final result = await dbClient.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('DatabaseService error in getProductCount: $e');
      return 0;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(_tableName);
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getProducts: $e');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final dbClient = await db;
      // Sanitize input to escape SQLite LIKE wildcards
      final sanitizedQuery = query
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');

      final List<Map<String, dynamic>> maps = await dbClient.query(
        _tableName,
        where: 'itemName LIKE ? ESCAPE \'\\\' OR itemCode LIKE ? ESCAPE \'\\\'',
        whereArgs: ['$sanitizedQuery%', '$sanitizedQuery%'],
        limit: 100, // Batasi hasil pencarian agar performa UI tetap ringan
      );
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in searchProducts: $e');
      return [];
    }
  }

  Future<String> getNextItemCode() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT itemCode FROM $_tableName WHERE itemCode LIKE "ITEM%" ORDER BY id DESC LIMIT 1',
      );
      if (result.isEmpty) {
        return 'ITEM00001';
      } else {
        String lastCode = result.first['itemCode'] as String;
        String numberPart = lastCode.substring(4);
        int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
        return 'ITEM${nextNumber.toString().padLeft(5, '0')}';
      }
    } catch (e) {
      debugPrint('DatabaseService error in getNextItemCode: $e');
      rethrow;
    }
  }

  // --- Categories ---

  Future<int> insertCategory(CategoryModel category) async {
    try {
      final dbClient = await db;
      return await dbClient.insert(
        _categoryTable,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DatabaseService error in insertCategory: $e');
      rethrow;
    }
  }

  Future<int> updateCategory(CategoryModel category) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        _categoryTable,
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in updateCategory: $e');
      rethrow;
    }
  }

  Future<int> deleteCategory(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete(
        _categoryTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in deleteCategory: $e');
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _categoryTable,
      );
      return List.generate(maps.length, (i) {
        return CategoryModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getCategories: $e');
      rethrow;
    }
  }

  Future<String> getNextCategoryCode() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT categoryCode FROM $_categoryTable WHERE categoryCode LIKE "CAT%" ORDER BY id DESC LIMIT 1',
      );
      if (result.isEmpty) {
        return 'CAT00001';
      } else {
        String lastCode = result.first['categoryCode'] as String;
        String numberPart = lastCode.substring(3);
        int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
        return 'CAT${nextNumber.toString().padLeft(5, '0')}';
      }
    } catch (e) {
      debugPrint('DatabaseService error in getNextCategoryCode: $e');
      rethrow;
    }
  }

  // --- Transactions ---

  Future<int> saveTransaction(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    try {
      final dbClient = await db;
      return await dbClient.transaction((txn) async {
        int id = await txn.insert(_transactionTable, transaction.toMap());
        for (var item in items) {
          var itemMap = item.toMap();
          itemMap['transactionId'] = id;
          await txn.insert(_transactionItemsTable, itemMap);
        }
        return id;
      });
    } catch (e) {
      debugPrint('DatabaseService error in saveTransaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(
    int transactionId,
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    try {
      final dbClient = await db;
      await dbClient.transaction((txn) async {
        final updateData = transaction.toMap();
        updateData.remove(
          'id',
        ); // Remove id to avoid updating primary key with null

        await txn.update(
          _transactionTable,
          updateData,
          where: 'id = ?',
          whereArgs: [transactionId],
        );
        await txn.delete(
          _transactionItemsTable,
          where: 'transactionId = ?',
          whereArgs: [transactionId],
        );
        for (var item in items) {
          var itemMap = item.toMap();
          itemMap.remove('id');
          itemMap['transactionId'] = transactionId;
          await txn.insert(_transactionItemsTable, itemMap);
        }
      });
    } catch (e) {
      debugPrint('DatabaseService error in updateTransaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      final dbClient = await db;
      await dbClient.transaction((txn) async {
        await txn.delete(
          _transactionTable,
          where: 'id = ?',
          whereArgs: [transactionId],
        );
        await txn.delete(
          _transactionItemsTable,
          where: 'transactionId = ?',
          whereArgs: [transactionId],
        );
      });
    } catch (e) {
      debugPrint('DatabaseService error in deleteTransaction: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _transactionTable,
        orderBy: 'id DESC',
      );
      return List.generate(
        maps.length,
        (i) => TransactionModel.fromMap(maps[i]),
      );
    } catch (e) {
      debugPrint('DatabaseService error in getAllTransactions: $e');
      rethrow;
    }
  }

  Future<List<TransactionItemModel>> getTransactionItems(
    int transactionId,
  ) async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _transactionItemsTable,
        where: 'transactionId = ?',
        whereArgs: [transactionId],
      );
      return List.generate(
        maps.length,
        (i) => TransactionItemModel.fromMap(maps[i]),
      );
    } catch (e) {
      debugPrint('DatabaseService error in getTransactionItems: $e');
      rethrow;
    }
  }

  // --- Daily Report ---

  Future<List<TransactionModel>> getTransactionsByDate(String date) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _transactionTable,
      where: 'transactionDate LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getDailyCategorySummary(
    String date,
  ) async {
    final dbClient = await db;
    return await dbClient.rawQuery(
      '''
      SELECT 
        ti.category,
        COUNT(DISTINCT t.id) AS transactionCount,
        SUM(ti.quantity) AS totalQty,
        SUM(ti.subtotal) AS totalAmount
      FROM $_transactionItemsTable ti
      INNER JOIN $_transactionTable t ON ti.transactionId = t.id
      WHERE t.transactionDate LIKE ?
      GROUP BY ti.category
      ORDER BY totalAmount DESC
    ''',
      ['$date%'],
    );
  }

  Future<Map<String, dynamic>> getDailySummary(String date) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      '''
      SELECT 
        COUNT(*) AS totalTransactions,
        COALESCE(SUM(totalAmount), 0) AS totalRevenue,
        COALESCE(AVG(totalAmount), 0) AS avgTransaction
      FROM $_transactionTable
      WHERE transactionDate LIKE ?
    ''',
      ['$date%'],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return {'totalTransactions': 0, 'totalRevenue': 0.0, 'avgTransaction': 0.0};
  }

  Future<List<Map<String, dynamic>>> getTransactionDetailsByDate(
    String date,
  ) async {
    final dbClient = await db;
    return await dbClient.rawQuery(
      '''
      SELECT 
        t.id,
        t.transactionDate,
        t.totalAmount,
        t.vehicleNo,
        ti.itemName,
        ti.category,
        ti.price,
        ti.quantity,
        ti.subtotal
      FROM $_transactionTable t
      INNER JOIN $_transactionItemsTable ti ON t.id = ti.transactionId
      WHERE t.transactionDate LIKE ?
      ORDER BY t.id DESC
    ''',
      ['$date%'],
    );
  }

  // --- Suppliers ---

  Future<int> insertSupplier(SupplierModel supplier) async {
    try {
      final dbClient = await db;
      return await dbClient.insert(
        _supplierTable,
        supplier.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DatabaseService error in insertSupplier: $e');
      rethrow;
    }
  }

  Future<int> updateSupplier(SupplierModel supplier) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        _supplierTable,
        supplier.toMap(),
        where: 'id = ?',
        whereArgs: [supplier.id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in updateSupplier: $e');
      rethrow;
    }
  }

  Future<int> deleteSupplier(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete(
        _supplierTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in deleteSupplier: $e');
      rethrow;
    }
  }

  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _supplierTable,
      );
      return List.generate(maps.length, (i) {
        return SupplierModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getSuppliers: $e');
      rethrow;
    }
  }

  Future<String> getNextSupplierCode() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT supplierCode FROM $_supplierTable WHERE supplierCode LIKE "SUPP%" ORDER BY id DESC LIMIT 1',
      );
      if (result.isEmpty) {
        return 'SUPP00001';
      } else {
        String lastCode = result.first['supplierCode'] as String;
        String numberPart = lastCode.substring(4);
        int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
        return 'SUPP${nextNumber.toString().padLeft(5, '0')}';
      }
    } catch (e) {
      debugPrint('DatabaseService error in getNextSupplierCode: $e');
      rethrow;
    }
  }

  // --- Purchase Invoices ---

  Future<int> savePurchaseInvoice(
    PurchaseInvoiceModel invoice,
    List<PurchaseInvoiceItemModel> items,
  ) async {
    try {
      final dbClient = await db;
      return await dbClient.transaction((txn) async {
        int invoiceId = await txn.insert(
          _purchaseInvoiceTable,
          invoice.toMap(),
        );
        for (var item in items) {
          var itemMap = item.toMap();
          itemMap['invoiceId'] = invoiceId;
          await txn.insert(_purchaseInvoiceItemsTable, itemMap);

          // Update stock and buying price for products
          final productRows = await txn.query(
            _tableName,
            where: 'id = ?',
            whereArgs: [item.productId],
          );
          if (productRows.isNotEmpty) {
            final product = Product.fromMap(productRows.first);
            Map<String, dynamic> updateData = {};

            // Update buying price to the latest one if it's > 0
            if (item.buyingPrice > 0) {
              updateData['buyingPrice'] = item.buyingPrice;
            }

            // Update stock if it's a stockable item
            if (product.isCountStock) {
              updateData['stockQty'] = product.stockQty + item.quantity;
            }

            if (updateData.isNotEmpty) {
              await txn.update(
                _tableName,
                updateData,
                where: 'id = ?',
                whereArgs: [item.productId],
              );
            }
          }
        }
        return invoiceId;
      });
    } catch (e) {
      debugPrint('DatabaseService error in savePurchaseInvoice: $e');
      rethrow;
    }
  }

  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _purchaseInvoiceTable,
        orderBy: 'id DESC',
      );
      return List.generate(maps.length, (i) {
        return PurchaseInvoiceModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getPurchaseInvoices: $e');
      rethrow;
    }
  }

  Future<List<PurchaseInvoiceItemModel>> getPurchaseInvoiceItems(
    int invoiceId,
  ) async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _purchaseInvoiceItemsTable,
        where: 'invoiceId = ?',
        whereArgs: [invoiceId],
      );
      return List.generate(maps.length, (i) {
        return PurchaseInvoiceItemModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getPurchaseInvoiceItems: $e');
      rethrow;
    }
  }

  Future<String> getNextPurchaseInvoiceCode() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT invoiceCode FROM $_purchaseInvoiceTable WHERE invoiceCode LIKE "PINV%" ORDER BY id DESC LIMIT 1',
      );
      if (result.isEmpty) {
        return 'PINV00001';
      } else {
        String lastCode = result.first['invoiceCode'] as String;
        String numberPart = lastCode.substring(4);
        int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
        return 'PINV${nextNumber.toString().padLeft(5, '0')}';
      }
    } catch (e) {
      debugPrint('DatabaseService error in getNextPurchaseInvoiceCode: $e');
      rethrow;
    }
  }

  // --- Customers ---

  Future<int> insertCustomer(CustomerModel customer) async {
    try {
      final dbClient = await db;
      return await dbClient.insert(
        _customerTable,
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DatabaseService error in insertCustomer: $e');
      rethrow;
    }
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        _customerTable,
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in updateCustomer: $e');
      rethrow;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete(
        _customerTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in deleteCustomer: $e');
      rethrow;
    }
  }

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _customerTable,
      );
      return List.generate(maps.length, (i) {
        return CustomerModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getCustomers: $e');
      rethrow;
    }
  }

  Future<String> getNextCustomerCode() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT customerCode FROM $_customerTable WHERE customerCode LIKE "CUST%" ORDER BY id DESC LIMIT 1',
      );
      if (result.isEmpty) {
        return 'CUST00001';
      } else {
        String lastCode = result.first['customerCode'] as String;
        String numberPart = lastCode.substring(4);
        int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
        return 'CUST${nextNumber.toString().padLeft(5, '0')}';
      }
    } catch (e) {
      debugPrint('DatabaseService error in getNextCustomerCode: $e');
      rethrow;
    }
  }

  // --- Notes ---

  Future<int> insertNote(NoteModel note) async {
    try {
      final dbClient = await db;
      return await dbClient.insert(
        _notesTable,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DatabaseService error in insertNote: $e');
      rethrow;
    }
  }

  Future<int> updateNote(NoteModel note) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        _notesTable,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in updateNote: $e');
      rethrow;
    }
  }

  Future<int> deleteNote(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete(
        _notesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('DatabaseService error in deleteNote: $e');
      rethrow;
    }
  }

  Future<List<NoteModel>> getNotes() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _notesTable,
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('DatabaseService error in getNotes: $e');
      rethrow;
    }
  }

  // --- Store Info ---

  Future<StoreInfoModel> getStoreInfo() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        _storeInfoTable,
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return StoreInfoModel.fromMap(maps.first);
      }
      return StoreInfoModel.defaults();
    } catch (e) {
      debugPrint('DatabaseService error in getStoreInfo: $e');
      rethrow;
    }
  }

  Future<int> saveStoreInfo(StoreInfoModel info) async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> existing = await dbClient.query(
        _storeInfoTable,
        limit: 1,
      );
      if (existing.isNotEmpty) {
        return await dbClient.update(
          _storeInfoTable,
          info.toMap()..remove('id'),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        return await dbClient.insert(
          _storeInfoTable,
          info.toMap()..remove('id'),
        );
      }
    } catch (e) {
      debugPrint('DatabaseService error in saveStoreInfo: $e');
      rethrow;
    }
  }

  // --- Backup & Restore ---

  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final dbClient = await db;
      final Map<String, dynamic> data = {};

      data[_tableName] = await dbClient.query(_tableName);
      data[_categoryTable] = await dbClient.query(_categoryTable);
      data[_transactionTable] = await dbClient.query(_transactionTable);
      data[_transactionItemsTable] = await dbClient.query(
        _transactionItemsTable,
      );
      data[_supplierTable] = await dbClient.query(_supplierTable);
      data[_purchaseInvoiceTable] = await dbClient.query(_purchaseInvoiceTable);
      data[_purchaseInvoiceItemsTable] = await dbClient.query(
        _purchaseInvoiceItemsTable,
      );
      data[_customerTable] = await dbClient.query(_customerTable);
      data[_notesTable] = await dbClient.query(_notesTable);
      data[_storeInfoTable] = await dbClient.query(_storeInfoTable);

      return data;
    } catch (e) {
      debugPrint('DatabaseService error in exportAllData: $e');
      rethrow;
    }
  }

  Future<void> clearAllTables(Transaction txn) async {
    try {
      await txn.delete(_tableName);
      await txn.delete(_categoryTable);
      await txn.delete(_transactionTable);
      await txn.delete(_transactionItemsTable);
      await txn.delete(_supplierTable);
      await txn.delete(_purchaseInvoiceTable);
      await txn.delete(_purchaseInvoiceItemsTable);
      await txn.delete(_customerTable);
      await txn.delete(_notesTable);
      await txn.delete(_storeInfoTable);
    } catch (e) {
      debugPrint('DatabaseService error in clearAllTables: $e');
      rethrow;
    }
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    try {
      final dbClient = await db;
      await dbClient.transaction((txn) async {
        await clearAllTables(txn);

        for (String table in data.keys) {
          List<dynamic> rows = data[table] ?? [];
          for (var row in rows) {
            await txn.insert(table, Map<String, dynamic>.from(row));
          }
        }
      });
    } catch (e) {
      debugPrint('DatabaseService error in importAllData: $e');
      rethrow;
    }
  }
}
