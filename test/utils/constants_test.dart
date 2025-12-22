import 'package:expense_tracker/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('appName is correct', () {
      expect(AppConstants.appName, 'Expense Tracker');
    });

    test('appVersion is correct', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('databaseName is correct', () {
      expect(AppConstants.databaseName, 'expense_tracker.db');
    });

    test('minPasswordLength is correct', () {
      expect(AppConstants.minPasswordLength, 6);
    });

    test('currencySymbol is correct', () {
      expect(AppConstants.currencySymbol, '₫');
    });

    test('dateFormat is correct', () {
      expect(AppConstants.dateFormat, 'dd/MM/yyyy');
    });

    test('errorEmptyField is correct', () {
      expect(AppConstants.errorEmptyField, 'Vui lòng điền đầy đủ thông tin');
    });

    test('errorInvalidEmail is correct', () {
      expect(AppConstants.errorInvalidEmail, 'Email không hợp lệ');
    });

    test('successLogin is correct', () {
      expect(AppConstants.successLogin, 'Đăng nhập thành công');
    });
  });
}
