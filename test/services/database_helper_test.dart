import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' hide Transaction;

void main() {
  late DatabaseHelper dbHelper;
  late Database inMemoryDb;

  // Khởi tạo in-memory database trước mỗi test
  setUpAll(() {
    // Khởi tạo sqflite ffi cho test trên desktop
    sqflite_ffi.sqfliteFfiInit();
    databaseFactory = sqflite_ffi.databaseFactoryFfi;
  });

  setUp(() async {
    // Tạo database in-memory
    inMemoryDb = await databaseFactory.openDatabase(inMemoryDatabasePath);

  // Inject database in-memory vào DatabaseHelper singleton
  dbHelper = DatabaseHelper();
  await dbHelper.setDatabaseForTest(inMemoryDb);

    // Tạo bảng và insert sample categories
    await dbHelper.database; // trigger _onCreate
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  group('DatabaseHelper - User Operations', () {
    test('registerUser inserts user and returns id', () async {
      final id = await dbHelper.registerUser(
        'test@gmail.com',
        '123456',
        'Nguyễn Test',
      );

      expect(id, greaterThan(0));

      final user = await dbHelper.getUserById(id);
      expect(user!.email, 'test@gmail.com');
      expect(user.name, 'Nguyễn Test');
    });

    test('authenticateUser returns user map when credentials correct', () async {
      await dbHelper.registerUser('auth@test.com', 'password123', 'Auth User');

      final result = await dbHelper.authenticateUser('auth@test.com', 'password123');
      expect(result, isNotNull);
      expect(result!['email'], 'auth@test.com');
    });

    test('authenticateUser returns null when password wrong', () async {
      await dbHelper.registerUser('wrong@test.com', 'correctpass', 'User');

      final result = await dbHelper.authenticateUser('wrong@test.com', 'wrongpass');
      expect(result, isNull);
    });

    test('updateUserProfile and changePassword work correctly', () async {
      final id = await dbHelper.registerUser('update@test.com', 'oldpass', 'Old Name');

      await dbHelper.updateUserProfile(id, 'New Name', 'https://avatar.com/new.jpg');
      await dbHelper.changePassword(id, 'newpass123');

      final user = await dbHelper.getUserById(id);
      expect(user!.name, 'New Name');
      expect(user.avatarUrl, 'https://avatar.com/new.jpg');

      final auth = await dbHelper.authenticateUser('update@test.com', 'newpass123');
      expect(auth, isNotNull);
    });
  });

  group('DatabaseHelper - Category Operations', () {
    test('getCategories returns all 12 sample categories', () async {
      final categories = await dbHelper.getCategories();
      expect(categories.length, 12);
      expect(categories.any((c) => c.name == 'Ăn uống'), true);
      expect(categories.any((c) => c.name == 'Lương'), true);
    });

    test('getCategoriesByType filters correctly', () async {
      final expenses = await dbHelper.getCategoriesByType('expense');
      final incomes = await dbHelper.getCategoriesByType('income');

      expect(expenses.length, 7);
      expect(incomes.length, 5);
      expect(expenses.every((c) => c.type == 'expense'), true);
    });

    test('getCategoryById returns correct category', () async {
      final cat = await dbHelper.getCategoryById(1);
      expect(cat!.name, 'Ăn uống');
      expect(cat.icon, '🍔');
    });
  });

  group('DatabaseHelper - Transaction CRUD', () {
    late int userId;

    setUp(() async {
      userId = await dbHelper.registerUser('trans@test.com', 'pass', 'Trans User');
    });

    test('insertTransaction, getTransactions, updateTransaction, deleteTransaction full flow', () async {
      final transaction = Transaction(
        userId: userId,
        title: 'Cơm trưa',
        amount: 75000,
        date: DateTime(2025, 12, 18),
        categoryId: 1,
        type: 'expense',
        note: 'Cơm tấm sườn',
      );

      final insertedId = await dbHelper.insertTransaction(transaction);
      expect(insertedId, greaterThan(0));
      expect(transaction.id, insertedId);

      final list = await dbHelper.getTransactions(userId);
      expect(list.length, 1);
      expect(list.first.title, 'Cơm trưa');
      expect(list.first.amount, 75000);

      // Update
      final updated = Transaction.fromMap(list.first.toMap()).copyWith(
        title: 'Cơm trưa ngon',
        amount: 80000,
      );
      updated.id = insertedId;

      final rowsAffected = await dbHelper.updateTransaction(updated);
      expect(rowsAffected, 1);

      final updatedTrans = await dbHelper.getTransactionById(insertedId);
      expect(updatedTrans!.title, 'Cơm trưa ngon');
      expect(updatedTrans.amount, 80000);

      // Delete
      final deleted = await dbHelper.deleteTransaction(insertedId);
      expect(deleted, 1);

      final afterDelete = await dbHelper.getTransactions(userId);
      expect(afterDelete, isEmpty);
    });

    test('getTransactions with filters (type, date range)', () async {
      final trans1 = Transaction(
        userId: userId,
        title: 'Lương',
        amount: 20000000,
        date: DateTime(2025, 12, 1),
        categoryId: 8,
        type: 'income',
      );
      final trans2 = Transaction(
        userId: userId,
        title: 'Cafe',
        amount: 50000,
        date: DateTime(2025, 12, 10),
        categoryId: 4,
        type: 'expense',
      );

      await dbHelper.insertTransaction(trans1);
      await dbHelper.insertTransaction(trans2);

      final onlyExpense = await dbHelper.getTransactions(userId, type: 'expense');
      expect(onlyExpense.length, 1);
      expect(onlyExpense.first.title, 'Cafe');

      final dateRange = await dbHelper.getTransactions(
        userId,
        startDate: DateTime(2025, 12, 5),
        endDate: DateTime(2025, 12, 15),
      );
      expect(dateRange.length, 1);
      expect(dateRange.first.title, 'Cafe');
    });
  });

  group('DatabaseHelper - Statistics', () {
    late int userId;

    setUp(() async {
      userId = await dbHelper.registerUser('stats@test.com', 'pass', 'Stats User');

      final income = Transaction(
        userId: userId,
        title: 'Lương',
        amount: 15000000,
        date: DateTime(2025, 12, 1),
        categoryId: 8,
        type: 'income',
      );
      final expense1 = Transaction(
        userId: userId,
        title: 'Ăn uống',
        amount: 500000,
        date: DateTime(2025, 12, 10),
        categoryId: 1,
        type: 'expense',
      );
      final expense2 = Transaction(
        userId: userId,
        title: 'Di chuyển',
        amount: 200000,
        date: DateTime(2025, 12, 15),
        categoryId: 2,
        type: 'expense',
      );

      await dbHelper.insertTransaction(income);
      await dbHelper.insertTransaction(expense1);
      await dbHelper.insertTransaction(expense2);
    });

    test('getTotalIncome, getTotalExpense, getBalance correct', () async {
      final income = await dbHelper.getTotalIncome(userId, null, null);
      final expense = await dbHelper.getTotalExpense(userId, null, null);
      final balance = await dbHelper.getBalance(userId, null, null);

      expect(income, 15000000);
      expect(expense, 700000);
      expect(balance, 14300000);
    });

    test('getCategoryStats groups by category name correctly', () async {
      final stats = await dbHelper.getCategoryStats(userId, 'expense', null, null);

      expect(stats.length, 2);
      expect(stats['Ăn uống'], 500000);
      expect(stats['Di chuyển'], 200000);
    });
  });
}