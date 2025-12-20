import 'package:expense_tracker/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transaction model', () {
    test('constructor enforces amount > 0', () {
      expect(
        () => Transaction(
          userId: 1,
          title: 'Test',
          amount: 0,
          date: DateTime.now(),
          categoryId: 1,
          type: 'expense',
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Transaction(
          userId: 1,
          title: 'Test',
          amount: -100,
          date: DateTime.now(),
          categoryId: 1,
          type: 'expense',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toMap() converts correctly', () {
      final t = Transaction(
        id: 10,
        userId: 1,
        title: 'Ăn trưa',
        amount: 150000,
        date: DateTime(2025, 12, 18, 12, 30),
        categoryId: 1,
        type: 'expense',
        note: 'Cơm tấm',
      );

      final map = t.toMap();
      expect(map['id'], 10);
      expect(map['user_id'], 1);
      expect(map['title'], 'Ăn trưa');
      expect(map['amount'], 150000); 
      expect(map['type'], 'expense');
    });

    test('fromMap() creates correct Transaction', () {
      final map = {
        'id': 5,
        'user_id': 1,
        'title': 'Lương tháng 12',
        'amount': 15000000,
        'date': '2025-12-01T08:00:00',
        'category_id': 8,
        'type': 'income',
      };

      final t = Transaction.fromMap(map);
      expect(t.id, 5);
      expect(t.amount, 15000000.0);
      expect(t.formattedAmount, '₫15,000,000');
      expect(t.formattedDate, '01/12/2025');
    });

    test('formattedAmount uses ₫ prefix and commas', () {
      final t1 = Transaction(
        userId: 1,
        title: 'Test',
        amount: 1234567,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );
      expect(t1.formattedAmount, '₫1,234,567');

      final t2 = Transaction(
        userId: 1,
        title: 'Test',
        amount: 500.5,
        date: DateTime.now(),
        categoryId: 1,
        type: 'expense',
      );
      expect(t2.formattedAmount, '₫501'); // làm tròn theo logic hiện tại
    });
  });
}