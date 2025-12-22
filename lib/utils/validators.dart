class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu không khớp';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }

    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }

    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }

    if (value.length > 100) {
      return 'Tiêu đề không được quá 100 ký tự';
    }

    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }

    if (amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }

    if (amount > 1000000000) {
      // 1 tỷ
      return 'Số tiền quá lớn';
    }

    return null;
  }

  // Note validation
  static String? validateNote(String? value) {
    if (value == null) return null;

    if (value.length > 500) {
      return 'Ghi chú không được quá 500 ký tự';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Vui lòng chọn ngày';
    }

    if (value.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      return 'Ngày không được trong tương lai quá 1 năm';
    }

    return null;
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn danh mục';
    }

    return null;
  }

  // Transaction type validation
  static String? validateTransactionType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn loại giao dịch';
    }

    if (value != 'income' && value != 'expense') {
      return 'Loại giao dịch không hợp lệ';
    }

    return null;
  }
}
