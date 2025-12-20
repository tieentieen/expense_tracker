// test/widgets/transaction_card_test.dart - Phiên bản đơn giản hơn
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/transaction_card.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/utils/formatters.dart';

void main() {
  group('TransactionCard Widget Tests', () {
    final mockTransaction = Transaction(
      id: 1,
      userId: 1,
      title: 'Cơm trưa',
      amount: 50000.0,
      date: DateTime(2024, 1, 15, 12, 30),
      categoryId: 1,
      type: 'expense',
      note: 'Ăn tại quán cơm',
    );

    testWidgets('renders basic transaction information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: mockTransaction),
          ),
        ),
      );

      // Chỉ test những thứ chắc chắn hiển thị
      expect(find.text('Cơm trưa'), findsOneWidget);
      expect(find.text(Formatters.formatCurrency(50000)), findsOneWidget);
      expect(find.text(Formatters.formatDate(mockTransaction.date)), findsOneWidget);
      expect(find.text('Ăn tại quán cơm'), findsOneWidget);
    });

    testWidgets('CompactTransactionCard renders basic info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactTransactionCard(transaction: mockTransaction),
          ),
        ),
      );

      // Chỉ test thông tin cơ bản
      expect(find.text('Cơm trưa'), findsOneWidget);
      expect(find.text(Formatters.formatCurrency(50000)), findsOneWidget);
    });
  });
}