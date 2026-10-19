# QuizZone — Flutter App Implementation Plan
> **PRM393 – Mobile Application Development (Flutter)**  
> Group 2 · SE1941 · 5 thành viên · 5 tuần

---

## 1. Tổng quan dự án

**Tên ứng dụng:** QuizZone  
**Mô tả:** Ứng dụng học flashcard giả lập Quizlet — tạo bộ thẻ học, học theo chế độ lật thẻ, kiểm tra bằng quiz trắc nghiệm, theo dõi tiến độ học.  
**Backend:** Spring Boot REST API (repo riêng — `gr2_se1941_quizzone_be`). App gọi API qua Dio với JWT.  
**Platform:** Android (Release APK)

---

## 2. Tech Stack

| Công nghệ | Package | Mục đích |
|-----------|---------|---------|
| State Management | `provider: ^6.1.2` | ChangeNotifier + Consumer (giống SportZone) |
| HTTP Client | `dio: ^5.7.0` | REST API calls, JWT interceptor |
| JWT | `jwt_decoder: ^2.0.1` | Kiểm tra token expiry |
| Session | `shared_preferences: ^2.3.2` | Lưu accessToken sau login |
| Routing | `go_router: ^14.3.0` | Navigation |
| Charts | `fl_chart: ^0.69.0` | Progress Dashboard (bar chart, pie chart) |
| Images | `cached_network_image: ^3.4.1` | Load ảnh flashcard từ URL |
| Formatting | `intl: ^0.19.0` | Format ngày, số liệu |

**dev_dependencies:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.13
```

---

## 3. Kiến trúc: MVVM + Provider

```
View (Page/Widget)
  └── Consumer<XViewModel> / context.watch<XViewModel>()
        └── ViewModel (ChangeNotifier)
              └── ApiService (Dio HTTP calls)
                    └── REST API (Spring Boot Backend)
```

**Quy tắc bắt buộc:**
- View **không** chứa business logic — chỉ render UI và gọi ViewModel methods
- ViewModel **không** import Flutter widgets — chỉ import models và ApiService
- Mọi thay đổi state phải gọi `notifyListeners()` sau khi update
- `ApiService` là singleton, được inject qua constructor của ViewModel
- `ApiClient` (Dio singleton) gắn JWT interceptor ở tầng thấp nhất

---

## 4. Cấu trúc thư mục

```
lib/
├── core/
│   ├── api_client.dart       # Dio singleton + JWT interceptor
│   ├── app_colors.dart       # Toàn bộ màu sắc
│   ├── app_text_styles.dart  # Typography
│   ├── app_strings.dart      # Hardcoded strings
│   └── app_router.dart       # go_router configuration
│
├── models/                   # Pure Dart, serialize từ JSON
│   ├── user.dart
│   ├── study_set.dart
│   ├── flashcard.dart
│   ├── quiz_result.dart
│   ├── notification.dart
│   ├── message.dart
│   └── study_progress.dart
│
├── services/
│   └── api_service.dart      # Tất cả HTTP calls (thay thế DatabaseService)
│
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── study_set_viewmodel.dart
│   ├── study_viewmodel.dart
│   ├── notification_viewmodel.dart
│   ├── progress_viewmodel.dart
│   └── chat_viewmodel.dart
│
├── views/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── study_set/
│   │   ├── study_set_list_page.dart
│   │   └── study_set_detail_page.dart
│   ├── study/
│   │   ├── flashcard_study_page.dart
│   │   ├── quiz_page.dart
│   │   └── quiz_result_page.dart
│   ├── notification/
│   │   └── notification_page.dart
│   ├── progress/
│   │   └── progress_page.dart
│   ├── chat/
│   │   └── chat_page.dart
│   ├── profile/
│   │   └── profile_page.dart
│   ├── home_screen.dart
│   └── splash_screen.dart
│
├── widgets/                  # Reusable widgets
│   ├── flashcard_card.dart   # Flip animation card
│   ├── study_set_card.dart
│   └── quiz_option_tile.dart
│
└── main.dart                 # MultiProvider setup
```

---

## 5. 10 Chức năng PRM393 → Màn hình QuizZone

| # | Chức năng PRM393 | Màn hình QuizZone | API Endpoint |
|---|---|---|---|
| 1 | Database/API design | — (tài liệu Postman collection) | Thiết kế schema + API contract |
| 2 | Login screen | `LoginPage`, `RegisterPage`, `SplashScreen` | `POST /auth/login` |
| 3 | Product list | `StudySetListPage` (search, filter theo chủ đề) | `GET /api/study-sets` |
| 4 | Product detail | `StudySetDetailPage` + danh sách flashcard | `GET /api/study-sets/{id}` |
| 5 | Shopping cart | `FlashcardStudyPage` (lật thẻ biết/chưa biết) | `PUT /api/progress/{setId}` |
| 6 | Checkout | `QuizPage` (trắc nghiệm) + `QuizResultPage` | `POST /api/quiz-results` |
| 7 | Notifications | `NotificationPage` | `GET /api/notifications` |
| 8 | **Progress Dashboard** | `ProgressPage` (fl_chart: bar + pie chart) | `GET /api/progress/summary` |
| 9 | Chat | `ChatPage` (bình luận theo study set) | `GET/POST /api/messages/{setId}` |
| 10 | State management | `MultiProvider` ở `main.dart`, toàn app | — |

---

## 6. Phân công 5 người

### Bảng phân công

| Người | Task | Files phụ trách | Chức năng PRM393 |
|---|---|---|---|
| **P1** — Core Lead | Project setup, core/, models/, `api_client.dart`, `main.dart` MultiProvider, Postman collection, Release APK | `core/`, `models/`, `main.dart`, `pubspec.yaml` | #1, #10 |
| **P2** — Auth & Profile | `AuthViewModel`, Login, Register, Splash, Profile, session handling | `views/auth/`, `views/profile/`, `viewmodels/auth_viewmodel.dart` | #2 |
| **P3** — Study Sets | `StudySetViewModel`, StudySetList (search/filter), StudySetDetail, `StudySetCard` widget | `views/study_set/`, `viewmodels/study_set_viewmodel.dart`, `widgets/study_set_card.dart` | #3, #4 |
| **P4** — Study Modes | `StudyViewModel`, FlashcardStudy (flip animation), QuizPage (trắc nghiệm), QuizResult | `views/study/`, `viewmodels/study_viewmodel.dart`, `widgets/flashcard_card.dart`, `widgets/quiz_option_tile.dart` | #5, #6 |
| **P5** — Dashboard & Chat | `NotificationViewModel`, NotificationPage, `ProgressViewModel`, ProgressPage (fl_chart), ChatPage, `ChatViewModel` | `views/notification/`, `views/progress/`, `views/chat/`, viewmodels tương ứng | #7, #8, #9 |

### Test phân công

| Người | Test | File |
|---|---|---|
| **P1** | Unit Test: `StudyViewModel` — tính điểm quiz, xác nhận đúng/sai | `test/viewmodels/study_viewmodel_test.dart` |
| **P3** | Widget Test: `StudySetCard` — verify render tên, số lượng thẻ | `test/widgets/study_set_card_test.dart` |

---

## 7. `api_client.dart` — Xương sống kết nối API

```dart
// lib/core/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator → localhost
  // Production: thay bằng URL deploy thật

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Dio get instance {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token hết hạn → logout
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('access_token');
          // Điều hướng về login (xử lý ở AuthViewModel)
        }
        return handler.next(error);
      },
    ));
    return _dio;
  }
}
```

---

## 8. `main.dart` MultiProvider Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => StudySetViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => StudyViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => ProgressViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(apiService)),
      ],
      child: const QuizZoneApp(),
    ),
  );
}
```

---

## 9. Naming Conventions

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| Files | `snake_case.dart` | `study_set_detail_page.dart` |
| Classes | `PascalCase` | `StudySetViewModel` |
| Methods | `camelCase` | `loadStudySets()`, `submitQuiz()` |
| Variables | `camelCase` | `currentStudySet`, `isLoading` |
| Constants | `kCamelCase` | `kPrimaryColor` |
| Private | `_prefix` | `_studySets`, `_isLoading` |
| Pages | `XxxPage` suffix | `StudySetDetailPage` |
| ViewModels | `XxxViewModel` suffix | `StudyViewModel` |
| Models | Tên thực thể | `StudySet`, `Flashcard`, `User` |

---

## 10. Git Workflow

### Branches
```
main          ← stable, chỉ merge khi feature done
feat/<ten>    ← mỗi feature một branch
fix/<ten>     ← bug fix
chore/<ten>   ← config, setup
test/<ten>    ← test files
```

### Quy trình mỗi feature
```bash
git checkout main && git pull
git checkout -b feat/ten_chuc_nang
# ... implement ...
git checkout main
git merge --no-ff feat/ten_chuc_nang -m "Merge feat/ten_chuc_nang"
git branch -d feat/ten_chuc_nang
```

### Quy tắc commit
- **Chỉ commit khi được yêu cầu rõ ràng** — không tự ý commit sau khi implement xong
- Commit message format: `feat(auth): add login page with JWT`, `fix(quiz): correct score calculation`
- **Không commit:** `build/`, `.dart_tool/`, `.kiro/`, `*.apk`, `*.aab`

---

## 11. Timeline 5 tuần

| Tuần | P1 (Core) | P2 (Auth) | P3 (Study Sets) | P4 (Study Modes) | P5 (Dashboard & Chat) |
|---|---|---|---|---|---|
| **1** | Setup project, core/, models/, pubspec, api_client | Đọc spec, setup branch | Đọc spec, setup branch | Đọc spec, setup branch | Đọc spec, setup branch |
| **2** | ApiService skeleton, app_router | Login, Register, Splash (mock auth) | StudySetList + Detail (mock data) | FlashcardStudy page (local flip logic) | NotificationPage (mock data) |
| **3** | Kết nối BE auth endpoints, integration test | Profile page, swap sang real auth API | Swap mock → real API, search/filter | QuizPage + QuizResultPage | ProgressPage (fl_chart) |
| **4** | Hỗ trợ fix integration issues | — | — | — | ChatPage, swap notifications sang real API |
| **5** | Release APK, Unit Test, flutter analyze | Widget polish, bug fix | Widget polish, Widget Test | Bug fix | Bug fix, final integration |

---

## 12. Non-Functional Requirements

- **Performance:** API response < 3 giây; UI 60fps khi scroll danh sách
- **Security:** Token lưu SharedPreferences, KHÔNG log token ra console; xử lý 401 tự động logout
- **Reliability:** Xử lý lỗi mạng (DioException) ở mọi API call, hiển thị SnackBar rõ ràng
- **UX:** Loading indicator khi gọi API; empty state có hướng dẫn; form có validation

---

## 13. Definition of Done (mỗi feature)

- [ ] ViewModel có đầy đủ methods cần thiết
- [ ] ApiService có method tương ứng gọi đúng endpoint
- [ ] UI render đúng, không crash trên emulator
- [ ] State cập nhật qua `notifyListeners()`, UI tự rebuild
- [ ] Lỗi mạng được catch và hiển thị thông báo rõ ràng
- [ ] Code có comment giải thích logic chính
- [ ] Chạy được trên emulator không crash

---

## 14. Deployment

```bash
# Build Release APK
flutter build apk --release

# Kết quả: build/app/outputs/flutter-apk/app-release.apk
# Cần chụp màn hình / quay video chứng minh chạy Release Mode
```

---

*Tài liệu này là tham chiếu triển khai. Cập nhật khi có thay đổi về scope hoặc phân công.*
