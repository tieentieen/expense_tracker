// test/widgets/expense_pie_chart_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/charts/expense_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('ExpensePieChart Widget Tests', () {
    testWidgets('renders empty chart when data is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpensePieChart(data: {}),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('renders pie chart with data', (WidgetTester tester) async {
      final data = {
        'Ăn uống': 500000.0,
        'Di chuyển': 300000.0,
        'Mua sắm': 200000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpensePieChart(data: data),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsNothing);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Tổng'), findsOneWidget);
    });

    testWidgets('shows legend when showLegend is true', (WidgetTester tester) async {
      final data = {
        'Ăn uống': 500000.0,
        'Di chuyển': 300000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpensePieChart(data: data, showLegend: true),
          ),
        ),
      );

      // Legend should be visible
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('Di chuyển'), findsOneWidget);
    });

    testWidgets('hides legend when showLegend is false', (WidgetTester tester) async {
      final data = {
        'Ăn uống': 500000.0,
        'Di chuyển': 300000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpensePieChart(data: data, showLegend: false),
          ),
        ),
      );

      // Legend should not be visible
      expect(find.text('Ăn uống'), findsNothing);
      expect(find.text('Di chuyển'), findsNothing);
    });

    testWidgets('uses correct radius parameter', (WidgetTester tester) async {
      final data = {
        'Test': 100000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpensePieChart(data: data, radius: 50),
          ),
        ),
      );

      final pieChart = tester.widget<PieChart>(find.byType(PieChart));
      final pieChartData = pieChart.data;
      
      // Check that center space radius is half of the provided radius
      expect(pieChartData.centerSpaceRadius, 25);
    });
  });

  group('IncomePieChart Widget Tests', () {
    testWidgets('renders empty chart when data is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IncomePieChart(data: {}),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('renders income pie chart with data', (WidgetTester tester) async {
      final data = {
        'Lương': 10000000.0,
        'Freelance': 5000000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomePieChart(data: data),
          ),
        ),
      );

      expect(find.text('Không có dữ liệu'), findsNothing);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Tổng'), findsOneWidget);
    });

    testWidgets('income chart shows legend', (WidgetTester tester) async {
      final data = {
        'Lương': 10000000.0,
        'Freelance': 5000000.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomePieChart(data: data, showLegend: true),
          ),
        ),
      );

      expect(find.text('Lương'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);
    });
  });
}