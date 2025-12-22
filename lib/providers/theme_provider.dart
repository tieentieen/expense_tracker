import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('theme_mode') ?? 'light';

      if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString().split('.')[1]);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    // Lưu vào shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('theme_mode', _themeMode.toString().split('.')[1]);
    }).catchError((e) {
      print('Error saving theme: $e');
    });
  }

  // Get theme data based on mode
  ThemeData getTheme(BuildContext context) {
    return isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}
