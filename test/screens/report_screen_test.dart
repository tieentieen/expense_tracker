import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/main/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<TransactionProvider>()])
import 'report_screen_test.mocks.dart';

void main() {
  late MockTransactionProvider mockProvider;

  setUp(() {
    mockProvider = MockTransactionProvider();

    // Mock các giá trị cơ bản
    when(mockProvider.transactions).thenReturn([
      // Thêm transaction mẫu để test
    ]);

    when(mockProvider.totalIncome).thenReturn(10000000.0);
    when(mockProvider.totalExpense).thenReturn(5000000.0);
    when(mockProvider.balance).thenReturn(5000000.0);

    // Mock các methods cần thiết
    when(mockProvider.getCategoryById(any)).thenReturn(
      Category(
          id: 1, name: 'Test', type: 'expense', icon: '🍔', color: 0xFF000000),
    );

    when(mockProvider.getMonthlyData(any, any))
        .thenReturn(List.filled(12, 0.0));

    // Mock loadTransactions
    when(mockProvider.loadTransactions(any)).thenAnswer((_) async {});
  });

  Widget buildTestableWidget() {
    return ChangeNotifierProvider<TransactionProvider>.value(
      value: mockProvider,
      child: const MaterialApp(
        home: ReportScreen(userId: 1),
      ),
    );
  }

  group('ReportScreen', () {
    testWidgets('renders report screen correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle(); // Đợi load data

      // Kiểm tra tiêu đề
      expect(find.text('Thống Kê Chi Tiêu'), findsOneWidget);

      // Kiểm tra các nút period selector
      expect(find.text('Tuần'), findsOneWidget);
      expect(find.text('Tháng'), findsOneWidget);
      expect(find.text('Năm'), findsOneWidget);

      // Kiểm tra summary cards
      expect(find.text('TỔNG THU'), findsOneWidget);
      expect(find.text('TỔNG CHI'), findsOneWidget);
      expect(find.text('SỐ DƯ'), findsOneWidget);

      // Kiểm tra nút export
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('changes period when tapping period chip', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap vào chip "Năm"
      await tester.tap(find.text('Năm'));
      await tester.pumpAndSettle();

      // Kiểm tra chip được chọn
      expect(find.text('Năm'), findsOneWidget);
    });

    testWidgets('shows export dialog when tapping export button',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap nút export
      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra dialog xuất hiện
      expect(find.text('Xuất báo cáo'), findsOneWidget);
      expect(find.text('Hình ảnh'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('HỦY'), findsOneWidget);
    });

    testWidgets('shows no data message when no transactions', (tester) async {
      // Mock không có transaction
      when(mockProvider.transactions).thenReturn([]);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Kiểm tra có thông báo không có dữ liệu
      expect(find.text('Không có dữ liệu để hiển thị'), findsOneWidget);
    });
  });
}
