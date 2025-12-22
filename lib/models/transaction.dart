import 'package:intl/intl.dart';

class Transaction {
  int? id;
  int userId;
  String title;
  double amount;
  DateTime date;
  int categoryId;
  String type; // 'income' hoặc 'expense'
  String? note;

  Transaction({
    this.id,
    required this.userId,
    required this.title,
    required double amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
  }) : amount = amount {
    // Enforce positive, non-zero amounts at construction time. Tests rely on
    // an assertion being thrown for zero/negative values.
    assert(this.amount > 0, 'amount must be greater than zero');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      // Store amount as int when there is no fractional part to match
      // existing test expectations and SQLite numeric behavior.
      'amount': (amount % 1 == 0) ? amount.toInt() : amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'type': type,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      // Accept numeric types from the database (int/double) and convert to
      // double for internal representation.
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.parse(map['amount'].toString()),
      date: DateTime.parse(map['date']),
      categoryId: map['category_id'],
      type: map['type'],
      note: map['note'],
    );
  }

  Transaction copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    DateTime? date,
    int? categoryId,
    String? type,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
  String get formattedAmount {
    // Use a neutral grouping format and prefix the currency symbol to match
    // test expectations (e.g. "₫100,000"). The 'vi_VN' locale places the
    // symbol after the amount and uses dots as group separators, so we
    // format manually using an en_US pattern and prefix the symbol.
    final s =
        NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0)
            .format(amount);
    return '₫$s';
  }

  String get formattedTime => DateFormat('HH:mm').format(date);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(date);

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount)';
  }
}
