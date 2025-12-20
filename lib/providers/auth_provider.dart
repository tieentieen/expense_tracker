import 'package:flutter/material.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:expense_tracker/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper;

  // Trạng thái
  bool _isLoading = false;
  bool _isLoggedIn = false;
  int? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUserAvatar;
  DateTime? _currentUserCreatedAt;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserAvatar => _currentUserAvatar;
  DateTime? get currentUserCreatedAt => _currentUserCreatedAt;
  
  // Constructor chính (dùng trong app thật) + constructor test để inject mock
  AuthProvider({DatabaseHelper? dbHelper}) 
      : _dbHelper = dbHelper ?? DatabaseHelper() {
    _checkLoginStatus();
  }
  
  Future<void> _checkLoginStatus() async {
    // Trong ứng dụng thực tế, bạn sẽ lưu token/session
    // Ở đây để đơn giản, reset trạng thái mỗi lần khởi động
    _isLoggedIn = false;
    notifyListeners();
  }
  
  // Phương thức đăng ký
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Kiểm tra email đã tồn tại chưa
      final existingUser = await _dbHelper.authenticateUser(email, password);
      if (existingUser != null) {
        return {
          'success': false, 
          'message': AppConstants.errorEmailInUse
        };
      }
      
      // Đăng ký user mới
      final userId = await _dbHelper.registerUser(email, password, name);
      
      if (userId > 0) {
        _setUserData(
          userId: userId,
          name: name,
          email: email,
        );
        
        return {
          'success': true, 
          'userId': userId,
          'message': AppConstants.successRegister
        };
      } else {
        return {
          'success': false, 
          'message': 'Đăng ký thất bại'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '${AppConstants.errorUnknown}: $e'
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Phương thức đăng nhập
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userData = await _dbHelper.authenticateUser(email, password);
      
      if (userData != null) {
        final user = await _dbHelper.getUserById(userData['id']);
        
        if (user != null) {
          _setUserData(
            userId: user.id!,
            name: user.name,
            email: user.email,
            avatar: user.avatarUrl,
            createdAt: user.createdAt,
          );
          
          return {
            'success': true, 
            'userId': _currentUserId,
            'message': AppConstants.successLogin
          };
        } else {
          return {
            'success': false, 
            'message': AppConstants.errorUserNotFound
          };
        }
      } else {
        return {
          'success': false, 
          'message': AppConstants.errorWrongPassword
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '${AppConstants.errorUnknown}: $e'
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Phương thức đăng xuất
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserAvatar = null;
    _currentUserCreatedAt = null;
    notifyListeners();
  }
  
  // Cập nhật thông tin user
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    if (_currentUserId == null) {
      return {
        'success': false, 
        'message': 'Chưa đăng nhập'
      };
    }
    
    try {
      final result = await _dbHelper.updateUserProfile(
        _currentUserId!,
        name,
        avatarUrl,
      );
      
      if (result > 0) {
        _currentUserName = name;
        if (avatarUrl != null) {
          _currentUserAvatar = avatarUrl;
        }
        notifyListeners();
        
        return {
          'success': true, 
          'message': AppConstants.successUpdateProfile
        };
      }
      return {
        'success': false, 
        'message': 'Cập nhật thất bại'
      };
    } catch (e) {
      return {
        'success': false, 
        'message': '${AppConstants.errorUnknown}: $e'
      };
    }
  }
  
  // Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUserId == null || _currentUserEmail == null) {
      return {
        'success': false, 
        'message': 'Chưa đăng nhập'
      };
    }
    
    try {
      // Kiểm tra mật khẩu hiện tại
      final check = await _dbHelper.authenticateUser(
        _currentUserEmail!,
        currentPassword,
      );
      
      if (check == null) {
        return {
          'success': false, 
          'message': 'Mật khẩu hiện tại không đúng'
        };
      }
      
      // Cập nhật mật khẩu mới
      final result = await _dbHelper.changePassword(
        _currentUserId!,
        newPassword,
      );
      
      if (result > 0) {
        return {
          'success': true, 
          'message': AppConstants.successChangePassword
        };
      } else {
        return {
          'success': false, 
          'message': 'Đổi mật khẩu thất bại'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': '${AppConstants.errorUnknown}: $e'
      };
    }
  }
  
  // Helper method để set user data
  void _setUserData({
    required int userId,
    required String name,
    required String email,
    String? avatar,
    DateTime? createdAt,
  }) {
    _isLoggedIn = true;
    _currentUserId = userId;
    _currentUserName = name;
    _currentUserEmail = email;
    _currentUserAvatar = avatar;
    _currentUserCreatedAt = createdAt ?? DateTime.now();
    notifyListeners();
  }

  // Public helper for tests to set user data without going through DB
  void setUserDataForTest({
    required int userId,
    required String name,
    required String email,
    String? avatar,
    DateTime? createdAt,
  }) {
    _setUserData(
      userId: userId,
      name: name,
      email: email,
      avatar: avatar,
      createdAt: createdAt,
    );
  }
  
  // Clear user data (dùng khi logout hoặc xóa tài khoản)
  // ignore: unused_element
  void _clearUserData() {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserAvatar = null;
    _currentUserCreatedAt = null;
  }
}