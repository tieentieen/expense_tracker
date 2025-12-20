import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/user.dart';
import 'package:expense_tracker/models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Test helper: allow injecting a Database instance (in-memory) for tests.
  // Use only in tests to avoid touching production singleton lifecycle.
  // When injecting an in-memory database, ensure schema is created so tests
  // don't depend on calling _initDatabase. This method is async so callers
  // should await it in tests.
  Future<void> setDatabaseForTest(Database db) async {
    _database = db;

    // Check whether expected tables exist; if not, call _onCreate to create
    // schema and seed sample data. We check for the 'users' table as a
    // representative indicator.
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('users','categories','transactions')",
    );

    if (tables.isEmpty) {
      await _onCreate(db, 1);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng users
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        avatar_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tạo bảng categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        description TEXT
      )
    ''');

    // Tạo bảng transactions
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Chèn dữ liệu mẫu cho categories
    await _insertSampleCategories(db);
  }

  Future<void> _insertSampleCategories(Database db) async {
    final categories = [
      ...CategoryRepository.getExpenseCategories(),
      ...CategoryRepository.getIncomeCategories(),
    ];

    for (var category in categories) {
      // Use conflictAlgorithm to avoid UNIQUE constraint errors when
      // seeding sample data multiple times (tests may create in-memory DBs
      // or the seeding may be invoked again). IGNORE will skip inserts
      // that would violate the unique primary key constraint.
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // ========== User Operations ==========
  Future<int> registerUser(String email, String password, String name) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUserProfile(int userId, String name, String? avatarUrl) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'name': name,
        'avatar_url': avatarUrl,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> changePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ========== Category Operations ==========
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }
    return null;
  }

  // ========== Transaction Operations ==========
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    transaction.id = await db.insert(
      'transactions',
      transaction.toMap(),
    );
    return transaction.id!;
  }

  Future<List<Transaction>> getTransactions(int userId, 
      {String? type, DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    
    String where = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (type != null) {
      where += ' AND type = ?';
      whereArgs.add(type);
    }
    
    if (startDate != null && endDate != null) {
      where += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC, created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return Transaction.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Thống kê
  Future<double> getTotalIncome(int userId, DateTime? startDate, DateTime? endDate) async {
    final db = await database;
    
    String where = 'user_id = ? AND type = ?';
    List<dynamic> whereArgs = [userId, 'income'];
    
    if (startDate != null && endDate != null) {
      where += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }
    
    final result = await db.query(
      'transactions',
      columns: ['SUM(amount) as total'],
      where: where,
      whereArgs: whereArgs,
    );
    
    return result.first['total'] as double? ?? 0;
  }

  Future<double> getTotalExpense(int userId, DateTime? startDate, DateTime? endDate) async {
    final db = await database;
    
    String where = 'user_id = ? AND type = ?';
    List<dynamic> whereArgs = [userId, 'expense'];
    
    if (startDate != null && endDate != null) {
      where += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }
    
    final result = await db.query(
      'transactions',
      columns: ['SUM(amount) as total'],
      where: where,
      whereArgs: whereArgs,
    );
    
    return result.first['total'] as double? ?? 0;
  }

  Future<double> getBalance(int userId, DateTime? startDate, DateTime? endDate) async {
    final income = await getTotalIncome(userId, startDate, endDate);
    final expense = await getTotalExpense(userId, startDate, endDate);
    return income - expense;
  }

  // Thống kê theo category
  Future<Map<String, double>> getCategoryStats(int userId, String type, DateTime? startDate, DateTime? endDate) async {
    final db = await database;
    
    String where = 't.user_id = ? AND t.type = ?';
    List<dynamic> whereArgs = [userId, type];
    
    if (startDate != null && endDate != null) {
      where += ' AND t.date BETWEEN ? AND ?';
      whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }
    
    final result = await db.rawQuery('''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE $where
      GROUP BY c.id
      ORDER BY total DESC
    ''', whereArgs);
    
    final Map<String, double> stats = {};
    for (var row in result) {
      stats[row['name'] as String] = row['total'] as double;
    }
    
    return stats;
  }
}