/// Hardcoded strings cho QuizLab
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'QuizLab';

  // Auth
  static const String login         = 'Đăng nhập';
  static const String register      = 'Đăng ký';
  static const String logout        = 'Đăng xuất';
  static const String email         = 'Email';
  static const String password      = 'Mật khẩu';
  static const String fullName      = 'Họ và tên';
  static const String emailHint     = 'example@email.com';
  static const String passwordHint  = 'Tối thiểu 8 ký tự';
  static const String loginSuccess  = 'Đăng nhập thành công';
  static const String logoutSuccess = 'Đã đăng xuất';

  // Study Set
  static const String studySets     = 'Bộ học';
  static const String myStudySets   = 'Bộ học của tôi';
  static const String searchHint    = 'Tìm kiếm bộ học...';
  static const String cards         = 'thẻ';

  // Study / Flashcard
  static const String startStudy    = 'Bắt đầu học';
  static const String startQuiz     = 'Làm quiz';
  static const String known         = 'Biết';
  static const String unknown       = 'Chưa biết';
  static const String flipCard      = 'Nhấn để lật thẻ';

  // Quiz
  static const String submitQuiz    = 'Nộp bài';
  static const String quizResult    = 'Kết quả quiz';
  static const String correct       = 'Đúng';
  static const String incorrect     = 'Sai';
  static const String score         = 'Điểm';

  // Navigation
  static const String navStudySets  = 'Học';
  static const String navProgress   = 'Tiến độ';
  static const String navChat       = 'Chat';
  static const String navNotifications = 'Thông báo';
  static const String navProfile    = 'Hồ sơ';

  // Errors
  static const String errorNetwork  = 'Lỗi kết nối. Vui lòng thử lại.';
  static const String errorUnknown  = 'Đã có lỗi xảy ra.';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordTooShort = 'Mật khẩu tối thiểu 8 ký tự';
  static const String errorFieldRequired = 'Trường này không được để trống';

  // Empty states
  static const String emptyStudySets = 'Chưa có bộ học nào';
  static const String emptyNotifications = 'Không có thông báo';
  static const String emptyMessages = 'Chưa có tin nhắn nào';
}
