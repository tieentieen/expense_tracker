import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:expense_tracker/screens/main/home_screen.dart';
import 'package:expense_tracker/screens/auth/register_screen.dart';
import 'package:expense_tracker/screens/main/report_screen.dart';
import 'package:expense_tracker/screens/main/profile_screen.dart';
import 'package:expense_tracker/screens/add_transaction_screen.dart';
import 'package:expense_tracker/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // In widget tests we may pump `MyApp` directly without wrapping it in
    // the application's `MultiProvider`. Guard the lookup of
    // `ThemeProvider` so tests don't throw a ProviderNotFoundException.
    ThemeProvider themeProvider;
    try {
      themeProvider = Provider.of<ThemeProvider>(context);
    } catch (_) {
      // Fallback to a default ThemeProvider for tests.
      themeProvider = ThemeProvider();
    }

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as int?;
          return HomeScreen(userId: userId ?? 0);
        },
        '/report': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as int?;
          return ReportScreen(userId: userId ?? 0);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProfileScreen(
            userId: args?['userId'] ?? 0,
            userName: args?['userName'] ?? 'Người dùng',
            userEmail: args?['userEmail'] ?? '',
          );
        },
        '/add-transaction': (context) => const AddTransactionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-transaction') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AddTransactionScreen(
              transaction: args['transaction'],
              isEditing: true,
            ),
          );
        }
        return null;
      },
    );
  }
}