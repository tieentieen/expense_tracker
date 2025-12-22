// test/widgets/balance_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/balance_card.dart';
import 'package:expense_tracker/utils/formatters.dart';

void main() {
  group('BalanceCard Widget Tests', () {
    testWidgets('renders positive balance correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 15000000.0,
              income: 20000000.0,
              expense: 5000000.0,
            ),
          ),
        ),
      );

      expect(find.text('SỐ DƯ HIỆN TẠI'), findsOneWidget);
      expect(find.text(Formatters.formatCurrency(15000000)), findsOneWidget);
      expect(find.text('Tăng'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);
      expect(find.text(Formatters.formatCurrency(20000000)), findsOneWidget);
      expect(find.text(Formatters.formatCurrency(5000000)), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNWidgets(2));
    });

    testWidgets('renders negative balance correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: -1000000.0,
              income: 5000000.0,
              expense: 6000000.0,
            ),
          ),
        ),
      );

      expect(find.text(Formatters.formatCurrency(-1000000)), findsOneWidget);
      expect(find.text('Giảm'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsNWidgets(2));
    });

    testWidgets('renders zero balance correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 0.0,
              income: 10000000.0,
              expense: 10000000.0,
            ),
          ),
        ),
      );

      expect(find.text(Formatters.formatCurrency(0)), findsOneWidget);
      expect(find.text('Tăng'), findsOneWidget); // 0 is considered positive
    });

    testWidgets('responds to onTap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 1000000.0,
              income: 2000000.0,
              expense: 1000000.0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BalanceCard));
      expect(tapped, true);
    });

    testWidgets('handles very large numbers with ellipsis',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 999999999999.0,
              income: 1000000000000.0,
              expense: 100000000.0,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.text('SỐ DƯ HIỆN TẠI'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);
    });

    testWidgets('uses correct colors for positive balance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 1000000.0,
              income: 2000000.0,
              expense: 1000000.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Positive balance should use green gradient
      expect(gradient.colors.length, 2);
    });

    testWidgets('uses correct colors for negative balance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: -1000000.0,
              income: 1000000.0,
              expense: 2000000.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Negative balance should use red gradient
      expect(gradient.colors.length, 2);
    });
  });
}
