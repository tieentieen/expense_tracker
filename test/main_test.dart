import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp renders without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that MaterialApp is rendered.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Expense Tracker');
    });

    testWidgets('MyApp debug banner is hidden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('MyApp initial route is login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, '/login');
    });

    testWidgets('MyApp handles ThemeProvider not found in context',
        (WidgetTester tester) async {
      // Test the scenario where MyApp is built without MultiProvider wrapper
      await tester.pumpWidget(const MyApp());

      // Should not throw exception and should render MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Theme Configuration Tests', () {
    testWidgets('MyApp has light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('MyApp has dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('MyApp uses themeMode from ThemeProvider',
        (WidgetTester tester) async {
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Initial theme mode
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final initialThemeMode = materialApp.themeMode;

      // Verify theme mode is not null
      expect(initialThemeMode, isNotNull);

      // Test that MaterialApp has themeMode property
      expect(materialApp.themeMode, isNotNull);
    });
  });

  group('Provider Configuration Tests', () {
    testWidgets('All providers are available in widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: Builder(
            builder: (context) {
              // Access all providers to ensure they exist
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final transactionProvider =
                  Provider.of<TransactionProvider>(context, listen: false);

              expect(themeProvider, isNotNull);
              expect(authProvider, isNotNull);
              expect(transactionProvider, isNotNull);

              return Container();
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('ThemeProvider can be accessed and has themeMode property',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: Builder(
            builder: (context) {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              
              // Kiểm tra provider có themeMode property
              expect(provider.themeMode, isNotNull);
              
              return Container();
            },
          ),
        ),
      );
      
      expect(tester.takeException(), isNull);
    });
  });

  group('Route Configuration Tests', () {
    testWidgets('Routes are defined correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Check that routes are defined
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/login'), isTrue);
      expect(materialApp.routes!.containsKey('/register'), isTrue);
      expect(materialApp.routes!.containsKey('/home'), isTrue);
      expect(materialApp.routes!.containsKey('/report'), isTrue);
      expect(materialApp.routes!.containsKey('/profile'), isTrue);
      expect(materialApp.routes!.containsKey('/add-transaction'), isTrue);
    });

    testWidgets('onGenerateRoute is defined', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.onGenerateRoute, isNotNull);
    });

    testWidgets('Edit transaction route can be generated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Test onGenerateRoute for edit transaction
      final routeSettings = RouteSettings(
        name: '/edit-transaction',
        arguments: {
          'transaction': {'id': 1, 'title': 'Test'},
          'isEditing': true,
        },
      );
      
      final route = materialApp.onGenerateRoute!(routeSettings);
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });
  });

  group('Error Handling Tests', () {
    testWidgets('MyApp handles missing providers gracefully',
        (WidgetTester tester) async {
      // Test without any providers
      await tester.pumpWidget(const MyApp());

      // Should still render without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MyApp builds without theme provider fallback',
        (WidgetTester tester) async {
      // Test with only some providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Should still render without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Unknown route returns null in onGenerateRoute',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      final routeSettings = RouteSettings(name: '/unknown-route');
      final route = materialApp.onGenerateRoute!(routeSettings);
      
      expect(route, isNull);
    });
  });
}