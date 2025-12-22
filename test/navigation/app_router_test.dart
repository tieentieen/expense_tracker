import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/navigation/app_router.dart';

void main() {
  group('AppRouter', () {
    test('router is not null', () {
      expect(AppRouter.router, isNotNull);
    });

    test('router can generate named locations correctly', () {
      // Test các named location cơ bản
      expect(AppRouter.router.namedLocation('login'), '/login');
      expect(AppRouter.router.namedLocation('register'), '/register');
      expect(AppRouter.router.namedLocation('home'), '/home');
      expect(AppRouter.router.namedLocation('report'), '/report');
      expect(AppRouter.router.namedLocation('profile'), '/profile');
      expect(AppRouter.router.namedLocation('add-transaction'),
          '/add-transaction');
      expect(AppRouter.router.namedLocation('edit-transaction'),
          '/edit-transaction');
    });

    test('router has configuration', () {
      expect(AppRouter.router.configuration, isNotNull);
    });

    test('router can be instantiated multiple times', () {
      // Test singleton pattern hoạt động
      final router1 = AppRouter.router;
      final router2 = AppRouter.router;
      expect(router1, same(router2));
    });

    test('router handles navigation requests', () {
      final router = AppRouter.router;
      expect(() => router.go('/login'), returnsNormally);
    });
  });
}
