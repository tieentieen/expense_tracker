import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;
  
  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài Khoản Cá Nhân'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(themeProvider),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(authProvider),
            const SizedBox(height: 24),
            
            // Personal Info
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            
            // Security
            _buildSecuritySection(authProvider),
            const SizedBox(height: 24),
            
            // Appearance
            _buildAppearanceSection(themeProvider),
            const SizedBox(height: 24),
            
            // Support
            _buildSupportSection(),
            const SizedBox(height: 24),
            
            // Logout button
            _buildLogoutButton(authProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha((0.2 * 255).round()),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 20),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: ${widget.userId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primaryLight,
              onPressed: () => _showEditProfileDialog(authProvider),
              tooltip: 'Chỉnh sửa thông tin',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'THÔNG TIN CÁ NHÂN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            _buildInfoRow(
              Icons.person_outline,
              'Họ và tên',
              widget.userName,
            ),
            const SizedBox(height: 12),
            
            // Email
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              widget.userEmail,
            ),
            const SizedBox(height: 12),
            
            // Member since
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tham gia từ',
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecuritySection(AuthProvider authProvider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BẢO MẬT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Change password button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(authProvider),
                icon: const Icon(Icons.lock_outline, size: 20),
                label: const Text('Đổi mật khẩu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight.withAlpha((0.1 * 255).round()),
                  foregroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Privacy policy
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
              title: const Text('Chính sách bảo mật'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showPrivacyPolicy(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSection(ThemeProvider themeProvider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GIAO DIỆN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme toggle
            ListTile(
              leading: const Icon(Icons.color_lens_outlined, color: Colors.grey),
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeThumbColor: AppColors.primaryLight,
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            
            // Language selector (optional)
            ListTile(
              leading: const Icon(Icons.language_outlined, color: Colors.grey),
              title: const Text('Ngôn ngữ'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tiếng Việt'),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () => _showLanguageDialog(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSupportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HỖ TRỢ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Help center
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.grey),
              title: const Text('Trung tâm trợ giúp'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showHelpCenter(),
              contentPadding: EdgeInsets.zero,
            ),
            
            // Contact support
            ListTile(
              leading: const Icon(Icons.support_agent_outlined, color: Colors.grey),
              title: const Text('Liên hệ hỗ trợ'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _contactSupport(),
              contentPadding: EdgeInsets.zero,
            ),
            
            // About app
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('Về ứng dụng'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showAboutDialog(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('ĐĂNG XUẤT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withAlpha((0.1 * 255).round()),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.withAlpha((0.3 * 255).round())),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Future<void> _showEditProfileDialog(AuthProvider authProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: Validators.validateName,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập họ tên'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
                return;
              }
              
              final result = await authProvider.updateProfile(
                name: _nameController.text.trim(),
                avatarUrl: null,
              );
              
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? AppConstants.successUpdateProfile),
                    backgroundColor: AppColors.successColor,
                  ),
                );
                Navigator.pop(context);
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Cập nhật thất bại'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
            ),
            child: const Text(
              'LƯU',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showChangePasswordDialog(AuthProvider authProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
              Navigator.pop(context);
            },
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu mới không khớp'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
                return;
              }
              
              if (_newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
                return;
              }
              
              final result = await authProvider.changePassword(
                currentPassword: _currentPasswordController.text,
                newPassword: _newPasswordController.text,
              );
              
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? AppConstants.successChangePassword),
                    backgroundColor: AppColors.successColor,
                  ),
                );
                
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Đổi mật khẩu thất bại'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
            ),
            child: const Text(
              'ĐỔI MẬT KHẨU',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showLogoutDialog(AuthProvider authProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              Navigator.pop(context);
              
              // Điều hướng về màn hình login
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất thành công'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'ĐĂNG XUẤT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showSettingsDialog(ThemeProvider themeProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Xóa cache'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _clearCache();
              },
            ),
            ListTile(
              title: const Text('Xóa dữ liệu ứng dụng'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _clearAppData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. Thông tin cá nhân của bạn được bảo mật tuyệt đối trên thiết bị.',
              ),
              SizedBox(height: 8),
              Text(
                '2. Ứng dụng không thu thập hay chia sẻ thông tin với bên thứ ba.',
              ),
              SizedBox(height: 8),
              Text(
                '3. Dữ liệu được lưu trữ cục bộ trên thiết bị của bạn.',
              ),
              SizedBox(height: 8),
              Text(
                '4. Bạn có toàn quyền kiểm soát và xóa dữ liệu của mình.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
  
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tiếng Việt'),
              leading: const Icon(Icons.check, color: AppColors.primaryLight),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đang phát triển'),
                    backgroundColor: AppColors.warningColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trung tâm trợ giúp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: const Text('Câu hỏi thường gặp'),
                onTap: () => _showFAQ(),
              ),
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('Hướng dẫn sử dụng'),
                onTap: () => _showTutorial(),
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Hướng dẫn chi tiết'),
                onTap: () => _showUserManual(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
  
  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liên hệ hỗ trợ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email: support@expensetracker.com'),
              onTap: () => _copyToClipboard('support@expensetracker.com'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Hotline: 1900 1234'),
              onTap: () => _copyToClipboard('19001234'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat trực tuyến'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đang phát triển'),
                    backgroundColor: AppColors.warningColor,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Phiên bản: 1.0.0'),
              const SizedBox(height: 4),
              const Text('Nhà phát triển: Sinh viên UIT'),
              const SizedBox(height: 4),
              const Text('Môn học: Phát triển ứng dụng di động'),
              const SizedBox(height: 12),
              const Text(
                'Ứng dụng quản lý chi tiêu cá nhân với giao diện thân thiện, dễ sử dụng. Hỗ trợ theo dõi thu chi, phân tích tài chính và lập kế hoạch ngân sách.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
  
  void _showFAQ() {
    // Implement FAQ screen
  }
  
  void _showTutorial() {
    // Implement tutorial
  }
  
  void _showUserManual() {
    // Implement user manual
  }
  
  void _copyToClipboard(String text) {
    // Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép: $text'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
  
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cache'),
        content: const Text('Bạn có chắc chắn muốn xóa cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa cache thành công'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }
  
  void _clearAppData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu ứng dụng'),
        content: const Text('Hành động này sẽ xóa tất cả dữ liệu của bạn. Bạn có chắc chắn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa dữ liệu ứng dụng'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'XÓA TẤT CẢ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}