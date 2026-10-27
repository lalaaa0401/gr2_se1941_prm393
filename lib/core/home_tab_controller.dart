import 'package:flutter/foundation.dart';

/// Controller điều hướng tab của HomeScreen từ bất kỳ đâu trong cây widget.
///
/// Bất kỳ widget nào cần chuyển tab có thể gọi [switchTo] thay vì
/// điều hướng trực tiếp vào HomeScreen.
class HomeTabController extends ChangeNotifier {
  int _activeIndex = 0;

  int get activeIndex => _activeIndex;

  /// Chuyển sang tab [index].
  /// Không làm gì nếu đã ở tab đó rồi.
  void switchTo(int index) {
    if (_activeIndex == index) return;
    _activeIndex = index;
    notifyListeners();
  }
}
