import 'package:flutter/material.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPositive
                ? [
                    const Color(0xFF4CAF50).withAlpha((0.8 * 255).round()),
                    const Color(0xFF8BC34A).withAlpha((0.8 * 255).round()),
                  ]
                : [
                    const Color(0xFFF44336).withAlpha((0.8 * 255).round()),
                    const Color(0xFFFF5722).withAlpha((0.8 * 255).round()),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'SỐ DƯ HIỆN TẠI',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            
            // Balance (use FittedBox so it scales down in tight test constraints)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.formatCurrency(balance),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            
            // Status indicator
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isPositive ? 'Tăng' : 'Giảm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Income and Expense row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Income
                  _buildStatItem(
                    context,
                    'Thu nhập',
                    income,
                    AppColors.incomeColor,
                    Icons.arrow_upward,
                  ),

                  // Vertical divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withAlpha((0.3 * 255).round()),
                  ),

                  // Expense
                  _buildStatItem(
                    context,
                    'Chi tiêu',
                    expense,
                    AppColors.expenseColor,
                    Icons.arrow_downward,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title row scaled down in tight constraints
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Amount scaled down and ellipsized
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}