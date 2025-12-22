import 'package:expense_tracker/models/user.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:expense_tracker/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DatabaseHelper>()])
import 'auth_provider_test.mocks.dart';

void main() {
  late AuthProvider provider;
  late MockDatabaseHelper mockDb;

  setUp(() {
    mockDb = MockDatabaseHelper();
    provider = AuthProvider(dbHelper: mockDb);
  });

  group('AuthProvider - Initial State', () {
    test('should start as not logged in', () {
      expect(provider.isLoggedIn, false);
      expect(provider.currentUserId, null);
      expect(provider.isLoading, false);
    });
  });

  group('AuthProvider - Register', () {
    test('register success sets user data', () async {
      when(mockDb.authenticateUser(any, any)).thenAnswer((_) async => null);
      when(mockDb.registerUser(any, any, any)).thenAnswer((_) async => 1);

      final result = await provider.register(
        email: 'new@test.com',
        password: 'pass123',
        name: 'New User',
      );

      expect(result['success'], true);
      expect(result['message'], AppConstants.successRegister);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUserId, 1);
      expect(provider.currentUserName, 'New User');
      expect(provider.currentUserEmail, 'new@test.com');
    });

    test('register fails if email in use', () async {
      when(mockDb.authenticateUser(any, any))
          .thenAnswer((_) async => {'id': 2});

      final result = await provider.register(
        email: 'existing@test.com',
        password: 'pass',
        name: 'User',
      );

      expect(result['success'], false);
      expect(result['message'], AppConstants.errorEmailInUse);
      expect(provider.isLoggedIn, false);
    });
  });

  group('AuthProvider - Login', () {
    test('login success sets user data', () async {
      when(mockDb.authenticateUser(any, any))
          .thenAnswer((_) async => {'id': 3});
      when(mockDb.getUserById(3)).thenAnswer((_) async => User(
            id: 3,
            email: 'login@test.com',
            password: 'pass',
            name: 'Login User',
            createdAt: DateTime(2023),
          ));

      final result = await provider.login(
        email: 'login@test.com',
        password: 'pass',
      );

      expect(result['success'], true);
      expect(result['message'], AppConstants.successLogin);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUserName, 'Login User');
    });

    test('login fails with wrong password', () async {
      when(mockDb.authenticateUser(any, any)).thenAnswer((_) async => null);

      final result = await provider.login(
        email: 'wrong@test.com',
        password: 'wrong',
      );

      expect(result['success'], false);
      expect(result['message'], AppConstants.errorWrongPassword);
      expect(provider.isLoggedIn, false);
    });
  });

  group('AuthProvider - Logout', () {
    test('logout clears user data', () async {
      provider.setUserDataForTest(
        userId: 4,
        name: 'User',
        email: 'user@test.com',
      );

      await provider.logout();

      expect(provider.isLoggedIn, false);
      expect(provider.currentUserId, null);
      expect(provider.currentUserName, null);
    });
  });

  group('AuthProvider - Update Profile', () {
    test('updateProfile success when logged in', () async {
      provider.setUserDataForTest(
        userId: 5,
        name: 'Old Name',
        email: 'test@test.com',
      );
      when(mockDb.updateUserProfile(any, any, any)).thenAnswer((_) async => 1);

      final result = await provider.updateProfile(
        name: 'New Name',
        avatarUrl: 'new.jpg',
      );

      expect(result['success'], true);
      expect(result['message'], AppConstants.successUpdateProfile);
      expect(provider.currentUserName, 'New Name');
      expect(provider.currentUserAvatar, 'new.jpg');
    });

    test('updateProfile fails if not logged in', () async {
      final result = await provider.updateProfile(
        name: 'Name',
        avatarUrl: null,
      );

      expect(result['success'], false);
      expect(result['message'], 'Chưa đăng nhập');
    });
  });

  group('AuthProvider - Change Password', () {
    test('changePassword success', () async {
      provider.setUserDataForTest(
        userId: 6,
        name: 'User',
        email: 'change@test.com',
      );
      when(mockDb.authenticateUser('change@test.com', 'old'))
          .thenAnswer((_) async => {'id': 6});
      when(mockDb.changePassword(6, 'new')).thenAnswer((_) async => 1);

      final result = await provider.changePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );

      expect(result['success'], true);
      expect(result['message'], AppConstants.successChangePassword);
    });

    test('changePassword fails wrong current password', () async {
      provider.setUserDataForTest(
        userId: 7,
        name: 'User',
        email: 'wrong@test.com',
      );
      when(mockDb.authenticateUser(any, any)).thenAnswer((_) async => null);

      final result = await provider.changePassword(
        currentPassword: 'wrong',
        newPassword: 'new',
      );

      expect(result['success'], false);
      expect(result['message'], 'Mật khẩu hiện tại không đúng');
    });
  });

  group('AuthProvider - Loading State', () {
    test('isLoading works during register', () async {
      when(mockDb.authenticateUser(any, any)).thenAnswer((_) async => null);
      when(mockDb.registerUser(any, any, any)).thenAnswer((_) async => 8);

      expect(provider.isLoading, false);

      final future = provider.register(
        email: 'load@test.com',
        password: 'pass',
        name: 'User',
      );

      expect(provider.isLoading, true);

      await future;
      expect(provider.isLoading, false);
    });
  });
}
