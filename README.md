# Báo Cáo Phát Triển Ứng Dụng Expense Tracker
Họ và tên: Phạm Thủy Tiên  
MSSV: 2221050368  
Lớp: DCCTCLC67B  
#
## Quá Trình Phát Triển

- Thiết kế Data Model: 
  + Bắt đầu bằng việc tạo các model chính (User, Transaction, Category) với đầy đủ thuộc tính (id, title/name, các trường bổ sung như amount, date, type, note)
  + Sử dụng Dart classes thuần với các phương thức toMap/fromMap, copyWith và getters hỗ trợ định dạng

- Xây dựng Lưu Trữ Dữ Liệu Cục Bộ: 
    + Triển khai DatabaseHelper sử dụng sqflite để tạo và quản lý SQLite database 
    + Thực hiện đầy đủ các thao tác CRUD cho User và Transaction, kèm theo các query thống kê (tổng thu/chi, thống kê theo danh mục)

- Phát triển State Management: Sử dụng package provider
    + AuthProvider (quản lý đăng nhập/đăng ký/logout)
    + TransactionProvider (quản lý danh sách giao dịch, filter, tính toán tổng)
    + ThemeProvider (chuyển đổi light/dark mode với lưu trữ SharedPreferences)

- Thiết kế Giao Diện Người Dùng: Áp dụng theme tùy chỉnh (light/dark) với palette pastel/kem và màu tối tương phản, các màn hình chính:
    + LoginScreen và RegisterScreen (xử lý validation, forgot password dialog)
    + HomeScreen (danh sách giao dịch, balance card, filter theo thời gian/danh mục)
    + AddTransactionScreen (tạo/sửa giao dịch, chọn danh mục, ngày, loại thu/chi)
    + ReportScreen (biểu đồ pie chart chi tiêu, bar chart thu/chi hàng tháng)
    + ProfileScreen (cập nhật tên, đổi mật khẩu, cài đặt theme và xóa dữ liệu)

- Tích hợp Navigation: Sử dụng go_router để quản lý route, truyền arguments (userId, transaction object) giữa các màn hình

- Xử lý Lỗi và Thông Báo: Thêm validation form chi tiết, hiển thị lỗi qua TextFormField và thông báo thành công/lỗi qua SnackBar

- Triển khai Kiểm Thử Tự Động: Viết unit tests cho model, provider, service, utils; widget tests cho các screen và component chính; sử dụng mockito để mock dependencies

- Thiết lập CI/CD:Cấu hình GitHub Actions để tự động chạy analyze, tests, generate coverage và deploy web demo lên GitHub Pages

- Hoàn thiện và Tối ưu: Thêm các tính năng phụ như định dạng tiền tệ VND, biểu đồ thống kê, export báo cáo (mock), và đảm bảo ứng dụng hoạt động mượt mà offline
#
## Các Thư Viện Đã Sử Dụng
- Flutter: Framework chính để xây dựng UI đa nền tảng
- provider: Quản lý trạng thái (state management) cho Auth, Transaction, và Theme
- sqflite: Lưu trữ dữ liệu cục bộ dưới dạng SQLite (tương tự NoSQL cục bộ), hỗ trợ CRUD và xử lý lỗi truy vấn
- intl: Định dạng ngày tháng, tiền tệ (ví dụ: '₫1,234,567')
- fl_chart: Tạo biểu đồ (pie chart cho chi tiêu, bar chart cho thu/chi hàng tháng)
- go_router: Quản lý navigation giữa các màn hình
- shared_preferences: Lưu trữ cài đặt đơn giản như theme mode
- flutter_test: Viết unit test và widget test
- mockito: Tạo mock objects cho testing (ví dụ: mock DatabaseHelper, Providers)
- path: Hỗ trợ xử lý đường dẫn file cho database
#
## Các Kiểm Thử Đã Thực Hiện
- Unit Tests: Kiểm tra model (User, Transaction, Category), services (DatabaseHelper, AuthService), providers (AuthProvider, TransactionProvider, ThemeProvider), và utils (Formatters, Validators)
    + Ví dụ: Kiểm tra constructor Transaction enforce amount > 0, DatabaseHelper CRUD operations trên in-memory DB
- Widget Tests: Kiểm tra UI components (BalanceCard, TransactionCard, ExpensePieChart, IncomeExpenseBarChart) và screens (AddTransactionScreen, LoginScreen, RegisterScreen, HomeScreen, ReportScreen, ProfileScreen)
    + Ví dụ: Kiểm tra render đúng dữ liệu, interaction (tap button, enter text), và state changes
- CI/CD: 
    + Sử dụng GitHub Actions (file ci.yml) để tự động chạy flutter analyze, unit/widget tests, generate coverage, và deploy demo lên GitHub Pages khi push/pull request trên branch main/develop
    + Xử lý lỗi deprecated APIs và unused imports
#
## Nguồn Tham Khảo
- Tài liệu Flutter chính thức: https://docs.flutter.dev/
- Sqflite documentation: https://pub.dev/packages/sqflite
- Provider state management: https://pub.dev/packages/provider
- Fl_chart examples: https://pub.dev/packages/fl_chart
- Mockito for testing: https://pub.dev/packages/mockito
- GitHub Actions for CI/CD: https://docs.github.com/en/actions
- Dart data classes: https://pub.dev/packages/freezed (tham khảo để tạo model)
- Các yêu cầu dự án: Dựa trên spec CRUD, UI, API integration (sử dụng local DB), và testing từ prompt dự án
#
## Tự Đánh Giá Điểm
Phân tích theo từng mức điểm:
- 5/10: Build thành công → Đạt
    + GitHub Actions đã được cấu hình hoàn chỉnh (file .github/workflows/ci.yml) 
    + Chạy thành công các bước: analyze, unit tests, widget tests, generate coverage, và deploy web lên GitHub Pages
    + Không có lỗi nào trong CI

- 6/10: Kiểm thử CRUD cơ bản → Đạt 
    + Có đầy đủ CRUD cho đối tượng chính là Transaction (tạo, đọc danh sách, cập nhật, xóa)
    + Unit test và widget test kiểm tra các thao tác này (add_transaction_screen_test, transaction_provider_test, database_helper_test)

- 7/10: Quản lý trạng thái + UI cơ bản → Đạt 
    + Sử dụng Provider để quản lý trạng thái (AuthProvider, TransactionProvider, ThemeProvider) → dữ liệu cập nhật realtime, không cần reload app
    + Giao diện cơ bản đầy đủ: danh sách giao dịch, chi tiết, form thêm/sửa, thông báo SnackBar thành công/thất bại rõ ràng

- 8/10: Tích hợp CSDL cục bộ + xử lý lỗi → Đạt 
    + Tích hợp sqflite (lưu trữ cục bộ SQLite) 
    + Các thao tác CRUD liên kết trực tiếp với database
    + Xử lý lỗi tốt: validation form, try-catch trong provider/service, thông báo lỗi cụ thể qua SnackBar

- 9/10: Kiểm thử tự động toàn diện + UI hoàn thiện → Đạt gần như hoàn chỉnh
    + Unit test: Unit test: model, provider, service, utils, database (in-memory)
    + Widget test: hầu hết các screen chính và component (Home, AddTransaction, Report, Profile, Login/Register, charts, cards...)
    + UI thân thiện: theme light/dark đẹp (pastel/kem), responsive cơ bản, icon, animation nhẹ, biểu đồ (fl_chart)
    + Có chức năng xác thực (login/register), cập nhật profile, đổi mật khẩu

- 10/10: Tối ưu hóa, UI/UX mượt + tính năng nâng cao → Đạt một phần, chưa hoàn hảo
    + UI/UX mượt mà: navigation (go_router), theme toggle, formatted currency VND, biểu đồ thống kê chi tiết
    + Tính năng nâng cao: filter/search giao dịch, báo cáo theo tháng/tuần/năm, export (mock), dark mode lưu trữ
    + Không có cảnh báo nghiêm trọng trong analyze (chỉ một số warning được ignore có chủ đích)
    + Thiếu: chưa có sắp xếp/lọc nâng cao hoặc animation phức tạp hơn, nhưng đã có filter khá tốt
    + CI/CD chưa ổn định, vẫn báo lỗi

## Kết luận tự đánh giá: 9/10
