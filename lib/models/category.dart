class Category {
  final int id;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;
  final int color;
  final String? description;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'description': description,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
      description: map['description'],
    );
  }
}

class CategoryRepository {
  static List<Category> getExpenseCategories() {
    return [
      Category(
        id: 1,
        name: 'Ăn uống',
        type: 'expense',
        icon: '🍔',
        color: 0xFFFFB6B6,
        description: 'Chi phí ăn uống hàng ngày',
      ),
      Category(
        id: 2,
        name: 'Di chuyển',
        type: 'expense',
        icon: '🚗',
        color: 0xFFA7C5EB,
        description: 'Xăng xe, taxi, phương tiện công cộng',
      ),
      Category(
        id: 3,
        name: 'Mua sắm',
        type: 'expense',
        icon: '🛍️',
        color: 0xFF98D8AA,
        description: 'Mua sắm quần áo, đồ dùng',
      ),
      Category(
        id: 4,
        name: 'Giải trí',
        type: 'expense',
        icon: '🎬',
        color: 0xFFDDA0DD,
        description: 'Xem phim, cafe, du lịch',
      ),
      Category(
        id: 5,
        name: 'Y tế',
        type: 'expense',
        icon: '🏥',
        color: 0xFFFFD700,
        description: 'Khám chữa bệnh, thuốc men',
      ),
      Category(
        id: 6,
        name: 'Hóa đơn',
        type: 'expense',
        icon: '📱',
        color: 0xFF87CEEB,
        description: 'Điện, nước, internet, điện thoại',
      ),
      Category(
        id: 7,
        name: 'Khác',
        type: 'expense',
        icon: '📦',
        color: 0xFFC0C0C0,
        description: 'Các khoản chi khác',
      ),
    ];
  }

  static List<Category> getIncomeCategories() {
    return [
      Category(
        id: 8,
        name: 'Lương',
        type: 'income',
        icon: '💰',
        color: 0xFF4CAF50,
        description: 'Lương chính thức hàng tháng',
      ),
      Category(
        id: 9,
        name: 'Freelance',
        type: 'income',
        icon: '💼',
        color: 0xFF2196F3,
        description: 'Thu nhập từ công việc tự do',
      ),
      Category(
        id: 10,
        name: 'Đầu tư',
        type: 'income',
        icon: '📈',
        color: 0xFF9C27B0,
        description: 'Lợi nhuận từ đầu tư',
      ),
      Category(
        id: 11,
        name: 'Quà tặng',
        type: 'income',
        icon: '🎁',
        color: 0xFFFF9800,
        description: 'Tiền quà tặng, mừng',
      ),
      Category(
        id: 12,
        name: 'Khác',
        type: 'income',
        icon: '📥',
        color: 0xFF795548,
        description: 'Các khoản thu khác',
      ),
    ];
  }

  static List<Category> getAllCategories() {
    return [...getExpenseCategories(), ...getIncomeCategories()];
  }

  static Category getCategoryById(int id) {
    return getAllCategories().firstWhere((cat) => cat.id == id);
  }

  static List<Category> getCategoriesByType(String type) {
    return getAllCategories().where((cat) => cat.type == type).toList();
  }

  static Category getDefaultExpenseCategory() {
    return getExpenseCategories().first;
  }

  static Category getDefaultIncomeCategory() {
    return getIncomeCategories().first;
  }
}