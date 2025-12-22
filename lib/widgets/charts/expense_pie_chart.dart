import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;
  final double radius;
  final bool showLegend;

  const ExpensePieChart({
    super.key,
    required this.data,
    this.radius = 80,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final chartData = _prepareChartData();

    return Column(
      children: [
        SizedBox(
          height: radius * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: chartData,
                  centerSpaceRadius: radius * 0.5,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
              // Total amount in center
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tổng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(chartData),
        ],
      ],
    );
  }

  List<PieChartSectionData> _prepareChartData() {
    final List<PieChartSectionData> sections = [];
    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final percentage = (entry.value / total) * 100;

      sections.add(
        PieChartSectionData(
          color: AppColors.getCategoryColor(i, 'expense'),
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(List<PieChartSectionData> sections) {
    final entries = data.entries.toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        final section = sections[index];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: section.color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: section.color.withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: section.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),

              // Category name
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),

              // Amount
              Text(
                Formatters.formatCurrency(entry.value),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: section.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 40,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Pie chart cho thu nhập
class IncomePieChart extends StatelessWidget {
  final Map<String, double> data;
  final double radius;
  final bool showLegend;

  const IncomePieChart({
    super.key,
    required this.data,
    this.radius = 80,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final chartData = _prepareChartData();

    return Column(
      children: [
        SizedBox(
          height: radius * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: chartData,
                  centerSpaceRadius: radius * 0.5,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
              // Total amount in center
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tổng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(chartData),
        ],
      ],
    );
  }

  List<PieChartSectionData> _prepareChartData() {
    final List<PieChartSectionData> sections = [];
    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final percentage = (entry.value / total) * 100;

      sections.add(
        PieChartSectionData(
          color: AppColors.getCategoryColor(i, 'income'),
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(List<PieChartSectionData> sections) {
    final entries = data.entries.toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        final section = sections[index];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: section.color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: section.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.formatCurrency(entry.value),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: section.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 40,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
