import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/screens/main/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<AuthProvider>(), MockSpec<ThemeProvider>()])
import 'profile_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockThemeProvider = MockThemeProvider();
    when(mockThemeProvider.isDarkMode).thenReturn(false);
    when(mockThemeProvider.toggleTheme()).thenReturn(null);
  });

  Widget buildTestableWidget({Size screenSize = const Size(800, 1200)}) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ProfileScreen(
              userId: 1,
              userName: 'Test User',
              userEmail: 'test@example.com',
            ),
          ),
          // Thêm routes để xử lý navigation
          routes: {
            '/login': (context) => Scaffold(
                  appBar: AppBar(title: Text('Login Screen')),
                  body: Center(child: Text('Login Screen')),
                ),
          },
        ),
      ),
    );
  }

  group('ProfileScreen', () {
    testWidgets('renders profile screen correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Tài Khoản Cá Nhân'), findsOneWidget);

      // Chỉ kiểm tra các text xuất hiện (không quan tâm số lượng)
      expect(find.text('Test User'), findsAtLeast(1));
      expect(find.text('test@example.com'), findsAtLeast(1));
      expect(find.text('User ID: 1'), findsOneWidget);

      // Tìm các section titles
      expect(find.text('THÔNG TIN CÁ NHÂN'), findsOneWidget);
      expect(find.text('BẢO MẬT'), findsOneWidget);
      expect(find.text('GIAO DIỆN'), findsOneWidget);
      expect(find.text('HỖ TRỢ'), findsOneWidget);
    });

    testWidgets('opens edit profile dialog when edit button pressed',
        (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Tìm và tap edit button (icon)
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra dialog xuất hiện
      expect(find.text('Chỉnh sửa thông tin'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('updates profile when submit valid data in dialog',
        (tester) async {
      when(mockAuthProvider.updateProfile(
              name: anyNamed('name'), avatarUrl: anyNamed('avatarUrl')))
          .thenAnswer(
              (_) async => {'success': true, 'message': 'Cập nhật thành công'});

      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Mở dialog chỉnh sửa
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Xóa text cũ và nhập tên mới
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '');
      await tester.enterText(textField, 'New Name');
      await tester.tap(find.text('LƯU'));
      await tester.pumpAndSettle();

      verify(mockAuthProvider.updateProfile(name: 'New Name', avatarUrl: null))
          .called(1);
    });

    testWidgets('opens change password dialog', (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Cuộn đến phần bảo mật
      await tester.scrollUntilVisible(find.text('BẢO MẬT'), 200);
      await tester.pump();

      // Tìm button "Đổi mật khẩu" và tap
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Đổi mật khẩu'), findsAtLeast(1)); // Dialog title
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // 3 fields trong dialog
    });

    testWidgets('changes password when valid in dialog', (tester) async {
      when(mockAuthProvider.changePassword(
        currentPassword: anyNamed('currentPassword'),
        newPassword: anyNamed('newPassword'),
      )).thenAnswer(
          (_) async => {'success': true, 'message': 'Đổi mật khẩu thành công'});

      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Mở dialog đổi mật khẩu
      await tester.scrollUntilVisible(find.text('BẢO MẬT'), 200);
      await tester.pump();
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      // Nhập các trường mật khẩu
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'oldpass');
      await tester.enterText(textFields.at(1), 'newpass');
      await tester.enterText(textFields.at(2), 'newpass');

      await tester.tap(find.text('ĐỔI MẬT KHẨU'));
      await tester.pumpAndSettle();

      verify(mockAuthProvider.changePassword(
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      )).called(1);
    });

    testWidgets('shows logout dialog', (tester) async {
      when(mockAuthProvider.logout()).thenAnswer((_) async => {});

      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Cuộn xuống và tìm logout button
      await tester.scrollUntilVisible(find.text('ĐĂNG XUẤT'), 500);
      await tester.pump();

      // Tìm và tap logout button
      final logoutButton = find.text('ĐĂNG XUẤT');
      await tester.ensureVisible(logoutButton);
      await tester.pump();
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Dialog logout xuất hiện với tiêu đề "Đăng xuất"
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn đăng xuất?'), findsOneWidget);

      // Tap confirm logout trong dialog
      await tester.tap(find.text('ĐĂNG XUẤT').last);
      await tester.pumpAndSettle();

      verify(mockAuthProvider.logout()).called(1);
    });

    testWidgets('toggles theme mode', (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Cuộn đến phần giao diện
      await tester.scrollUntilVisible(find.text('GIAO DIỆN'), 300);
      await tester.pump();

      // Tìm switch và tap
      final switchFinder = find.byType(Switch);
      await tester.ensureVisible(switchFinder);
      await tester.pump();
      await tester.tap(switchFinder);
      await tester.pump();

      verify(mockThemeProvider.toggleTheme()).called(1);
    });

    testWidgets('shows validation error when empty name in profile update',
        (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Mở dialog chỉnh sửa
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Xóa text hiện tại
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '');

      // Tap LƯU
      await tester.tap(find.text('LƯU'));
      await tester.pumpAndSettle();

      // Kiểm tra SnackBar xuất hiện
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    });

    testWidgets('shows validation error when passwords dont match',
        (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Mở dialog đổi mật khẩu
      await tester.scrollUntilVisible(find.text('BẢO MẬT'), 200);
      await tester.pump();
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      // Nhập mật khẩu không khớp
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'oldpass');
      await tester.enterText(textFields.at(1), 'newpass1');
      await tester.enterText(textFields.at(2), 'newpass2');

      await tester.tap(find.text('ĐỔI MẬT KHẨU'));
      await tester.pumpAndSettle();

      // Kiểm tra SnackBar xuất hiện
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Mật khẩu mới không khớp'), findsOneWidget);
    });

    testWidgets('shows settings dialog when settings button pressed',
        (tester) async {
      await tester
          .pumpWidget(buildTestableWidget(screenSize: const Size(800, 1000)));

      // Tìm và tap settings button trong AppBar
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra settings dialog xuất hiện
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Xóa cache'), findsOneWidget);
      expect(find.text('Xóa dữ liệu ứng dụng'), findsOneWidget);
    });
  });
}
