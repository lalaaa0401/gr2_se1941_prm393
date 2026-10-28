import 'package:flutter/foundation.dart';
import '../models/study_progress.dart';
import '../services/api_service.dart';

/// Điểm dữ liệu cho một ngày trong tuần — dùng bởi bar chart.
class DailyStudy {
  final String label; // e.g. 'T2', 'T3', ...
  final int cardsStudied;

  const DailyStudy(this.label, this.cardsStudied);
}

/// T3-P5-01 – ViewModel cho trang tiến độ học tập.
///
/// Dùng mock data cho đến khi backend sẵn sàng (T3);
/// swap `_loadMock()` thành `_apiService.getProgressSummary()` khi API online.
class ProgressViewModel extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _apiService;

  ProgressSummary? _summary;
  List<DailyStudy> _weeklyStudy = [];
  bool _isLoading = false;

  ProgressViewModel(this._apiService);

  ProgressSummary? get summary => _summary;
  List<DailyStudy> get weeklyStudy => _weeklyStudy;
  bool get isLoading => _isLoading;

  Future<void> loadProgress() async {
    if (_isLoading || _summary != null) return;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _summary = ProgressSummary(
      totalKnownCards: 42,
      totalQuizzesTaken: 8,
      avgScorePercentage: 0.73,
      totalStudySets: 4,
    );

    _weeklyStudy = const [
      DailyStudy('T2', 12),
      DailyStudy('T3', 8),
      DailyStudy('T4', 15),
      DailyStudy('T5', 5),
      DailyStudy('T6', 20),
      DailyStudy('T7', 0),
      DailyStudy('CN', 0),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
