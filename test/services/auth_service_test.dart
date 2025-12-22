import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction.dart';
// Removed unused import

void main() {
  group('Transaction Model Tests', () {
    test('Transaction should create correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime(2024, 1, 15),
        categoryId: 1,
        type: 'expense',
        note: 'Test note',
      );

      expect(transaction.id, 1);
      expect(transaction.userId, 1);
      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 100000);
      expect(transaction.date, DateTime(2024, 1, 15));
      expect(transaction.categoryId, 1);
      expect(transaction.type, 'expense');
      expect(transaction.note, 'Test note');
    });

    test('Transaction toMap should convert correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime(2024, 1, 15, 14, 30),
        categoryId: 1,
        type: 'expense',
        note: 'Test note',
      );

      final map = transaction.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 1);
      expect(map['title'], 'Test Transaction');
      expect(map['amount'], 100000);
      expect(map['date'], '2024-01-15T14:30:00.000');
      expect(map['category_id'], 1);
      expect(map['type'], 'expense');
      expect(map['note'], 'Test note');
    });

    test('Transaction fromMap should create correctly', () {
      final map = {
        'id': 1,
        'user_id': 1,
        'title': 'Test Transaction',
        'amount': 100000.0,
        'date': '2024-01-15T14:30:00.000',
        'category_id': 1,
        'type': 'expense',
        'note': 'Test note',
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, 1);
      expect(transaction.userId, 1);
      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 100000);
      expect(transaction.date, DateTime(2024, 1, 15, 14, 30));
      expect(transaction.categoryId, 1);
      expect(transaction.type, 'expense');
      expect(transaction.note, 'Test note');
    });

    test('Transaction formattedDate should format correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime(2024, 1, 15),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.formattedDate, '15/01/2024');
    });

    test('Transaction formattedAmount should format correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.formattedAmount, '₫100,000');
    });

    test('Transaction formattedTime should format correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime(2024, 1, 15, 14, 30),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.formattedTime, '14:30');
    });

    test('Transaction formattedDateTime should format correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime(2024, 1, 15, 14, 30),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.formattedDateTime, '15/01/2024 14:30');
    });

    test('Transaction should handle null note', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.note, isNull);
    });

    test('Transaction should handle income type', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Salary',
        amount: 10000000,
        date: DateTime.now(),
        categoryId: 8,
        type: 'income',
      );

      expect(transaction.type, 'income');
      expect(transaction.categoryId, 8);
    });

    test('Transaction should handle zero amount', () {
      expect(() {
        Transaction(
          id: 1,
          userId: 1,
          title: 'Test',
          amount: 0,
          date: DateTime.now(),
          categoryId: 1,
          type: 'expense',
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('Transaction should handle negative amount', () {
      expect(() {
        Transaction(
          id: 1,
          userId: 1,
          title: 'Test',
          amount: -100,
          date: DateTime.now(),
          categoryId: 1,
          type: 'expense',
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('Transaction should handle very large amount', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Large Transaction',
        amount: 1000000000,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.amount, 1000000000);
    });

    test('Transaction should handle different date times', () {
      final dates = [
        DateTime(2023, 12, 31, 23, 59),
        DateTime(2024, 2, 29), // Leap year
        DateTime(2024, 6, 15, 9, 15),
        DateTime(2024, 12, 25, 0, 0),
      ];

      for (final date in dates) {
        final transaction = Transaction(
          id: 1,
          userId: 1,
          title: 'Test',
          amount: 1000,
          date: date,
          categoryId: 1,
          type: 'expense',
        );

        expect(transaction.date, date);
      }
    });

    test('Transaction should handle different categories', () {
      final categories = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

      for (final categoryId in categories) {
        final transaction = Transaction(
          id: 1,
          userId: 1,
          title: 'Test',
          amount: 1000,
          date: DateTime.now(),
          categoryId: categoryId,
          type: categoryId <= 7 ? 'expense' : 'income',
        );

        expect(transaction.categoryId, categoryId);
        expect(
          transaction.type,
          categoryId <= 7 ? 'expense' : 'income',
        );
      }
    });

    test('Transaction should have correct string representations', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test Transaction',
        amount: 123456,
        date: DateTime(2024, 1, 15, 14, 30),
        categoryId: 1,
        type: 'expense',
        note: 'Test note',
      );

      // Test toString (optional)
      expect(transaction.toString(), contains('Transaction'));
      expect(transaction.toString(), contains('Test Transaction'));
      expect(transaction.toString(), contains('123456'));
    });
  });

  group('Transaction Edge Cases', () {
    test('Should handle long title', () {
      final longTitle = 'A' * 100;
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: longTitle,
        amount: 1000,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.title.length, 100);
    });

    test('Should handle long note', () {
      final longNote = 'B' * 500;
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test',
        amount: 1000,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
        note: longNote,
      );

      expect(transaction.note?.length, 500);
    });

    test('Should handle decimal amounts', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test',
        amount: 123.45,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.amount, 123.45);
    });

    test('Should handle very large decimal amounts', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test',
        amount: 999999999.99,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.amount, 999999999.99);
    });

    test('Should handle minimum valid amount', () {
      final transaction = Transaction(
        id: 1,
        userId: 1,
        title: 'Test',
        amount: 0.01,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );

      expect(transaction.amount, 0.01);
    });
  });
}
