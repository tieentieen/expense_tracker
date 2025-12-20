import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Pastel & Kem Palette
  static const Color primaryLight = Color(0xFFA7C5EB);   // Xanh pastel nhạt
  static const Color secondaryLight = Color(0xFFE6E6FA); // Lavender nhạt
  static const Color accentLight = Color(0xFF98D8AA);    // Mint green
  static const Color backgroundLight = Color(0xFFFAF3E0); // Nền kem ấm
  static const Color surfaceLight = Color(0xFFFFFFFF);   // Nền trắng
  static const Color errorLight = Color(0xFFFFB6B6);     // Đỏ pastel
  static const Color onBackgroundLight = Color(0xFF5D5D5D); // Text trên nền
  static const Color onSurfaceLight = Color(0xFF333333); // Text trên surface
  static const Color cardLight = Color(0xFFFFFFFF);     // Card background
  static const Color dividerLight = Color(0xFFE0E0E0);  // Divider color
  
  // Dark Theme
  static const Color primaryDark = Color(0xFF6A93C9);
  static const Color secondaryDark = Color(0xFF9B9BC8);
  static const Color accentDark = Color(0xFF6BBF8A);
  static const Color backgroundDark = Color(0xFF242424);
  static const Color surfaceDark = Color(0xFF363636);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF555555);
  
  // Semantic Colors (cho cả 2 theme)
  static const Color incomeColor = Color(0xFF4CAF50);    // Xanh lá thu nhập
  static const Color expenseColor = Color(0xFFF44336);   // Đỏ chi tiêu
  static const Color warningColor = Color(0xFFFF9800);   // Cam cảnh báo
  static const Color successColor = Color(0xFF4CAF50);   // Xanh thành công
  static const Color infoColor = Color(0xFF2196F3);      // Xanh dương thông tin
  // Backwards-compatible semantic alias used across the app
  static const Color errorColor = errorLight;
  
  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFFFB6B6), // Ăn uống
    Color(0xFFA7C5EB), // Di chuyển
    Color(0xFF98D8AA), // Mua sắm
    Color(0xFFDDA0DD), // Giải trí
    Color(0xFFFFD700), // Y tế
    Color(0xFF87CEEB), // Hóa đơn
    Color(0xFFC0C0C0), // Khác
  ];
  
  // Income Category Colors
  static const List<Color> incomeCategoryColors = [
    Color(0xFF4CAF50), // Lương
    Color(0xFF2196F3), // Freelance
    Color(0xFF9C27B0), // Đầu tư
    Color(0xFFFF9800), // Quà tặng
    Color(0xFF795548), // Khác
  ];
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFA7C5EB),
    Color(0xFF98D8AA),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFC107),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFFF5722),
  ];
  
  // Get color based on theme
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDark
        : primaryLight;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }
  
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dividerDark
        : dividerLight;
  }
  
  // Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? onBackgroundDark
        : onBackgroundLight;
  }
  
  // Get category color by index
  static Color getCategoryColor(int index, String type) {
    if (type == 'income') {
      return incomeCategoryColors[index % incomeCategoryColors.length];
    }
    return categoryColors[index % categoryColors.length];
  }
}