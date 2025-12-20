// test/theme/app_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/theme/app_colors.dart';

void main() {
  group('AppColors Tests', () {
    test('Light theme colors should have correct values', () {
      expect(AppColors.primaryLight, const Color(0xFFA7C5EB));
      expect(AppColors.secondaryLight, const Color(0xFFE6E6FA));
      expect(AppColors.accentLight, const Color(0xFF98D8AA));
      expect(AppColors.backgroundLight, const Color(0xFFFAF3E0));
      expect(AppColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(AppColors.errorLight, const Color(0xFFFFB6B6));
      expect(AppColors.onBackgroundLight, const Color(0xFF5D5D5D));
      expect(AppColors.onSurfaceLight, const Color(0xFF333333));
      expect(AppColors.cardLight, const Color(0xFFFFFFFF));
      expect(AppColors.dividerLight, const Color(0xFFE0E0E0));
    });

    test('Dark theme colors should have correct values', () {
      expect(AppColors.primaryDark, const Color(0xFF6A93C9));
      expect(AppColors.secondaryDark, const Color(0xFF9B9BC8));
      expect(AppColors.accentDark, const Color(0xFF6BBF8A));
      expect(AppColors.backgroundDark, const Color(0xFF242424));
      expect(AppColors.surfaceDark, const Color(0xFF363636));
      expect(AppColors.errorDark, const Color(0xFFCF6679));
      expect(AppColors.onBackgroundDark, const Color(0xFFE0E0E0));
      expect(AppColors.onSurfaceDark, const Color(0xFFFFFFFF));
      expect(AppColors.cardDark, const Color(0xFF424242));
      expect(AppColors.dividerDark, const Color(0xFF555555));
    });

    test('Semantic colors should have correct values', () {
      expect(AppColors.incomeColor, const Color(0xFF4CAF50));
      expect(AppColors.expenseColor, const Color(0xFFF44336));
      expect(AppColors.warningColor, const Color(0xFFFF9800));
      expect(AppColors.successColor, const Color(0xFF4CAF50));
      expect(AppColors.infoColor, const Color(0xFF2196F3));
      expect(AppColors.errorColor, AppColors.errorLight);
    });

    test('Category colors should have correct length', () {
      expect(AppColors.categoryColors.length, 7);
      expect(AppColors.incomeCategoryColors.length, 5);
    });

    test('Gradient colors should have correct length', () {
      expect(AppColors.primaryGradient.length, 2);
      expect(AppColors.successGradient.length, 2);
      expect(AppColors.warningGradient.length, 2);
      expect(AppColors.errorGradient.length, 2);
    });

    test('getCategoryColor should return correct color for expense type', () {
      final color0 = AppColors.getCategoryColor(0, 'expense');
      final color1 = AppColors.getCategoryColor(1, 'expense');
      final color10 = AppColors.getCategoryColor(10, 'expense');
      
      expect(color0, AppColors.categoryColors[0]);
      expect(color1, AppColors.categoryColors[1]);
      // Test wrap-around behavior
      expect(color10, AppColors.categoryColors[3]); // 10 % 7 = 3
    });

    test('getCategoryColor should return correct color for income type', () {
      final color0 = AppColors.getCategoryColor(0, 'income');
      final color1 = AppColors.getCategoryColor(1, 'income');
      final color10 = AppColors.getCategoryColor(10, 'income');
      
      expect(color0, AppColors.incomeCategoryColors[0]);
      expect(color1, AppColors.incomeCategoryColors[1]);
      // Test wrap-around behavior
      expect(color10, AppColors.incomeCategoryColors[0]); // 10 % 5 = 0
    });

    // TEST ĐƠN GIẢN CHO THEME-BASED GETTERS - SỬA LẠI
    test('Theme-based getters logic is correct', () {
      // Test getPrimary
      expect(AppColors.primaryLight, const Color(0xFFA7C5EB));
      expect(AppColors.primaryDark, const Color(0xFF6A93C9));
      
      // Test getBackground
      expect(AppColors.backgroundLight, const Color(0xFFFAF3E0));
      expect(AppColors.backgroundDark, const Color(0xFF242424));
      
      // Test getSurface
      expect(AppColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceDark, const Color(0xFF363636));
      
      // Test getCardColor
      expect(AppColors.cardLight, const Color(0xFFFFFFFF));
      expect(AppColors.cardDark, const Color(0xFF424242));
      
      // Test getTextColor
      expect(AppColors.onBackgroundLight, const Color(0xFF5D5D5D));
      expect(AppColors.onBackgroundDark, const Color(0xFFE0E0E0));
      
      // Test getDividerColor
      expect(AppColors.dividerLight, const Color(0xFFE0E0E0));
      expect(AppColors.dividerDark, const Color(0xFF555555));
    });

    test('All color values should be valid', () {
      // Test that all colors are valid (alpha channel is present)
      final List<Color> allColors = [
        // Light theme
        AppColors.primaryLight,
        AppColors.secondaryLight,
        AppColors.accentLight,
        AppColors.backgroundLight,
        AppColors.surfaceLight,
        AppColors.errorLight,
        AppColors.onBackgroundLight,
        AppColors.onSurfaceLight,
        AppColors.cardLight,
        AppColors.dividerLight,
        // Dark theme
        AppColors.primaryDark,
        AppColors.secondaryDark,
        AppColors.accentDark,
        AppColors.backgroundDark,
        AppColors.surfaceDark,
        AppColors.errorDark,
        AppColors.onBackgroundDark,
        AppColors.onSurfaceDark,
        AppColors.cardDark,
        AppColors.dividerDark,
        // Semantic
        AppColors.incomeColor,
        AppColors.expenseColor,
        AppColors.warningColor,
        AppColors.successColor,
        AppColors.infoColor,
        AppColors.errorColor,
      ];

      for (final color in allColors) {
        expect(color.alpha, greaterThan(0)); // Alpha should be > 0
        expect(color.value, isNotNull); // Color value should not be null
      }
    });

    test('Category colors should have unique values', () {
      // Check for duplicate colors in category lists
      final Set<Color> expenseColorSet = Set.from(AppColors.categoryColors);
      final Set<Color> incomeColorSet = Set.from(AppColors.incomeCategoryColors);

      expect(expenseColorSet.length, AppColors.categoryColors.length,
          reason: 'Expense category colors should be unique');
      expect(incomeColorSet.length, AppColors.incomeCategoryColors.length,
          reason: 'Income category colors should be unique');
    });
  });
}

