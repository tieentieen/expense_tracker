import 'package:expense_tracker/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User model', () {
    test('should create User instance', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        password: '123456',
        name: 'Nguyễn Văn A',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(user.email, 'test@example.com');
      expect(user.name, 'Nguyễn Văn A');
    });

    test('toMap() and fromMap() work correctly', () {
      final user = User(
        id: 2,
        email: 'user2@gmail.com',
        password: 'abc123',
        name: 'Trần Thị B',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: DateTime(2025, 6, 15),
      );

      final map = user.toMap();
      expect(map['email'], 'user2@gmail.com');
      expect(map['avatar_url'], 'https://example.com/avatar.jpg');

      final fromMap = User.fromMap(map);
      expect(fromMap.name, 'Trần Thị B');
      expect(fromMap.formattedCreatedAt, '15/06/2025');
    });

    test('copyWith creates new instance with updated fields', () {
      final user = User(
        id: 3,
        email: 'old@email.com',
        password: 'oldpass',
        name: 'Old Name',
        createdAt: DateTime(2024),
      );

      final updated = user.copyWith(
        email: 'new@email.com',
        name: 'New Name',
      );

      expect(updated.email, 'new@email.com');
      expect(updated.name, 'New Name');
      expect(updated.password, 'oldpass'); 
    });
  });
}