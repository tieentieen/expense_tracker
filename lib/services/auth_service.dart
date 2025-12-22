import 'package:expense_tracker/models/user.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _db = DatabaseHelper();

  User? _currentUser;
  User? get currentUser => _currentUser;

  /// Đăng ký người dùng mới
  Future<bool> register(String email, String password, String name) async {
    try {
      final id = await _db.registerUser(email, password, name);
      _currentUser = User(
        id: id,
        email: email,
        password: password, // Note: Trong thực tế, nên hash password
        name: name,
        createdAt: DateTime.now(),
      );
      await _saveUserId(id);
      return true;
    } catch (e) {
      // Xử lý lỗi (ví dụ: email trùng)
      return false;
    }
  }

  /// Đăng nhập
  Future<bool> login(String email, String password) async {
    final userMap = await _db.authenticateUser(email, password);
    if (userMap != null) {
      _currentUser = User.fromMap(userMap);
      await _saveUserId(_currentUser!.id!);
      return true;
    }
    return false;
  }

  /// Đăng xuất
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  /// Tải user hiện tại từ shared_preferences (gọi khi app start)
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    if (userId != null) {
      final user = await _db.getUserById(userId);
      if (user != null) {
        _currentUser = user;
      } else {
        // Nếu user không tồn tại, xóa prefs
        await prefs.remove('current_user_id');
      }
    }
  }

  /// Cập nhật profile (tên và avatar)
  Future<bool> updateProfile(String name, String? avatarUrl) async {
    if (_currentUser == null) return false;
    final rows =
        await _db.updateUserProfile(_currentUser!.id!, name, avatarUrl);
    if (rows > 0) {
      _currentUser = _currentUser!.copyWith(name: name, avatarUrl: avatarUrl);
      return true;
    }
    return false;
  }

  /// Đổi mật khẩu
  Future<bool> changePassword(String newPassword) async {
    if (_currentUser == null) return false;
    final rows = await _db.changePassword(_currentUser!.id!, newPassword);
    if (rows > 0) {
      _currentUser =
          _currentUser!.copyWith(password: newPassword); // Update local
      return true;
    }
    return false;
  }

  /// Lưu user ID vào shared_preferences
  Future<void> _saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', id);
  }
}
