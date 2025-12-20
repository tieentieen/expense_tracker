import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart' as my_transaction;
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateNiceMocks([MockSpec<DatabaseHelper>()])
import 'transaction_provider_test.mocks.dart';

void main() {
  late TransactionProvider provider;
  late MockDatabaseHelper mockDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    mockDb = MockDatabaseHelper();
    provider = TransactionProvider(dbHelper: mockDb);
  });

  group('TransactionProvider - Initial Data', () {
    test('loadInitialData loads categories correctly', () async {
      when(mockDb.getCategories()).thenAnswer((_) async => [
        Category(id: 1, name: 'Ăn uống', type: 'expense', icon: '🍔', color: 0xFFFFB6B6),
        Category(id: 8, name: 'Lương', type: 'income', icon: '💰', color: 0xFF4CAF50),
      ]);

      await provider.loadInitialData();

      expect(provider.categories.length, 2);
      expect(provider.expenseCategories.length, 1);
      expect(provider.incomeCategories.length, 1);
      expect(provider.categories.any((c) => c.name == 'Ăn uống'), true);
      expect(provider.categories.any((c) => c.name == 'Lương'), true);
    });
  });

  group('TransactionProvider - Transactions CRUD', () {
    test('loadTransactions sets data and calculates totals correctly', () async {
      final transactions = [
        my_transaction.Transaction(
          userId: 1,
          title: 'Lương tháng',
          amount: 20000000,
          date: DateTime(2025, 12, 19),
          categoryId: 8,
          type: 'income',
        ),
        my_transaction.Transaction(
          userId: 1,
          title: 'Ăn uống',
          amount: 500000,
          date: DateTime(2025, 12, 19),
          categoryId: 1,
          type: 'expense',
        ),
      ];

      when(mockDb.getTransactions(1)).thenAnswer((_) async => transactions);

      await provider.loadTransactions(1);

      expect(provider.transactions.length, 2);
      expect(provider.totalIncome, 20000000);
      expect(provider.totalExpense, 500000);
      expect(provider.balance, 19500000);
    });

    test('addTransaction calls DB insert and reloads data', () async {
      final newTransaction = my_transaction.Transaction(
        userId: 1,
        title: 'Cafe sáng',
        amount: 45000,
        date: DateTime(2025, 12, 19),
        categoryId: 1,
        type: 'expense',
      );

      when(mockDb.insertTransaction(any)).thenAnswer((_) async => 15);
      when(mockDb.getTransactions(1)).thenAnswer((_) async => [newTransaction..id = 15]);

      await provider.addTransaction(newTransaction);

      verify(mockDb.insertTransaction(newTransaction)).called(1);
      verify(mockDb.getTransactions(1)).called(1);
    });

    test('updateTransaction calls DB update and reloads data', () async {
      final updatedTransaction = my_transaction.Transaction(
        id: 10,
        userId: 1,
        title: 'Cập nhật chi tiêu',
        amount: 100000,
        date: DateTime(2025, 12, 19),
        categoryId: 1,
        type: 'expense',
      );

      when(mockDb.updateTransaction(any)).thenAnswer((_) async => 1);
      when(mockDb.getTransactions(1)).thenAnswer((_) async => [updatedTransaction]);

      await provider.updateTransaction(updatedTransaction);

      verify(mockDb.updateTransaction(updatedTransaction)).called(1);
      verify(mockDb.getTransactions(1)).called(1);
    });

    test('deleteTransaction calls DB delete and reloads data', () async {
      when(mockDb.deleteTransaction(20)).thenAnswer((_) async => 1);
      when(mockDb.getTransactions(1)).thenAnswer((_) async => []);

      await provider.deleteTransaction(20, 1);

      verify(mockDb.deleteTransaction(20)).called(1);
      verify(mockDb.getTransactions(1)).called(1);
    });
  });

  group('TransactionProvider - Filters & Search', () {
    test('search and type filters work correctly', () async {
      final transactions = [
        my_transaction.Transaction(
          id: 1,
          userId: 1,
          title: 'Ăn sáng',
          amount: 30000,
          date: DateTime.now(),
          categoryId: 1,
          type: 'expense',
        ),
        my_transaction.Transaction(
          id: 2,
          userId: 1,
          title: 'Lương thưởng',
          amount: 5000000,
          date: DateTime.now(),
          categoryId: 8,
          type: 'income',
        ),
      ];

      provider.setTransactionsForTest(transactions);

      // Test ban đầu
      expect(provider.transactions.length, 2);

      // Test search filter
      provider.setSearchKeyword('sáng');
      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.title, 'Ăn sáng');

      // Reset và test type filter
      provider.setSearchKeyword('');
      provider.setSelectedType('income');
      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.type, 'income');
      expect(provider.transactions.first.title, 'Lương thưởng');
    });
  });

  group('TransactionProvider - Category Analysis', () {
    test('getCategoryAnalysis returns correct totals by category name', () async {
      when(mockDb.getCategories()).thenAnswer((_) async => [
        Category(id: 1, name: 'Ăn uống', type: 'expense', icon: '🍔', color: 0xFFFFB6B6),
        Category(id: 2, name: 'Di chuyển', type: 'expense', icon: '🚗', color: 0xFFA7C5EB),
      ]);
      await provider.loadInitialData();

      final transactions = [
        my_transaction.Transaction(
          userId: 1,
          title: 'Cơm trưa',
          amount: 80000,
          date: DateTime(2025, 12, 19),
          categoryId: 1,
          type: 'expense',
        ),
        my_transaction.Transaction(
          userId: 1,
          title: 'Xăng xe',
          amount: 300000,
          date: DateTime(2025, 12, 19),
          categoryId: 2,
          type: 'expense',
        ),
        my_transaction.Transaction(
          userId: 1,
          title: 'Cafe',
          amount: 50000,
          date: DateTime(2025, 12, 19),
          categoryId: 1,
          type: 'expense',
        ),
      ];

      provider.setTransactionsForTest(transactions);

      final analysis = provider.getCategoryAnalysis('expense');

      expect(analysis.length, 2);
      expect(analysis['Ăn uống'], 130000);
      expect(analysis['Di chuyển'], 300000);
    });
  });
}