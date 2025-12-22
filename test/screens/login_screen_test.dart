import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<AuthProvider>()])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isLoading).thenReturn(false);
  });

  Widget buildTestableWidget({Size screenSize = const Size(800, 1000)}) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: MaterialApp(
          home: LoginScreen(),
          routes: {
            '/register': (context) => Scaffold(
                  appBar: AppBar(title: Text('Register Screen')),
                  body: Center(child: Text('Register Screen')),
                ),
            '/home': (context) => Scaffold(
                  appBar: AppBar(title: Text('Home Screen')),
                  body: Center(child: Text('Home Screen')),
                ),
          },
        ),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders login screen correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Đăng Nhập'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Mật khẩu'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
      expect(find.text('Chưa có tài khoản?'), findsOneWidget);
      expect(find.text('Đăng ký ngay'), findsOneWidget);
    });

    testWidgets('shows validation errors when submit with empty data',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('ĐĂNG NHẬP'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      await tester.tap(find.text('ĐĂNG NHẬP'));
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('validates short password', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      await tester.tap(find.text('ĐĂNG NHẬP'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('calls login when form is valid', (tester) async {
      when(mockAuthProvider.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer(
          (_) async => {'success': true, 'message': 'Đăng nhập thành công'});

      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123456');
      await tester.tap(find.text('ĐĂNG NHẬP'));

      // Đợi đủ thời gian để timer hoàn thành
      await tester.pumpAndSettle(const Duration(seconds: 2));

      verify(mockAuthProvider.login(
        email: 'test@example.com',
        password: '123456',
      )).called(1);

      // Kiểm tra Snackbar xuất hiện
      expect(find.text('Đăng nhập thành công'), findsOneWidget);
    });

    testWidgets('shows forgot password dialog when tapping link',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();

      expect(find.text('Quên mật khẩu'), findsOneWidget);

      // Tìm TextFormField trong dialog (có label 'Email')
      final dialogTextFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      expect(dialogTextFields, findsOneWidget);

      expect(find.text('GỬI'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Tìm icon visibility trong password field và tap
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');
      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_outlined),
      );

      await tester.tap(visibilityIcon);
      await tester.pump();

      // Kiểm tra icon đã đổi
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('toggles remember me checkbox', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Tìm checkbox và tap
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      // Kiểm tra checkbox được chọn
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, true);
    });

    testWidgets('disables login button when isLoading is true', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildTestableWidget());

      // Kiểm tra có CircularProgressIndicator (loading) thay vì text button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tìm ElevatedButton và kiểm tra onPressed là null (disabled)
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsOneWidget);

      final button = tester.widget<ElevatedButton>(elevatedButtons.first);
      expect(button.onPressed, isNull); // Button bị disabled
    });

    testWidgets('shows error snackbar when login fails', (tester) async {
      when(mockAuthProvider.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async =>
          {'success': false, 'message': 'Email hoặc mật khẩu không đúng'});

      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(find.text('ĐĂNG NHẬP'));
      await tester.pumpAndSettle();

      // Kiểm tra Snackbar lỗi xuất hiện
      expect(find.text('Email hoặc mật khẩu không đúng'), findsOneWidget);
    });

    testWidgets('enables login button when isLoading is false', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(buildTestableWidget());

      // Kiểm tra không có CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Kiểm tra có text 'ĐĂNG NHẬP'
      expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

      // Tìm ElevatedButton và kiểm tra onPressed không null (enabled)
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsOneWidget);

      final button = tester.widget<ElevatedButton>(elevatedButtons.first);
      expect(button.onPressed, isNotNull); // Button enabled
    });
  });
}
