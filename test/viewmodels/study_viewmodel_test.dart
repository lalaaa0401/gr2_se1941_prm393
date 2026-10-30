import 'package:flutter_test/flutter_test.dart';
import 'package:quizzone/models/quiz_result.dart';
import 'package:quizzone/models/study_progress.dart';
import 'package:quizzone/services/api_service.dart';
import 'package:quizzone/viewmodels/study_viewmodel.dart';

/// Stub ApiService — không gọi Dio, dùng cho unit test.
class _StubApiService extends ApiService {
  @override
  Future<void> updateCardProgress(
      int setId, int flashcardId, CardStatus status) async {
    // No-op stub
  }

  @override
  Future<QuizResult> submitQuizResult(
      int studySetId, int score, int totalQuestions) async {
    return QuizResult(
      studySetId: studySetId,
      score: score,
      totalQuestions: totalQuestions,
    );
  }
}

void main() {
  late StudyViewModel vm;

  setUp(() {
    vm = StudyViewModel(_StubApiService());
  });

  group('StudyViewModel — session management', () {
    test('startSession resets sessionKnownIds', () {
      vm.startSession(1);
      expect(vm.sessionKnownIds, isEmpty);
    });

    test('markKnown adds flashcardId to sessionKnownIds', () async {
      await vm.markKnown(1, 42);
      expect(vm.sessionKnownIds, contains(42));
    });

    test('markUnknown removes flashcardId from sessionKnownIds', () async {
      await vm.markKnown(1, 42);
      await vm.markUnknown(1, 42);
      expect(vm.sessionKnownIds, isNot(contains(42)));
    });

    test('finishSession clears sessionKnownIds', () async {
      await vm.markKnown(1, 10);
      await vm.markKnown(1, 20);
      vm.finishSession();
      expect(vm.sessionKnownIds, isEmpty);
    });
  });

  group('StudyViewModel — quiz result', () {
    test('submitQuizResult stores lastScore and lastTotal', () async {
      await vm.submitQuizResult(1, 7, 10);
      expect(vm.lastScore, equals(7));
      expect(vm.lastTotal, equals(10));
    });

    test('submitQuizResult returns QuizResult with correct fields', () async {
      final result = await vm.submitQuizResult(2, 5, 8);
      expect(result, isNotNull);
      expect(result!.score, equals(5));
      expect(result.totalQuestions, equals(8));
    });

    test('lastScore is null before any quiz submission', () {
      expect(vm.lastScore, isNull);
      expect(vm.lastTotal, isNull);
    });
  });
}
