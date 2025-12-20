import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final List<double> monthlyIncome;
  final List<double> monthlyExpense;
  final int year;
  final bool showLegend;
  IncomeExpenseBarChart({
    super.key,
    List<double>? monthlyData,
    this.monthlyIncome = const [],
    this.monthlyExpense = const [],
    this.year = 2024,
    this.showLegend = true,
  }) : assert(
          monthlyData == null || (monthlyIncome.isEmpty && monthlyExpense.isEmpty),
          'Chỉ sử dụng monthlyData hoặc monthlyIncome/monthlyExpense',
        );

  @override
  Widget build(BuildContext context) {
    final incomeData = monthlyIncome.isNotEmpty ? monthlyIncome : List.filled(12, 0.0);
    final expenseData = monthlyExpense.isNotEmpty ? monthlyExpense : List.filled(12, 0.0);
    
    if (_isEmpty(incomeData) && _isEmpty(expenseData)) {
      return _buildEmptyChart();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(incomeData, expenseData) * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = _getMonthName(groupIndex);
                    final value = Formatters.formatCurrency(rod.toY);
                    final type = rodIndex == 0 ? 'Thu' : 'Chi';
                    
                    return BarTooltipItem(
                      '$month\n$type: $value',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _getMonthAbbreviation(value.toInt()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox();
                      }
                      return Text(
                        Formatters.abbreviateNumber(value),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1000000, // 1 triệu
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withAlpha((0.1 * 255).round()),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
              ),
              barGroups: _createBarGroups(incomeData, expenseData),
            ),
          ),
        ),
        
        if (showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(List<double> income, List<double> expense) {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            toY: income[index],
            color: AppColors.incomeColor,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: expense[index],
            color: AppColors.expenseColor,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        showingTooltipIndicators: [0, 1],
      );
    });
  }

  double _getMaxValue(List<double> income, List<double> expense) {
    final maxIncome = income.isNotEmpty ? income.reduce((a, b) => a > b ? a : b) : 0;
    final maxExpense = expense.isNotEmpty ? expense.reduce((a, b) => a > b ? a : b) : 0;
    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.1;
  }

  bool _isEmpty(List<double> data) {
    return data.every((value) => value == 0);
  }

  String _getMonthName(int monthIndex) {
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[monthIndex];
  }

  String _getMonthAbbreviation(int monthIndex) {
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    return months[monthIndex];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Income legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.incomeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Thu nhập',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Expense legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.expenseColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Chi tiêu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Không có dữ liệu',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Thêm giao dịch để xem biểu đồ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bar chart đơn giản cho single dataset
class SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final String title;
  final int year;
  SimpleBarChart({
    super.key,
    required this.data,
    this.color = AppColors.primaryLight,
    this.title = 'Thống kê',
    this.year = 2024,
  });

  @override
  Widget build(BuildContext context) {
    if (_isEmpty(data)) {
      return _buildEmptyChart();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = _getMonthName(groupIndex);
                    final value = Formatters.formatCurrency(rod.toY);
                    
                    return BarTooltipItem(
                      '$month: $value',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _getMonthAbbreviation(value.toInt()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
              ),
              barGroups: _createBarGroups(data),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(List<double> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  bool _isEmpty(List<double> data) {
    return data.every((value) => value == 0);
  }

  String _getMonthName(int monthIndex) {
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[monthIndex];
  }

  String _getMonthAbbreviation(int monthIndex) {
    final months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
    return months[monthIndex];
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Không có dữ liệu',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}