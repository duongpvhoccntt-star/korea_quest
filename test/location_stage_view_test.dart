import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';
import 'package:korea_quest/features/explore/presentation/widgets/location_content_view.dart';

void main() {
  const location = PublishedLocationDetail({
    'id': 'sample',
    'slug': 'sample',
    'name': 'Địa điểm mẫu',
    'korean_name': '샘플',
    'english_name': 'Sample Place',
    'city': 'Seoul',
    'short_description': 'Mô tả ngắn.',
    'foods': <Object?>[],
  });

  Widget buildApp({required int stage, required ValueChanged<int> onStage}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LocationContentView(
            location: location,
            currentStage: stage,
            onStageSelected: onStage,
            onSubmitQuizAnswer: (_, _) async =>
                const QuizAnswerResult(isCorrect: false, explanation: ''),
          ),
        ),
      ),
    );
  }

  testWidgets('renders one selected stage and continues to the next stage', (
    tester,
  ) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 6, onStage: (stage) => selectedStage = stage),
    );

    expect(find.text('Chặng 6/9'), findsOneWidget);
    expect(find.text('Ẩm thực'), findsWidgets);
    expect(find.text('Chưa có nội dung ẩm thực để hiển thị.'), findsOneWidget);

    await tester.ensureVisible(find.text('Tiếp tục đến Fun Facts'));
    await tester.tap(find.text('Tiếp tục đến Fun Facts'));
    expect(selectedStage, 7);
  });

  testWidgets('starts the journey from the hero into the overview stage', (
    tester,
  ) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 1, onStage: (stage) => selectedStage = stage),
    );

    await tester.ensureVisible(find.text('Bắt đầu khám phá'));
    await tester.tap(find.text('Bắt đầu khám phá'));
    expect(selectedStage, 2);
  });
  testWidgets('does not render inactive detail action buttons', (tester) async {
    await tester.pumpWidget(buildApp(stage: 3, onStage: (_) {}));

    expect(find.text('Xem chi tiết'), findsNothing);
    expect(find.text('Khám phá'), findsNothing);
    expect(find.text('Tìm hiểu ý nghĩa'), findsNothing);
    expect(find.text('Mở bản đồ'), findsNothing);
  });
  testWidgets('returns to the map after the travel stage', (tester) async {
    var selectedStage = -1;

    await tester.pumpWidget(
      buildApp(stage: 9, onStage: (stage) => selectedStage = stage),
    );

    await tester.ensureVisible(find.text('Trở về bản đồ Hàn Quốc'));
    await tester.tap(find.text('Trở về bản đồ Hàn Quốc'));
    expect(selectedStage, 0);
  });
}
