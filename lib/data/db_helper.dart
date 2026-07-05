import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 3;
  static const String _tableName = 'products';
  static const String _categoryTable = 'categories';

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
}
