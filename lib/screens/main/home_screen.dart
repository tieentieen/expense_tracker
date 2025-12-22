import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/widgets/balance_card.dart';
import 'package:expense_tracker/widgets/transaction_card.dart';
import 'package:expense_tracker/screens/add_transaction_screen.dart';
import 'package:expense_tracker/screens/main/profile_screen.dart';
import 'package:expense_tracker/screens/main/report_screen.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  String _selectedTimeFilter = 'month';
  String? _selectedCategoryFilter;

  final List<String> _timeFilters = ['today', 'week', 'month', 'year', 'all'];

  final Map<String, String> _timeFilterLabels = {
    'today': 'Hôm nay',
    'week': 'Tuần này',
    'month': 'Tháng này',
    'year': 'Năm nay',
    'all': 'Tất cả',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    transactionProvider.loadInitialData();
    transactionProvider.loadTransactions(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<Widget> screens = [
      _buildHomeTab(transactionProvider, authProvider, themeProvider),
      ReportScreen(userId: widget.userId),
      ProfileScreen(
        userId: widget.userId,
        userName: authProvider.currentUserName ?? 'Người dùng',
        userEmail: authProvider.currentUserEmail ?? '',
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(themeProvider),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeTab(
    TransactionProvider provider,
    AuthProvider authProvider,
    ThemeProvider themeProvider,
  ) {
    final now = DateTime.now();
    final monthYear = Formatters.formatMonthYear(now);
    final userName = authProvider.currentUserName?.split(' ').first ?? 'Bạn';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, $userName! 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Tháng $monthYear',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha((0.8 * 255).round()),
              ),
            ),
          ],
        ),
        backgroundColor: themeProvider.isDarkMode
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Tìm kiếm',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Lọc',
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Chế độ tối/sáng',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadTransactions(widget.userId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Balance Card
              BalanceCard(
                balance: provider.balance,
                income: provider.totalIncome,
                expense: provider.totalExpense,
                onTap: () {
                  // Có thể thêm hành động khi tap vào balance card
                },
              ),

              // Time Filter Chips
              _buildTimeFilterChips(),

              // Quick Stats
              _buildQuickStats(provider),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GIAO DỊCH GẦN ĐÂY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Tổng: ${provider.transactions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions List
              provider.transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionList(provider),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeFilters.length,
        itemBuilder: (context, index) {
          final filter = _timeFilters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_timeFilterLabels[filter]!),
              selected: _selectedTimeFilter == filter,
              selectedColor:
                  AppColors.primaryLight.withAlpha((0.3 * 255).round()),
              onSelected: (_) {
                setState(() {
                  _selectedTimeFilter = filter;
                });
                // Update provider after state change to avoid calling
                // notifyListeners during the widget build phase.
                final provider =
                    Provider.of<TransactionProvider>(context, listen: false);
                provider.setTimeFilter(filter);
              },
              labelStyle: TextStyle(
                color: _selectedTimeFilter == filter
                    ? AppColors.primaryLight
                    : Colors.grey,
                fontWeight: _selectedTimeFilter == filter
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(TransactionProvider provider) {
    final categoryData = provider.getCategoryAnalysis('expense');
    final topCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CHI TIÊU HÀNG ĐẦU',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              if (topCategories.isEmpty)
                _buildNoDataMessage('Chưa có chi tiêu nào')
              else
                Column(
                  children: topCategories.map((entry) {
                    final percentage = provider.totalExpense > 0
                        ? (entry.value / provider.totalExpense * 100)
                            .toStringAsFixed(1)
                        : '0.0';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.categoryColors[
                                  topCategories.indexOf(entry) %
                                      AppColors.categoryColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              // View all categories button
              if (topCategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/report',
                          arguments: widget.userId,
                        );
                      },
                      child: const Text(
                        'Xem tất cả →',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    // Nhóm giao dịch theo ngày
    final Map<String, List<Transaction>> groupedTransactions = {};

    for (final transaction in provider.transactions) {
      final dateKey = Formatters.formatDate(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: groupedTransactions.entries.map((entry) {
          final expenseForDay = entry.value
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);
          final incomeForDay = entry.value
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        if (incomeForDay > 0)
                          Text(
                            '+${Formatters.formatCurrency(incomeForDay)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.incomeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (incomeForDay > 0 && expenseForDay > 0)
                          const Text(' • ',
                              style: TextStyle(color: Colors.grey)),
                        if (expenseForDay > 0)
                          Text(
                            '-${Formatters.formatCurrency(expenseForDay)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.expenseColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              ...entry.value.map((transaction) {
                return TransactionCard(
                  transaction: transaction,
                  onTap: () => _editTransaction(transaction),
                  onDelete: () => _deleteTransaction(
                    transaction.id!,
                    provider,
                  ),
                  showDate: false,
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm giao dịch đầu tiên của bạn!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _addTransaction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Thêm giao dịch',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(ThemeProvider themeProvider) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor:
          themeProvider.isDarkMode ? AppColors.surfaceDark : Colors.white,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addTransaction,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tooltip: 'Thêm giao dịch',
      child: const Icon(Icons.add, size: 30),
    );
  }

  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    ).then((_) {
      _loadData();
    });
  }

  void _editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transaction: transaction,
          isEditing: true,
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }

  Future<void> _deleteTransaction(
    int transactionId,
    TransactionProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text(
              'XÓA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteTransaction(transactionId, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa giao dịch thành công'),
            backgroundColor: AppColors.successColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm giao dịch'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa (tiêu đề, ghi chú)...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) {
            final provider =
                Provider.of<TransactionProvider>(context, listen: false);
            provider.setSearchKeyword(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              final provider =
                  Provider.of<TransactionProvider>(context, listen: false);
              provider.setSearchKeyword('');
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final categories = provider.getCategoryAnalysis('expense').keys.toList();
    final incomeCategories =
        provider.getCategoryAnalysis('income').keys.toList();
    final allCategories = [...categories, ...incomeCategories];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.filter_list, size: 20),
                SizedBox(width: 8),
                Text('Lọc giao dịch'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter by type
                  const Text(
                    'Loại giao dịch:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Row(
                          children: [
                            Icon(Icons.arrow_upward,
                                size: 14, color: AppColors.incomeColor),
                            SizedBox(width: 4),
                            Text('Thu nhập'),
                          ],
                        ),
                        selected: _selectedCategoryFilter == 'income_all',
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryFilter = 'income_all';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Row(
                          children: [
                            Icon(Icons.arrow_downward,
                                size: 14, color: AppColors.expenseColor),
                            SizedBox(width: 4),
                            Text('Chi tiêu'),
                          ],
                        ),
                        selected: _selectedCategoryFilter == 'expense_all',
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryFilter = 'expense_all';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter by category
                  const Text(
                    'Danh mục cụ thể:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allCategories.map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategoryFilter == category,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryFilter = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedCategoryFilter = null;
                  provider.setSelectedCategory(null);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('XÓA LỌC'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.setSelectedCategory(_selectedCategoryFilter);
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                ),
                child: const Text(
                  'ÁP DỤNG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
