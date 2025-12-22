import 'package:expense_tracker/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category model', () {
    test('should create Category instance correctly', () {
      final category = Category(
        id: 1,
        name: 'Ăn uống',
        type: 'expense',
        icon: '🍔',
        color: 0xFFFFB6B6,
        description: 'Chi phí ăn uống',
      );

      expect(category.id, 1);
      expect(category.name, 'Ăn uống');
      expect(category.type, 'expense');
      expect(category.icon, '🍔');
      expect(category.color, 0xFFFFB6B6);
      expect(category.description, 'Chi phí ăn uống');
    });

    test('toMap() should convert to correct map', () {
      final category = Category(
        id: 3,
        name: 'Mua sắm',
        type: 'expense',
        icon: '🛍️',
        color: 0xFF98D8AA,
      );

      final map = category.toMap();

      expect(map['id'], 3);
      expect(map['name'], 'Mua sắm');
      expect(map['type'], 'expense');
      expect(map['icon'], '🛍️');
      expect(map['color'], 0xFF98D8AA);
      expect(map['description'], null);
    });

    test('fromMap() should create Category from map', () {
      final map = {
        'id': 5,
        'name': 'Y tế',
        'type': 'expense',
        'icon': '🏥',
        'color': 0xFFFFD700,
        'description': 'Thuốc men',
      };

      final category = Category.fromMap(map);

      expect(category.id, 5);
      expect(category.name, 'Y tế');
      expect(category.type, 'expense');
    });
  });

  group('CategoryRepository', () {
    test('getExpenseCategories returns 7 categories', () {
      final expenses = CategoryRepository.getExpenseCategories();
      expect(expenses.length, 7);
      expect(expenses.first.name, 'Ăn uống');
    });

    test('getIncomeCategories returns 5 categories', () {
      final incomes = CategoryRepository.getIncomeCategories();
      expect(incomes.length, 5);
      expect(incomes.first.name, 'Lương');
    });

    test('getAllCategories combines expense and income', () {
      final all = CategoryRepository.getAllCategories();
      expect(all.length, 12);
    });

    test('getCategoryById finds correct category', () {
      final cat = CategoryRepository.getCategoryById(4);
      expect(cat.name, 'Giải trí');
    });

    test('getDefaultExpenseCategory returns first expense', () {
      final def = CategoryRepository.getDefaultExpenseCategory();
      expect(def.name, 'Ăn uống');
    });
  });
}
