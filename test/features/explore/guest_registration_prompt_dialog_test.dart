import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart';
import 'package:korea_quest/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'GuestRegistrationPromptDialog displays celebration and buttons',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: Scaffold(
            body: GuestRegistrationPromptDialog(
              locationName: 'Cung điện Gyeongbokgung',
              guestName: 'Minh Anh',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Minh Anh'), findsOneWidget);
      expect(find.textContaining('Cung điện Gyeongbokgung'), findsOneWidget);
      expect(find.text('Đăng ký & Lưu tiến trình'), findsOneWidget);
      expect(find.text('Để sau / Tiếp tục khám phá'), findsOneWidget);
    },
  );
}
