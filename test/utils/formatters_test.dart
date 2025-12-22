import 'package:expense_tracker/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('formatCurrency formats correctly', () {
      expect(Formatters.formatCurrency(100000), '₫100,000');
      expect(Formatters.formatCurrency(1234567), '₫1,234,567');
      expect(Formatters.formatCurrency(500.5), '₫501');
      expect(Formatters.formatCurrency(0), '₫0');
    });

    test('formatDate formats correctly', () {
      final date = DateTime(2025, 12, 19);
      expect(Formatters.formatDate(date), '19/12/2025');
    });

    test('formatDateTime formats correctly', () {
      final date = DateTime(2025, 12, 19, 14, 30);
      expect(Formatters.formatDateTime(date), '19/12/2025 14:30');
    });

    test('formatTime formats correctly', () {
      final date = DateTime(2025, 12, 19, 14, 30);
      expect(Formatters.formatTime(date), '14:30');
    });

    test('formatPercentage formats correctly', () {
      expect(Formatters.formatPercentage(0.75), '75.0%');
      expect(Formatters.formatPercentage(0.1234), '12.3%');
      expect(Formatters.formatPercentage(1.0), '100.0%');
    });

    test('abbreviateNumber abbreviates correctly', () {
      expect(Formatters.abbreviateNumber(500), '500');
      expect(Formatters.abbreviateNumber(1500), '1.5K');
      expect(Formatters.abbreviateNumber(2500000), '2.5Tr');
      expect(Formatters.abbreviateNumber(3000000000), '3.0T');
    });
  });
}
