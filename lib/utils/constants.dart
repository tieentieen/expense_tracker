class AppConstants {
  // App Info
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Ứng dụng quản lý chi tiêu cá nhân';
  
  // Database
  static const String databaseName = 'expense_tracker.db';
  static const int databaseVersion = 1;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxNoteLength = 500;
  
  // Currency
  static const String currencySymbol = '₫';
  static const String currencyCode = 'VND';
  static const int currencyDecimalDigits = 0;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MM/yyyy';
  static const String dayMonthFormat = 'dd/MM';
  
  // Error Messages
  static const String errorNetwork = 'Lỗi kết nối mạng';
  static const String errorServer = 'Lỗi máy chủ';
  static const String errorUnknown = 'Đã xảy ra lỗi không xác định';
  static const String errorEmptyField = 'Vui lòng điền đầy đủ thông tin';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordMismatch = 'Mật khẩu không khớp';
  static const String errorWeakPassword = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const String errorUserNotFound = 'Người dùng không tồn tại';
  static const String errorWrongPassword = 'Mật khẩu không đúng';
  static const String errorEmailInUse = 'Email đã được sử dụng';
  
  // Success Messages
  static const String successLogin = 'Đăng nhập thành công';
  static const String successRegister = 'Đăng ký thành công';
  static const String successLogout = 'Đăng xuất thành công';
  static const String successAddTransaction = 'Thêm giao dịch thành công';
  static const String successUpdateTransaction = 'Cập nhật giao dịch thành công';
  static const String successDeleteTransaction = 'Xóa giao dịch thành công';
  static const String successUpdateProfile = 'Cập nhật thông tin thành công';
  static const String successChangePassword = 'Đổi mật khẩu thành công';
  
  // Default limits
  static const double maxTransactionAmount = 1000000000; // 1 tỷ
}