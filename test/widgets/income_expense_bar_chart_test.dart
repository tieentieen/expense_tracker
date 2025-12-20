// test/widgets/income_expense_bar_chart_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/charts/income_expense_bar_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('IncomeExpenseBarChart Widget Tests', () {
    testWidgets('renders empty chart when no data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: const [],
              monthlyExpense: const [],
            ),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    });

    testWidgets('renders chart with income and expense data', (WidgetTester tester) async {
      // Sửa: Tạo mảng 12 phần tử thay vì 1 phần tử
      final income = List.filled(12, 0.0);
      final expense = List.filled(12, 0.0);
      income[0] = 1000000.0; // January income
      expense[0] = 500000.0; // January expense
      income[1] = 2000000.0; // February income
      expense[1] = 800000.0; // February expense

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: income,
              monthlyExpense: expense,
            ),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsNothing);
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);
    });

    testWidgets('shows legend when showLegend is true', (WidgetTester tester) async {
      // Sửa: Tạo mảng 12 phần tử
      final income = List.filled(12, 0.0);
      final expense = List.filled(12, 0.0);
      income[0] = 1000000.0;
      expense[0] = 500000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: income,
              monthlyExpense: expense,
              showLegend: true,
            ),
          ),
        ),
      );

      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);
    });

    testWidgets('hides legend when showLegend is false', (WidgetTester tester) async {
      // Sửa: Tạo mảng 12 phần tử
      final income = List.filled(12, 0.0);
      final expense = List.filled(12, 0.0);
      income[0] = 1000000.0;
      expense[0] = 500000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: income,
              monthlyExpense: expense,
              showLegend: false,
            ),
          ),
        ),
      );

      expect(find.text('Thu nhập'), findsNothing);
      expect(find.text('Chi tiêu'), findsNothing);
    });

    testWidgets('SimpleBarChart renders correctly', (WidgetTester tester) async {
      // Sửa: Tạo mảng 12 phần tử
      final data = List.filled(12, 0.0);
      data[0] = 100000.0;
      data[1] = 200000.0;
      data[2] = 300000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimpleBarChart(data: data, title: 'Thống kê'),
          ),
        ),
      );

      expect(find.text('Thống kê'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('SimpleBarChart shows empty state', (WidgetTester tester) async {
      final data = List.filled(12, 0.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimpleBarChart(data: data),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('handles year parameter correctly', (WidgetTester tester) async {
      // Sửa: Tạo mảng 12 phần tử
      final income = List.filled(12, 0.0);
      final expense = List.filled(12, 0.0);
      income[0] = 1000000.0;
      expense[0] = 500000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: income,
              monthlyExpense: expense,
              year: 2024,
            ),
          ),
        ),
      );

      // Should render without error with custom year
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('month abbreviations are shown', (WidgetTester tester) async {
      final income = List.filled(12, 100000.0);
      final expense = List.filled(12, 50000.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeExpenseBarChart(
              monthlyIncome: income,
              monthlyExpense: expense,
            ),
          ),
        ),
      );

      // Check that month labels are present
      // Widget hiển thị số tháng từ 1-12
      expect(find.text('1'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });
}