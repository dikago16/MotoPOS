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
        await db.execute(
          '''
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
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_categoryTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoryCode TEXT,
            categoryName TEXT
          )
          ''',
        );
        await db.execute(
          '''
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
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_transactionItemsTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionId INTEGER,
            itemName TEXT,
            category TEXT,
            price REAL,
            quantity INTEGER,
            subtotal REAL
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_supplierTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            supplierCode TEXT,
            supplierName TEXT,
            phone TEXT,
            address TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_purchaseInvoiceTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceCode TEXT,
            invoiceDate TEXT,
            supplierId INTEGER,
            supplierName TEXT,
            totalAmount REAL,
            notes TEXT
          )
          ''',
        );
        await db.execute(
          '''
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
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_customerTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerCode TEXT,
            name TEXT,
            phone TEXT,
            vehicleNo TEXT,
            vehicleType TEXT,
            address TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_notesTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            createdAt TEXT
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE $_storeInfoTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            storeName TEXT,
            address TEXT,
            phone TEXT
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            '''
            CREATE TABLE $_categoryTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              categoryCode TEXT,
              categoryName TEXT
            )
            ''',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN category TEXT DEFAULT "uncategorized"',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            '''
            CREATE TABLE $_transactionTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transactionDate TEXT,
              totalAmount REAL,
              cashAmount REAL,
              changeAmount REAL,
              vehicleNo TEXT
            )
            ''',
          );
          await db.execute(
            '''
            CREATE TABLE $_transactionItemsTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transactionId INTEGER,
              itemName TEXT,
              category TEXT,
              price REAL,
              quantity INTEGER,
              subtotal REAL
            )
            ''',
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE $_transactionTable ADD COLUMN vehicleNo TEXT',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            '''
            CREATE TABLE $_supplierTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              supplierCode TEXT,
              supplierName TEXT,
              phone TEXT,
              address TEXT
            )
            ''',
          );
        }
        if (oldVersion < 7) {
          await db.execute(
            '''
            CREATE TABLE $_purchaseInvoiceTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              invoiceCode TEXT,
              invoiceDate TEXT,
              supplierId INTEGER,
              supplierName TEXT,
              totalAmount REAL,
              notes TEXT
            )
            ''',
          );
          await db.execute(
            '''
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
            ''',
          );
        }
        if (oldVersion < 8) {
          await db.execute(
            '''
            CREATE TABLE $_customerTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customerCode TEXT,
              name TEXT,
              phone TEXT,
              vehicleNo TEXT,
              vehicleType TEXT,
              address TEXT
            )
            ''',
          );
        }
        if (oldVersion < 9) {
          await db.execute('ALTER TABLE $_transactionTable ADD COLUMN customerId INTEGER');
          await db.execute('ALTER TABLE $_transactionTable ADD COLUMN customerName TEXT');
        }
        if (oldVersion < 10) {
          await db.execute(
            '''
            CREATE TABLE $_notesTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              content TEXT,
              createdAt TEXT
            )
            ''',
          );
        }
        if (oldVersion < 11) {
          await db.execute(
            '''
            CREATE TABLE $_storeInfoTable(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              storeName TEXT,
              address TEXT,
              phone TEXT
            )
            ''',
          );
        }
      },
    );
  }

  // --- Products ---

  Future<int> insertProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.insert(
      _tableName,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.update(
      _tableName,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_tableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<String> getNextItemCode() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT itemCode FROM $_tableName WHERE itemCode LIKE "ITEM%" ORDER BY id DESC LIMIT 1');
    if (result.isEmpty) {
      return 'ITEM00001';
    } else {
      String lastCode = result.first['itemCode'] as String;
      String numberPart = lastCode.substring(4);
      int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      return 'ITEM${nextNumber.toString().padLeft(5, '0')}';
    }
  }

  // --- Categories ---

  Future<int> insertCategory(CategoryModel category) async {
    final dbClient = await db;
    return await dbClient.insert(
      _categoryTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCategory(CategoryModel category) async {
    final dbClient = await db;
    return await dbClient.update(
      _categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_categoryTable);
    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<String> getNextCategoryCode() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT categoryCode FROM $_categoryTable WHERE categoryCode LIKE "CAT%" ORDER BY id DESC LIMIT 1');
    if (result.isEmpty) {
      return 'CAT00001';
    } else {
      String lastCode = result.first['categoryCode'] as String;
      String numberPart = lastCode.substring(3);
      int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      return 'CAT${nextNumber.toString().padLeft(5, '0')}';
    }
  }

  // --- Transactions ---

  Future<int> saveTransaction(TransactionModel transaction, List<TransactionItemModel> items) async {
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
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _transactionTable,
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _transactionItemsTable,
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    return List.generate(maps.length, (i) => TransactionItemModel.fromMap(maps[i]));
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

  Future<List<Map<String, dynamic>>> getDailyCategorySummary(String date) async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
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
    ''', ['$date%']);
  }

  Future<Map<String, dynamic>> getDailySummary(String date) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT 
        COUNT(*) AS totalTransactions,
        COALESCE(SUM(totalAmount), 0) AS totalRevenue,
        COALESCE(AVG(totalAmount), 0) AS avgTransaction
      FROM $_transactionTable
      WHERE transactionDate LIKE ?
    ''', ['$date%']);
    if (result.isNotEmpty) {
      return result.first;
    }
    return {'totalTransactions': 0, 'totalRevenue': 0.0, 'avgTransaction': 0.0};
  }

  Future<List<Map<String, dynamic>>> getTransactionDetailsByDate(String date) async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
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
    ''', ['$date%']);
  }

  // --- Suppliers ---

  Future<int> insertSupplier(SupplierModel supplier) async {
    final dbClient = await db;
    return await dbClient.insert(
      _supplierTable,
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateSupplier(SupplierModel supplier) async {
    final dbClient = await db;
    return await dbClient.update(
      _supplierTable,
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _supplierTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SupplierModel>> getSuppliers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_supplierTable);
    return List.generate(maps.length, (i) {
      return SupplierModel.fromMap(maps[i]);
    });
  }

  Future<String> getNextSupplierCode() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT supplierCode FROM $_supplierTable WHERE supplierCode LIKE "SUPP%" ORDER BY id DESC LIMIT 1');
    if (result.isEmpty) {
      return 'SUPP00001';
    } else {
      String lastCode = result.first['supplierCode'] as String;
      String numberPart = lastCode.substring(4);
      int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      return 'SUPP${nextNumber.toString().padLeft(5, '0')}';
    }
  }

  // --- Purchase Invoices ---

  Future<int> savePurchaseInvoice(
    PurchaseInvoiceModel invoice,
    List<PurchaseInvoiceItemModel> items,
  ) async {
    final dbClient = await db;
    return await dbClient.transaction((txn) async {
      int invoiceId = await txn.insert(_purchaseInvoiceTable, invoice.toMap());
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
  }

  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _purchaseInvoiceTable,
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return PurchaseInvoiceModel.fromMap(maps[i]);
    });
  }

  Future<List<PurchaseInvoiceItemModel>> getPurchaseInvoiceItems(
    int invoiceId,
  ) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _purchaseInvoiceItemsTable,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    return List.generate(maps.length, (i) {
      return PurchaseInvoiceItemModel.fromMap(maps[i]);
    });
  }

  Future<String> getNextPurchaseInvoiceCode() async {
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
  }

  // --- Customers ---

  Future<int> insertCustomer(CustomerModel customer) async {
    final dbClient = await db;
    return await dbClient.insert(
      _customerTable,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final dbClient = await db;
    return await dbClient.update(
      _customerTable,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _customerTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CustomerModel>> getCustomers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_customerTable);
    return List.generate(maps.length, (i) {
      return CustomerModel.fromMap(maps[i]);
    });
  }

  Future<String> getNextCustomerCode() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT customerCode FROM $_customerTable WHERE customerCode LIKE "CUST%" ORDER BY id DESC LIMIT 1');
    if (result.isEmpty) {
      return 'CUST00001';
    } else {
      String lastCode = result.first['customerCode'] as String;
      String numberPart = lastCode.substring(4);
      int nextNumber = (int.tryParse(numberPart) ?? 0) + 1;
      return 'CUST${nextNumber.toString().padLeft(5, '0')}';
    }
  }

  // --- Notes ---

  Future<int> insertNote(NoteModel note) async {
    final dbClient = await db;
    return await dbClient.insert(
      _notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateNote(NoteModel note) async {
    final dbClient = await db;
    return await dbClient.update(
      _notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> getNotes() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_notesTable, orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

  // --- Store Info ---

  Future<StoreInfoModel> getStoreInfo() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_storeInfoTable, limit: 1);
    if (maps.isNotEmpty) {
      return StoreInfoModel.fromMap(maps.first);
    }
    return StoreInfoModel.defaults();
  }

  Future<int> saveStoreInfo(StoreInfoModel info) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> existing = await dbClient.query(_storeInfoTable, limit: 1);
    if (existing.isNotEmpty) {
      return await dbClient.update(
        _storeInfoTable,
        info.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      return await dbClient.insert(_storeInfoTable, info.toMap()..remove('id'));
    }
  }

  // --- Backup & Restore ---

  Future<Map<String, dynamic>> exportAllData() async {
    final dbClient = await db;
    final Map<String, dynamic> data = {};

    data[_tableName] = await dbClient.query(_tableName);
    data[_categoryTable] = await dbClient.query(_categoryTable);
    data[_transactionTable] = await dbClient.query(_transactionTable);
    data[_transactionItemsTable] = await dbClient.query(_transactionItemsTable);
    data[_supplierTable] = await dbClient.query(_supplierTable);
    data[_purchaseInvoiceTable] = await dbClient.query(_purchaseInvoiceTable);
    data[_purchaseInvoiceItemsTable] = await dbClient.query(_purchaseInvoiceItemsTable);
    data[_customerTable] = await dbClient.query(_customerTable);
    data[_notesTable] = await dbClient.query(_notesTable);
    data[_storeInfoTable] = await dbClient.query(_storeInfoTable);

    return data;
  }

  Future<void> clearAllTables(Transaction txn) async {
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
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
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
  }
}
