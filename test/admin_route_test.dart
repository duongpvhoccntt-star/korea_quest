import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/app/app.dart';
import 'package:korea_quest/app/app_router.dart';

void main() {
  testWidgets('admin route explains missing Supabase configuration', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(appRouterProvider).go('/admin');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const KoreaQuestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa cấu hình Supabase'), findsOneWidget);
    expect(find.textContaining('SUPABASE_PUBLISHABLE_KEY'), findsOneWidget);
  });
}
