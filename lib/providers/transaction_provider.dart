import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart' as my_transaction;
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<my_transaction.Transaction> _transactions = [];
  List<my_transaction.Transaction> _filteredTransactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  // Filter states
  String _searchKeyword = '';
  String? _selectedCategory;
  String _timeFilter = 'month';
  String? _selectedType;

  // Category data
  List<Category> _categories = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  // Getters
  List<my_transaction.Transaction> get transactions => _filteredTransactions;
  List<my_transaction.Transaction> get allTransactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;

  List<Category> get categories => _categories;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;

  String get searchKeyword => _searchKeyword;
  String? get selectedCategory => _selectedCategory;
  String get timeFilter => _timeFilter;
  String? get selectedType => _selectedType;

  final DatabaseHelper _dbHelper;

  // Constructor mới: cho phép inject mock trong test
  TransactionProvider({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> loadInitialData() async {
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await _dbHelper.getCategories();
    _expenseCategories =
        _categories.where((cat) => cat.type == 'expense').toList();
    _incomeCategories =
        _categories.where((cat) => cat.type == 'income').toList();
    notifyListeners();
  }

  Future<void> loadTransactions(int userId) async {
    final transactions = await _dbHelper.getTransactions(userId);
    _transactions = transactions;
    _applyFilters();
    _calculateTotals();
    notifyListeners();
  }

  // Public helper to set transactions in tests without DB operations.
  void setTransactionsForTest(List<my_transaction.Transaction> transactions) {
    _transactions = List.from(transactions);
    _filteredTransactions = List.from(transactions);
    _calculateTotals();
    notifyListeners();
  }

  Future<void> addTransaction(my_transaction.Transaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions(transaction.userId);
  }

  Future<void> updateTransaction(my_transaction.Transaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions(transaction.userId);
  }

  Future<void> deleteTransaction(int id, int userId) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions(userId);
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    _timeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedType(String? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedCategory = null;
    _timeFilter = 'month';
    _selectedType = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      bool matchesSearch = _searchKeyword.isEmpty ||
          transaction.title.toLowerCase().contains(_searchKeyword) ||
          (transaction.note?.toLowerCase().contains(_searchKeyword) ?? false);

      bool matchesCategory = _selectedCategory == null ||
          _getCategoryName(transaction.categoryId) == _selectedCategory;

      bool matchesTime = _filterByTime(transaction.date);

      bool matchesType =
          _selectedType == null || transaction.type == _selectedType;

      return matchesSearch && matchesCategory && matchesTime && matchesType;
    }).toList();

    _calculateTotals();
  }

  bool _filterByTime(DateTime date) {
    final now = DateTime.now();

    switch (_timeFilter) {
      case 'today':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo) &&
            date.isBefore(now.add(const Duration(days: 1)));
      case 'month':
        return date.year == now.year && date.month == now.month;
      case 'year':
        return date.year == now.year;
      default:
        return true;
    }
  }

  void _calculateTotals() {
    _totalIncome = _filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);

    _totalExpense = _filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);

    _balance = _totalIncome - _totalExpense;
  }

  String _getCategoryName(int categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(
        id: 0,
        name: 'Khác',
        type: 'expense',
        icon: '❓',
        color: 0xFFC0C0C0,
      ),
    );
    return category.name;
  }

  Category getCategoryById(int categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(
        id: 0,
        name: 'Khác',
        type: 'expense',
        icon: '❓',
        color: 0xFFC0C0C0,
      ),
    );
  }

  Map<String, double> getCategoryAnalysis(String type) {
    final filtered = _filteredTransactions.where((t) => t.type == type);
    final Map<String, double> result = {};

    for (var transaction in filtered) {
      final categoryName = _getCategoryName(transaction.categoryId);
      result.update(
        categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return result;
  }

  List<double> getMonthlyData(int year, String type) {
    final List<double> monthlyTotals = List.filled(12, 0);

    for (var transaction in _transactions) {
      if (transaction.date.year == year && transaction.type == type) {
        monthlyTotals[transaction.date.month - 1] += transaction.amount;
      }
    }

    return monthlyTotals;
  }

  Map<String, double> getWeeklyData(DateTime startDate, String type) {
    final Map<String, double> weeklyData = {};

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);

      final dailyTotal = _transactions
          .where((t) =>
              t.type == type &&
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .fold(0.0, (sum, t) => sum + t.amount);

      weeklyData[dayName] = dailyTotal;
    }

    return weeklyData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  List<my_transaction.Transaction> getRecentTransactions(int limit) {
    return _transactions.take(limit).toList();
  }

  List<my_transaction.Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  my_transaction.Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
