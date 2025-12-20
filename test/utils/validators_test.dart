import 'package:expense_tracker/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), 'Vui lòng nhập email');
      });

      test('returns error for invalid email', () {
        expect(Validators.validateEmail('invalid'), 'Email không hợp lệ');
        expect(Validators.validateEmail('test@'), 'Email không hợp lệ');
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        expect(Validators.validatePassword('123456'), null);
      });

      test('returns error for empty password', () {
        expect(Validators.validatePassword(''), 'Vui lòng nhập mật khẩu');
      });

      test('returns error for short password', () {
        expect(Validators.validatePassword('12345'), 'Mật khẩu phải có ít nhất 6 ký tự');
      });
    });

    group('validateConfirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.validateConfirmPassword('123456', '123456'), null);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.validateConfirmPassword('123456', 'wrong'), 'Mật khẩu không khớp');
      });

      test('returns error for empty confirm password', () {
        expect(Validators.validateConfirmPassword('', '123456'), 'Vui lòng xác nhận mật khẩu');
      });
    });

    group('validateName', () {
      test('returns null for valid name', () {
        expect(Validators.validateName('Nguyễn Văn A'), null);
      });

      test('returns error for empty name', () {
        expect(Validators.validateName(''), 'Vui lòng nhập họ tên');
      });

      test('returns error for short name', () {
        expect(Validators.validateName('A'), 'Họ tên phải có ít nhất 2 ký tự');
      });
    });

    group('validateTitle', () {
      test('returns null for valid title', () {
        expect(Validators.validateTitle('Ăn trưa'), null);
      });

      test('returns error for empty title', () {
        expect(Validators.validateTitle(''), 'Vui lòng nhập tiêu đề');
      });

      test('returns error for too long title', () {
        final longTitle = 'A' * 101;
        expect(Validators.validateTitle(longTitle), 'Tiêu đề không được quá 100 ký tự');
      });
    });

    group('validateAmount', () {
      test('returns null for valid amount', () {
        expect(Validators.validateAmount('100000'), null);
      });

      test('returns error for empty amount', () {
        expect(Validators.validateAmount(''), 'Vui lòng nhập số tiền');
      });

      test('returns error for invalid amount', () {
        expect(Validators.validateAmount('abc'), 'Số tiền không hợp lệ');
      });

      test('returns error for zero or negative amount', () {
        expect(Validators.validateAmount('0'), 'Số tiền phải lớn hơn 0');
        expect(Validators.validateAmount('-100'), 'Số tiền phải lớn hơn 0');
      });

      test('returns error for too large amount', () {
        expect(Validators.validateAmount('1000000001'), 'Số tiền quá lớn');
      });
    });

    group('validateNote', () {
      test('returns null for valid note', () {
        expect(Validators.validateNote('Ghi chú bình thường'), null);
      });

      test('returns null for empty note', () {
        expect(Validators.validateNote(null), null);
        expect(Validators.validateNote(''), null);
      });

      test('returns error for too long note', () {
        final longNote = 'A' * 501;
        expect(Validators.validateNote(longNote), 'Ghi chú không được quá 500 ký tự');
      });
    });

    group('validateDate', () {
      test('returns null for valid date', () {
        expect(Validators.validateDate(DateTime.now()), null);
      });

      test('returns error for null date', () {
        expect(Validators.validateDate(null), 'Vui lòng chọn ngày');
      });

      test('returns error for future date too far', () {
        final farFuture = DateTime.now().add(const Duration(days: 366));
        expect(Validators.validateDate(farFuture), 'Ngày không được trong tương lai quá 1 năm');
      });
    });

    group('validateCategory', () {
      test('returns null for valid category', () {
        expect(Validators.validateCategory('Ăn uống'), null);
      });

      test('returns error for empty category', () {
        expect(Validators.validateCategory(''), 'Vui lòng chọn danh mục');
        expect(Validators.validateCategory(null), 'Vui lòng chọn danh mục');
      });
    });

    group('validateTransactionType', () {
      test('returns null for valid type', () {
        expect(Validators.validateTransactionType('income'), null);
        expect(Validators.validateTransactionType('expense'), null);
      });

      test('returns error for empty type', () {
        expect(Validators.validateTransactionType(''), 'Vui lòng chọn loại giao dịch');
        expect(Validators.validateTransactionType(null), 'Vui lòng chọn loại giao dịch');
      });

      test('returns error for invalid type', () {
        expect(Validators.validateTransactionType('other'), 'Loại giao dịch không hợp lệ');
      });
    });
  });
}