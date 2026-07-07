import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'models/transaction_item_model.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 5;
  static const String _tableName = 'products';
  static const String _categoryTable = 'categories';
  static const String _transactionTable = 'transactions';
  static const String _transactionItemsTable = 'transaction_items';

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
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
      },
    );
  }

  // --- Products ---

  static Future<int> insertProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.insert(
      _tableName,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.update(
      _tableName,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<int> deleteProduct(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_tableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  static Future<String> getNextItemCode() async {
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

  static Future<int> insertCategory(CategoryModel category) async {
    final dbClient = await db;
    return await dbClient.insert(
      _categoryTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCategory(CategoryModel category) async {
    final dbClient = await db;
    return await dbClient.update(
      _categoryTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      _categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<CategoryModel>> getCategories() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(_categoryTable);
    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  static Future<String> getNextCategoryCode() async {
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

  static Future<int> saveTransaction(TransactionModel transaction, List<TransactionItemModel> items) async {
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

  // --- Daily Report ---

  static Future<List<TransactionModel>> getTransactionsByDate(String date) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      _transactionTable,
      where: 'transactionDate LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  static Future<List<Map<String, dynamic>>> getDailyCategorySummary(String date) async {
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

  static Future<Map<String, dynamic>> getDailySummary(String date) async {
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

  static Future<List<Map<String, dynamic>>> getTransactionDetailsByDate(String date) async {
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
}
