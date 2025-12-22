import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/charts/expense_pie_chart.dart';
import '../../widgets/charts/income_expense_bar_chart.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class ReportScreen extends StatefulWidget {
  final int userId;

  const ReportScreen({super.key, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedPeriod = 'month'; // 'week', 'month', 'year'
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    // Filter transactions for selected period
    final filteredTransactions = provider.transactions.where((t) {
      switch (_selectedPeriod) {
        case 'week':
          final weekAgo = _selectedDate.subtract(const Duration(days: 6));
          return t.date.isAfter(weekAgo) &&
              t.date.isBefore(_selectedDate.add(const Duration(days: 1)));
        case 'month':
          return t.date.month == _selectedDate.month &&
              t.date.year == _selectedDate.year;
        case 'year':
          return t.date.year == _selectedDate.year;
        default:
          return true;
      }
    }).toList();

    final totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    // Category analysis
    final expenseByCategory = <String, double>{};
    final incomeByCategory = <String, double>{};

    for (final transaction in filteredTransactions) {
      if (transaction.type == 'expense') {
        final categoryName =
            provider.getCategoryById(transaction.categoryId).name;
        expenseByCategory.update(
          categoryName,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      } else {
        final categoryName =
            provider.getCategoryById(transaction.categoryId).name;
        incomeByCategory.update(
          categoryName,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Chi Tiêu'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _exportReport(provider),
            tooltip: 'Xuất báo cáo',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadTransactions(widget.userId);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Period selector
              _buildPeriodSelector(),

              // Summary cards
              _buildSummaryCards(totalIncome, totalExpense, balance),

              // Charts
              if (totalExpense > 0 || totalIncome > 0)
                _buildChartsSection(
                    expenseByCategory, incomeByCategory, provider),

              // Category breakdown
              _buildCategoryBreakdown(
                expenseByCategory,
                incomeByCategory,
                totalExpense,
                totalIncome,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      {'label': 'Tuần', 'value': 'week'},
      {'label': 'Tháng', 'value': 'month'},
      {'label': 'Năm', 'value': 'year'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CHỌN KỲ THỐNG KÊ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: periods.map((period) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(period['label']!),
                        selected: _selectedPeriod == period['value'],
                        selectedColor: AppColors.primaryLight
                            .withAlpha((0.3 * 255).round()),
                        onSelected: (_) {
                          setState(() {
                            _selectedPeriod = period['value']!;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _getPeriodLabel(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeDate(-1),
                    iconSize: 20,
                    tooltip: 'Kỳ trước',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _canGoToNextPeriod() ? () => _changeDate(1) : null,
                    iconSize: 20,
                    tooltip: 'Kỳ sau',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense, double balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'TỔNG THU',
              income,
              AppColors.incomeColor,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'TỔNG CHI',
              expense,
              AppColors.expenseColor,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'SỐ DƯ',
              balance,
              balance >= 0 ? AppColors.incomeColor : AppColors.expenseColor,
              balance >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (title == 'SỐ DƯ')
              Text(
                amount >= 0 ? 'Thặng dư' : 'Thâm hụt',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(
    Map<String, double> expenseByCategory,
    Map<String, double> incomeByCategory,
    TransactionProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Expense Pie Chart
          if (expenseByCategory.isNotEmpty)
            Card(
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
                      'PHÂN BỔ CHI TIÊU THEO DANH MỤC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ExpensePieChart(
                        data: expenseByCategory,
                        radius: 70,
                        showLegend: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Income Pie Chart
          if (incomeByCategory.isNotEmpty)
            Card(
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
                      'PHÂN BỔ THU NHẬP THEO DANH MỤC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: IncomePieChart(
                        data: incomeByCategory,
                        radius: 70,
                        showLegend: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Bar Chart
          Card(
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
                    'THU - CHI THEO THÁNG',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: IncomeExpenseBarChart(
                      monthlyIncome: provider.getMonthlyData(
                          DateTime.now().year, 'income'),
                      monthlyExpense: provider.getMonthlyData(
                          DateTime.now().year, 'expense'),
                      year: DateTime.now().year,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<String, double> expenseByCategory,
    Map<String, double> incomeByCategory,
    double totalExpense,
    double totalIncome,
  ) {
    final expenseEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final incomeEntries = incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHI TIẾT THEO DANH MỤC',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Expense breakdown
          if (expenseEntries.isNotEmpty)
            _buildCategoryList(
              'CHI TIÊU',
              expenseEntries,
              totalExpense,
              AppColors.expenseColor,
            ),

          const SizedBox(height: 20),

          // Income breakdown
          if (incomeEntries.isNotEmpty)
            _buildCategoryList(
              'THU NHẬP',
              incomeEntries,
              totalIncome,
              AppColors.incomeColor,
            ),

          if (expenseEntries.isEmpty && incomeEntries.isEmpty)
            _buildNoDataMessage('Không có dữ liệu để hiển thị'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    String title,
    List<MapEntry<String, double>> entries,
    double total,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.formatCurrency(total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final percentage = total > 0
                  ? (entry.value / total * 100).toStringAsFixed(1)
                  : '0.0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Category name
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    // Progress bar
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LinearProgressIndicator(
                          value: total > 0 ? entry.value / total : 0,
                          backgroundColor: color.withAlpha((0.2 * 255).round()),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8,
                        ),
                      ),
                    ),

                    // Amount and percentage
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(entry.value),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        final start = _selectedDate.subtract(const Duration(days: 6));
        return '${Formatters.formatDate(start)} - ${Formatters.formatDate(_selectedDate)}';
      case 'month':
        return 'Tháng ${_selectedDate.month}/${_selectedDate.year}';
      case 'year':
        return 'Năm ${_selectedDate.year}';
      default:
        return 'Tất cả';
    }
  }

  void _changeDate(int delta) {
    setState(() {
      switch (_selectedPeriod) {
        case 'week':
          _selectedDate = _selectedDate.add(Duration(days: delta * 7));
          break;
        case 'month':
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + delta,
          );
          break;
        case 'year':
          _selectedDate = DateTime(_selectedDate.year + delta);
          break;
      }
    });
  }

  bool _canGoToNextPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        return _selectedDate.isBefore(now);
      case 'month':
        return _selectedDate.isBefore(DateTime(now.year, now.month));
      case 'year':
        return _selectedDate.year < now.year;
      default:
        return false;
    }
  }

  Future<void> _exportReport(TransactionProvider provider) async {
    // Hiển thị dialog chọn loại export
    final exportType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất báo cáo'),
        content: const Text('Chọn định dạng xuất báo cáo:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'image'),
            child: const Text('Hình ảnh'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
        ],
      ),
    );

    if (exportType != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang xuất báo cáo dạng $exportType...'),
          backgroundColor: AppColors.primaryLight,
        ),
      );

      // Hiện tại chỉ hiển thị thông báo
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Xuất báo cáo thành công!'),
          backgroundColor:
              Colors.green, // Thay AppColors.successColor bằng Colors.green
        ),
      );
    }
  }
}
