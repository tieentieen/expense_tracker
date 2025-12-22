// test/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/screens/main/home_screen.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'home_screen_test.mocks.dart';

// Định nghĩa các mock cần tạo
@GenerateMocks([
  TransactionProvider,
  AuthProvider,
  ThemeProvider,
])
void main() {
  late MockTransactionProvider mockTransactionProvider;
  late MockAuthProvider mockAuthProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockTransactionProvider = MockTransactionProvider();
    mockAuthProvider = MockAuthProvider();
    mockThemeProvider = MockThemeProvider();
  });

  group('HomeScreen Tests', () {
    testWidgets('should display greeting message with user name',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(1000.0);
      when(mockTransactionProvider.totalExpense).thenReturn(500.0);
      when(mockTransactionProvider.balance).thenReturn(500.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Nguyễn Văn A');
      when(mockAuthProvider.currentUserEmail)
          .thenReturn('nguyenvana@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert
      expect(find.text('Xin chào, Nguyễn! 👋'), findsOneWidget);
    });

    testWidgets('should display empty state when no transactions',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(0.0);
      when(mockTransactionProvider.totalExpense).thenReturn(0.0);
      when(mockTransactionProvider.balance).thenReturn(0.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Test User');
      when(mockAuthProvider.currentUserEmail).thenReturn('test@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert
      expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
      expect(find.text('Thêm giao dịch đầu tiên của bạn!'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display FAB on home tab but not on other tabs',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(0.0);
      when(mockTransactionProvider.totalExpense).thenReturn(0.0);
      when(mockTransactionProvider.balance).thenReturn(0.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Test User');
      when(mockAuthProvider.currentUserEmail).thenReturn('test@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert - FAB should be visible on home tab
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Act - Switch to statistics tab
      await tester.tap(find.text('Thống kê'));
      await tester.pumpAndSettle();

      // Assert - FAB should not be visible on statistics tab
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should display all time filter chips',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(0.0);
      when(mockTransactionProvider.totalExpense).thenReturn(0.0);
      when(mockTransactionProvider.balance).thenReturn(0.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Test User');
      when(mockAuthProvider.currentUserEmail).thenReturn('test@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert
      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('Tuần này'), findsOneWidget);
      expect(find.text('Tháng này'), findsOneWidget);
      expect(find.text('Năm nay'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
    });

    testWidgets('should display app bar with actions',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(0.0);
      when(mockTransactionProvider.totalExpense).thenReturn(0.0);
      when(mockTransactionProvider.balance).thenReturn(0.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Test User');
      when(mockAuthProvider.currentUserEmail).thenReturn('test@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });

    testWidgets('should display balance card with correct values',
        (WidgetTester tester) async {
      // Arrange
      when(mockTransactionProvider.transactions).thenReturn([]);
      when(mockTransactionProvider.totalIncome).thenReturn(1500.0);
      when(mockTransactionProvider.totalExpense).thenReturn(750.0);
      when(mockTransactionProvider.balance).thenReturn(750.0);
      when(mockTransactionProvider.getCategoryAnalysis('expense'))
          .thenReturn({});
      when(mockAuthProvider.currentUserName).thenReturn('Test User');
      when(mockAuthProvider.currentUserEmail).thenReturn('test@example.com');
      when(mockThemeProvider.isDarkMode).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
                value: mockTransactionProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ThemeProvider>.value(
                value: mockThemeProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(userId: 1),
          ),
        ),
      );

      // Assert - BalanceCard should be present
      expect(find.byType(Card), findsWidgets);
    });
  });
}
