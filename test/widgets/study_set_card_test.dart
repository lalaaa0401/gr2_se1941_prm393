import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzone/models/study_set.dart';
import 'package:quizzone/widgets/study_set_card.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('StudySetCard', () {
    test('StudySet.cardCount returns correct count', () {
      final s = StudySet(id: 1, title: 'Test', cardCount: 12);
      expect(s.cardCount, equals(12));
    });

    testWidgets('renders study set title', (tester) async {
      final studySet = StudySet(
        id: 1,
        title: 'English Vocabulary',
        cardCount: 20,
      );

      await tester.pumpWidget(_wrap(StudySetCard(studySet: studySet)));

      expect(find.text('English Vocabulary'), findsOneWidget);
    });

    testWidgets('renders card count with mono style', (tester) async {
      final studySet = StudySet(
        id: 2,
        title: 'Flutter Widgets',
        cardCount: 15,
      );

      await tester.pumpWidget(_wrap(StudySetCard(studySet: studySet)));

      expect(find.text('15 thẻ'), findsOneWidget);

      // Verify the text uses mono fontFamily
      final richTextFinder = find.text('15 thẻ');
      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('renders subject chip when subject is not null', (tester) async {
      final studySet = StudySet(
        id: 3,
        title: 'Kiến trúc phần mềm',
        subject: 'SE',
        cardCount: 10,
      );

      await tester.pumpWidget(_wrap(StudySetCard(studySet: studySet)));

      expect(find.text('SE'), findsOneWidget);
    });

    testWidgets('does not render subject chip when subject is null',
        (tester) async {
      final studySet = StudySet(id: 4, title: 'No Subject', cardCount: 5);

      await tester.pumpWidget(_wrap(StudySetCard(studySet: studySet)));

      // Subject chip should not be present
      expect(find.byType(Container), findsWidgets);
      // No subject-specific text beyond title and count
      expect(find.text('No Subject'), findsOneWidget);
      expect(find.text('5 thẻ'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final studySet = StudySet(id: 5, title: 'Tap Test', cardCount: 3);

      await tester.pumpWidget(
        _wrap(StudySetCard(studySet: studySet, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });
}
