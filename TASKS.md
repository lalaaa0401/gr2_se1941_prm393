# QuizZone – Implementation Task Plan
> Group 2 · SE1941 · PRM393  
> 5 thành viên · 5 tuần

---

## Dependency Map (đọc trước khi bắt tay)

```
P1-01 (pubspec + flutter create)
  └── P1-02 (core/ + api_client)
        └── P1-03 (models)
              └── P1-04 (ApiService skeleton)   ← tất cả ViewModel phụ thuộc cái này
                    ├── P2-01 (AuthViewModel)
                    ├── P3-01 (StudySetViewModel)
                    ├── P4-01 (StudyViewModel)
                    └── P5-01 (NotificationViewModel / ProgressViewModel / ChatViewModel)
  └── P1-05 (app_router)
        └── P1-06 (main.dart MultiProvider)     ← cần có đủ ViewModel mới hoàn chỉnh
```

**Critical path:** P1-01 → P1-02 → P1-03 → P1-04 → tất cả ViewModel → tất cả View

---

## TUẦN 1 — Project Setup & Foundation

### P1 — anhlphe180185

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T1-P1-01** | Khởi tạo Flutter project, cấu hình `pubspec.yaml` với đầy đủ dependencies | `chore/project-setup` | `pubspec.yaml` có provider, dio, jwt_decoder, shared_preferences, go_router, fl_chart, cached_network_image, intl, mockito, build_runner | `flutter pub get` không lỗi |
| **T1-P1-02** | Tạo `lib/core/`: `app_colors.dart`, `app_text_styles.dart`, `app_strings.dart` | `chore/project-setup` | 3 file core constants, toàn bộ màu/typography từ ui-conventions | Import được vào bất kỳ file nào |
| **T1-P1-03** | Tạo `lib/core/api_client.dart` — Dio singleton + JWT interceptor | `chore/project-setup` | `ApiClient.instance` trả về Dio đã gắn interceptor auto-attach Bearer token | Gọi được API với token |
| **T1-P1-04** | Tạo toàn bộ `lib/models/`: `user.dart`, `study_set.dart`, `flashcard.dart`, `quiz_result.dart`, `notification.dart`, `message.dart`, `study_progress.dart` | `feat/models` | 7 model classes với `fromJson` / `toJson` | `flutter analyze` 0 error |
| **T1-P1-05** | Tạo `lib/core/app_router.dart` — go_router với tất cả routes | `chore/project-setup` | Routes đầy đủ cho mọi page (dùng placeholder page tạm) | Navigation giữa các page không crash |
| **T1-P1-06** | Tạo `lib/services/api_service.dart` — skeleton tất cả methods (body để trống hoặc throw UnimplementedError) | `feat/api-service` | Tất cả method signatures: `login`, `getStudySets`, `getStudySetDetail`, `updateProgress`, `submitQuiz`, `getNotifications`, `getProgressSummary`, `getMessages`, `sendMessage` | Compile được |

### P2 — dangpdhhe190525
| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T1-P2-01** | Đọc spec, setup branch, tạo stub files | `feat/auth` | `auth_viewmodel.dart`, `login_page.dart`, `register_page.dart`, `splash_screen.dart`, `profile_page.dart` (file trống có class declaration) | Files tồn tại, compile được |

### P3 — ductdhe186732
| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T1-P3-01** | Đọc spec, setup branch, tạo stub files | `feat/study-set` | `study_set_viewmodel.dart`, `study_set_list_page.dart`, `study_set_detail_page.dart`, `study_set_card.dart` (stubs) | Files tồn tại, compile được |

### P4 — taiknhe186063
| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T1-P4-01** | Đọc spec, setup branch, tạo stub files | `feat/study-modes` | `study_viewmodel.dart`, `flashcard_study_page.dart`, `quiz_page.dart`, `quiz_result_page.dart`, `flashcard_card.dart`, `quiz_option_tile.dart` (stubs) | Files tồn tại, compile được |

### P5 — tuantahe176408
| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T1-P5-01** | Đọc spec, setup branch, tạo stub files | `feat/dashboard-chat` | `notification_viewmodel.dart`, `notification_page.dart`, `progress_viewmodel.dart`, `progress_page.dart`, `chat_viewmodel.dart`, `chat_page.dart` (stubs) | Files tồn tại, compile được |

---

## TUẦN 2 — Core Features (Mock Data)

> **Tiền đề:** T1-P1-01 → T1-P1-06 hoàn thành trước khi P2–P5 implement ViewModel

### P1 — anhlphe180185

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T2-P1-01** | Implement `HomeScreen` với BottomNavigationBar 5 tabs | `feat/core-setup` | `home_screen.dart` render đúng 5 tabs, navigate giữa các page | Không crash, tab switch hoạt động |
| **T2-P1-02** | Hoàn thiện `main.dart` MultiProvider (sau khi có đủ ViewModel stub) | `feat/core-setup` | `MultiProvider` với 6 provider: Auth, StudySet, Study, Notification, Progress, Chat | `flutter run` khởi động được |

### P2 — dangpdhhe190525

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T2-P2-01** | Implement `AuthViewModel` với mock auth (hardcode token/user) | `feat/auth` | `login()`, `register()`, `logout()`, `checkSession()` với mock data | Unit có thể gọi `login()` mà không crash |
| **T2-P2-02** | Implement `LoginPage` UI + form validation | `feat/auth` | Form email/password, validate, gọi `authViewModel.login()`, điều hướng về Home | UI render đúng, validate hoạt động |
| **T2-P2-03** | Implement `RegisterPage` UI + form validation | `feat/auth` | Form đăng ký, validate, gọi `authViewModel.register()` | UI render đúng |
| **T2-P2-04** | Implement `SplashScreen` — check session → route | `feat/auth` | Check `access_token` → Home hoặc Login | Tự điều hướng đúng |

### P3 — ductdhe186732

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T2-P3-01** | Implement `StudySetViewModel` với mock data (List hardcode) | `feat/study-set` | `loadStudySets()`, `searchStudySets()`, `filterByTopic()` với mock | UI nhận được data |
| **T2-P3-02** | Implement `StudySetCard` widget | `feat/study-set` | Card hiển thị tên, số thẻ, chủ đề — theo ui-conventions (border, no shadow) | Render đúng với mock data |
| **T2-P3-03** | Implement `StudySetListPage` — list + search + filter | `feat/study-set` | GridView/ListView các `StudySetCard`, search realtime, filter theo topic | Render list, search hoạt động |
| **T2-P3-04** | Implement `StudySetDetailPage` — thông tin + danh sách flashcard | `feat/study-set` | Hiển thị study set info + list flashcard (term/definition), nút bắt đầu học | Render đúng với mock data |

### P4 — taiknhe186063

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T2-P4-01** | Implement `FlashcardCard` widget với flip animation | `feat/study-modes` | AnimationController flip front↔back, tap để lật, hiển thị term/definition | Animation mượt, không jank |
| **T2-P4-02** | Implement `FlashcardStudyPage` — lật thẻ + biết/chưa biết | `feat/study-modes` | PageView các `FlashcardCard`, 2 nút Biết/Chưa biết, đếm tiến độ | Hoạt động với mock flashcards |

### P5 — tuantahe176408

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T2-P5-01** | Implement `NotificationViewModel` + `NotificationPage` với mock data | `feat/dashboard-chat` | List notifications mock, tap → đánh dấu đã đọc, badge count | Badge cập nhật khi tap |

---

## TUẦN 3 — Real API Integration

> **Tiền đề:** Backend API đã sẵn sàng ở `http://10.0.2.2:8080`

### P1 — anhlphe180185

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T3-P1-01** | Implement `ApiService` — endpoint auth: `login()`, `register()` | `feat/api-service` | Gọi `POST /auth/login`, xử lý response, lưu token | Login với tài khoản thật, nhận JWT |
| **T3-P1-02** | Implement `ApiService` — endpoint study set: `getStudySets()`, `getStudySetDetail()` | `feat/api-service` | `GET /api/study-sets`, `GET /api/study-sets/{id}` | Nhận data thật từ BE |
| **T3-P1-03** | Implement `ApiService` — endpoint study: `updateProgress()`, `submitQuiz()` | `feat/api-service` | `PUT /api/progress/{setId}`, `POST /api/quiz-results` | POST thành công, nhận response |
| **T3-P1-04** | Implement `ApiService` — endpoint dashboard & chat | `feat/api-service` | `GET /api/notifications`, `GET /api/progress/summary`, `GET/POST /api/messages/{setId}` | Nhận data thật |

### P2 — dangpdhhe190525

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T3-P2-01** | Swap `AuthViewModel` mock → real API | `feat/auth` | `login()` gọi `apiService.login()`, lưu JWT, xử lý lỗi 401 | Đăng nhập thật với BE |
| **T3-P2-02** | Implement `ProfilePage` | `feat/auth` | Hiển thị user info từ `AuthViewModel`, nút logout | Logout xóa token, về LoginPage |

### P3 — ductdhe186732

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T3-P3-01** | Swap `StudySetViewModel` mock → real API | `feat/study-set` | `loadStudySets()` gọi `apiService.getStudySets()`, xử lý loading/error state | Data thật hiển thị trên UI |
| **T3-P3-02** | Hoàn thiện search + filter với real API (query params hoặc client-side filter) | `feat/study-set` | Search và filter hoạt động với data thật | Filter trả kết quả đúng |

### P4 — taiknhe186063

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T3-P4-01** | Implement `StudyViewModel` — track flashcard session | `feat/study-modes` | `markKnown()`, `markUnknown()`, `finishSession()`, gọi `apiService.updateProgress()` | Progress được cập nhật lên API |
| **T3-P4-02** | Implement `QuizPage` — trắc nghiệm 4 lựa chọn | `feat/study-modes` | Generate câu hỏi từ flashcards, hiển thị `QuizOptionTile`, đánh dấu đúng/sai | Quiz chạy qua hết câu hỏi |
| **T3-P4-03** | Implement `QuizResultPage` — điểm số + tổng kết | `feat/study-modes` | Hiển thị điểm, số câu đúng/sai, nút học lại hoặc về Home; gọi `apiService.submitQuiz()` | Submit quiz thành công lên API |

### P5 — tuantahe176408

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T3-P5-01** | Implement `ProgressViewModel` + `ProgressPage` với fl_chart | `feat/dashboard-chat` | Bar chart số thẻ học theo ngày, pie chart biết/chưa biết; data từ `apiService.getProgressSummary()` | Chart render đúng với real data |

---

## TUẦN 4 — Polish & Full Integration

### P1 — anhlphe180185

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T4-P1-01** | Hỗ trợ fix integration issues (401 handling, token refresh flow) | _(theo issue)_ | Auto-logout khi 401 trên bất kỳ API call nào | 401 → về LoginPage, không crash |
| **T4-P1-02** | Thêm global error handling — DioException → SnackBar | `feat/api-service` | Mọi API error hiển thị SnackBar thông báo rõ ràng | Mất mạng → SnackBar, không crash |

### P5 — tuantahe176408

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T4-P5-01** | Implement `ChatViewModel` + `ChatPage` | `feat/dashboard-chat` | Load messages (`GET /api/messages/{setId}`), gửi tin (`POST`), optimistic update | Tin nhắn gửi/nhận được |
| **T4-P5-02** | Swap `NotificationViewModel` mock → real API | `feat/dashboard-chat` | `GET /api/notifications`, badge count real-time trong app | Badge đúng với data thật |

### P2, P3, P4 — Polish

| ID | Người | Task |
|----|-------|------|
| **T4-P2-01** | P2 | UI polish LoginPage, RegisterPage — loading state, error messages |
| **T4-P3-01** | P3 | Loading skeleton khi fetch study sets; empty state khi không có kết quả |
| **T4-P4-01** | P4 | Polish FlashcardStudy — progress bar, số thẻ còn lại; polish QuizPage |

---

## TUẦN 5 — Testing, QA & Release

### P1 — anhlphe180185

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T5-P1-01** | Viết Unit Test `StudyViewModel` — test `calculateScore()`, `markKnown()`, `markUnknown()` | `test/study-viewmodel` | `test/viewmodels/study_viewmodel_test.dart` với ≥ 3 test cases | `flutter test` PASS |
| **T5-P1-02** | Chạy `flutter analyze` — fix tất cả warnings/errors | _(main branch)_ | Output: `No issues found!` | `flutter analyze` sạch |
| **T5-P1-03** | Build Release APK | `chore/release` | `build/app/outputs/flutter-apk/app-release.apk` | APK chạy được trên emulator |

### P3 — ductdhe186732

| ID | Task | Branch | Deliverable | Done khi |
|----|------|--------|-------------|---------|
| **T5-P3-01** | Viết Widget Test `StudySetCard` — verify tên, số thẻ render đúng | `test/study-set-card` | `test/widgets/study_set_card_test.dart` với ≥ 2 test cases | `flutter test` PASS |

### P2, P4, P5 — Bug Fix & Final QA

| ID | Người | Task |
|----|-------|------|
| **T5-P2-01** | P2 | Test toàn bộ auth flow: register → login → profile → logout |
| **T5-P4-01** | P4 | Test flashcard flip animation; test quiz end-to-end |
| **T5-P5-01** | P5 | Test progress chart với data thật; test chat gửi/nhận |

---

## Checklist trước khi nộp

- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — cả 2 test file PASS
- [ ] Release APK build thành công
- [ ] Chụp màn hình / quay video APK chạy trên emulator (Release Mode)
- [ ] Postman collection export và đính kèm
- [ ] Tất cả tính năng UC#1–UC#10 hoạt động với real API
- [ ] Không có token/password bị log ra console
- [ ] `.kiro/`, `build/`, `*.apk` không bị commit lên git

---

## Rủi ro & Mitigation

| Rủi ro | Xác suất | Giải pháp |
|--------|----------|-----------|
| BE API chưa sẵn sàng tuần 3 | Trung bình | Dùng mock data đến tuần 4, chỉ swap API call khi BE xong |
| Conflict merge giữa P2/P3/P4/P5 | Thấp | Mỗi người làm riêng branch, chỉ merge vào main khi feature done |
| `fl_chart` API thay đổi so với docs | Thấp | Pin version `0.69.0` trong pubspec |
| AnimationController flashcard jank | Trung bình | Test trên physical device sớm (tuần 2) |
| JWT hết hạn trong lúc demo | Thấp | Test 401 flow trước khi demo, set token TTL dài trong BE (dev mode) |
