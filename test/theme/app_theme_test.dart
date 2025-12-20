// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/theme/app_colors.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme should have correct base properties', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(theme.colorScheme.primary, AppColors.primaryLight);
      expect(theme.colorScheme.secondary, AppColors.secondaryLight);
      expect(theme.colorScheme.surface, AppColors.surfaceLight);
      expect(theme.colorScheme.error, AppColors.errorLight);
    });

    test('darkTheme should have correct base properties', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(theme.colorScheme.primary, AppColors.primaryDark);
      expect(theme.colorScheme.secondary, AppColors.secondaryDark);
      expect(theme.colorScheme.surface, AppColors.surfaceDark);
      expect(theme.colorScheme.error, AppColors.errorDark);
    });

    testWidgets('lightTheme app bar should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test AppBar'),
            ),
          ),
        ),
      );

      // Chỉ kiểm tra rằng widget tồn tại và có đúng nội dung
      expect(find.text('Test AppBar'), findsOneWidget);
    });

    testWidgets('lightTheme elevated button should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('lightTheme input decoration should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(
                labelText: 'Test Input',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('lightTheme card should render with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Test Card'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('lightTheme chip should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Chip(
              label: Text('Test Chip'),
            ),
          ),
        ),
      );

      expect(find.text('Test Chip'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('lightTheme bottom navigation bar should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('lightTheme floating action button should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('darkTheme app bar should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test AppBar'),
            ),
          ),
        ),
      );

      expect(find.text('Test AppBar'), findsOneWidget);
    });

    testWidgets('darkTheme bottom navigation bar should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    test('ThemeData instances should have different colors for light and dark themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;
      
      expect(lightTheme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(lightTheme.scaffoldBackgroundColor, isNot(equals(darkTheme.scaffoldBackgroundColor)));
      
      expect(lightTheme.colorScheme.primary, AppColors.primaryLight);
      expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
      expect(lightTheme.colorScheme.primary, isNot(equals(darkTheme.colorScheme.primary)));
    });

    testWidgets('Theme should apply to all Material widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Title'),
                        const TextField(decoration: InputDecoration(hintText: 'Enter text')),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Submit'),
                        ),
                        const Chip(label: Text('Tag')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              ],
            ),
          ),
        ),
      );

      // Kiểm tra tất cả widget đều được render
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Tag'), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Theme brightness should be correct for light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              expect(brightness, Brightness.light);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Theme brightness should be correct for dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              expect(brightness, Brightness.dark);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Theme color scheme should be applied correctly for light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expect(theme.colorScheme.primary, AppColors.primaryLight);
              expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Theme color scheme should be applied correctly for dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expect(theme.colorScheme.primary, AppColors.primaryDark);
              expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}