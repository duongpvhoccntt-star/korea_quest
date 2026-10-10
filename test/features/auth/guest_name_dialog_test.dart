import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/auth/presentation/widgets/guest_name_dialog.dart';
import 'package:korea_quest/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({required MockAuthRepository repository}) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('vi'),
        home: Scaffold(body: GuestNameDialog()),
      ),
    );
  }

  group('GuestNameDialog', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    testWidgets('renders input and shows error on empty submit', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      // Tap submit with empty name
      final submitButton = find.text('Vào khám phá ngay');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập tên của bạn.'), findsOneWidget);
      expect(repository.currentUser, isNull);
    });

    testWidgets('submits valid name and signs in as guest', (tester) async {
      await tester.pumpWidget(buildTestWidget(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Minh Anh');
      await tester.pumpAndSettle();

      final submitButton = find.text('Vào khám phá ngay');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(repository.currentUser, isNotNull);
      expect(repository.currentUser!.displayName, equals('Minh Anh'));
      expect(repository.currentUser!.isGuest, isTrue);
    });
  });
}
