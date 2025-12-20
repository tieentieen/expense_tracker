import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial theme is light', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
    });

    test('loadTheme from prefs - dark', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final provider = ThemeProvider();
      // Chờ cho async load hoàn thành
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);
    });

    test('loadTheme from prefs - system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});

      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isDarkMode, false);
    });

    test('setThemeMode saves to prefs and notifies', () async {
      // Dùng expectAsync với count: 1 vì chỉ notify khi setThemeMode
      final listener = expectAsync0(() {}, count: 1);
      final provider = ThemeProvider();

      // Đợi cho loadTheme hoàn thành trước
      await Future.delayed(const Duration(milliseconds: 100));
      
      provider.addListener(listener);
      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('toggleTheme switches and saves', () async {
      final provider = ThemeProvider();
      
      // Đợi cho loadTheme hoàn thành trước
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Lắng nghe từng lần toggle
      var callCount = 0;
      provider.addListener(() {
        callCount++;
      });

      // Toggle lần 1
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      expect(callCount, 1);

      // Toggle lần 2
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      expect(callCount, 2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('getTheme returns correct theme', () {
      final provider = ThemeProvider();
      
      // Tạo mock BuildContext
      final mockContext = MockBuildContext();
      
      // Ban đầu là light
      expect(provider.getTheme(mockContext).brightness, Brightness.light);
      
      // Đổi sang dark
      provider.setThemeMode(ThemeMode.dark);
      expect(provider.getTheme(mockContext).brightness, Brightness.dark);
      
      // Đổi lại light
      provider.setThemeMode(ThemeMode.light);
      expect(provider.getTheme(mockContext).brightness, Brightness.light);
    });
  });
}

// Mock BuildContext cho test
class MockBuildContext implements BuildContext {
  @override
  T dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    throw UnimplementedError();
  }
  
  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    throw UnimplementedError();
  }
  
  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    throw UnimplementedError();
  }
  
  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }
  
  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }
  
  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}
  
  @override
  void visitChildElements(ElementVisitor visitor) {}
  
  @override
  Widget get widget => Container();
  
  @override
  BuildOwner? get owner => null;
  
  @override
  Size? get size => null;
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}