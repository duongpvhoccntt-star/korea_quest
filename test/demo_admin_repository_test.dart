import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/admin/data/demo_admin_repository.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';

void main() {
  group('DemoAdminRepository', () {
    late DemoAdminRepository repository;

    setUp(() => repository = DemoAdminRepository());
    tearDown(() => repository.dispose());

    test('đăng nhập bằng tài khoản demo có sẵn', () async {
      await repository.signIn(email: 'admin', password: 'admin123');

      expect(repository.currentSession.isSignedIn, isTrue);
      expect(repository.currentSession.email, 'admin');
      expect(await repository.isCurrentUserAdmin(), isTrue);

      await repository.signOut();
      expect(repository.currentSession.isSignedIn, isFalse);
    });

    test('đăng ký username mới và tự đăng nhập', () async {
      await repository.register(username: 'nhom_1', password: '1234');

      expect(repository.currentSession.email, 'nhom_1');

      await repository.signOut();
      await repository.signIn(email: 'nhom_1', password: '1234');
      expect(repository.currentSession.isSignedIn, isTrue);
    });

    test('không cho đăng ký trùng username', () async {
      expect(
        () => repository.register(username: 'admin', password: 'new-password'),
        throwsA(isA<FormatException>()),
      );
    });

    test('kiểm tra định dạng username và mật khẩu', () async {
      expect(
        () => repository.register(username: 'a b', password: '1234'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => repository.register(username: 'tester', password: '123'),
        throwsA(isA<FormatException>()),
      );
    });

    test('chỉ chấp nhận 10–20 câu Quiz tổng kết', () async {
      final draft = AdminLocationDraft(
        quiz: List.generate(9, (_) => <String, dynamic>{'is_visible': true}),
      );

      var errors = await repository.validateDraft(draft);
      expect(errors, contains(contains('10 đến 20')));

      draft.quiz.add(<String, dynamic>{'is_visible': true});
      errors = await repository.validateDraft(draft);
      expect(errors, isNot(contains(contains('10 đến 20'))));

      draft.quiz.addAll(
        List.generate(11, (_) => <String, dynamic>{'is_visible': false}),
      );
      errors = await repository.validateDraft(draft);
      expect(errors, contains(contains('10 đến 20')));
    });

    test('lưu và cập nhật cấu hình gameplay trong demo', () async {
      await repository.saveLevel(
        const AdminLevelDefinition(levelNumber: 1, minXp: 0, title: 'Tân binh'),
      );
      await repository.saveLevel(
        const AdminLevelDefinition(
          levelNumber: 1,
          minXp: 0,
          title: 'Nhà thám hiểm mới',
        ),
      );
      await repository.saveAchievement(
        const AdminAchievementDefinition(
          slug: 'first-place',
          title: 'Điểm đến đầu tiên',
          metric: AdminAchievementMetric.completedLocations,
          target: 1,
        ),
      );

      final config = await repository.getGameConfig();
      expect(config.levels, hasLength(1));
      expect(config.levels.single.title, 'Nhà thám hiểm mới');
      expect(config.achievements, hasLength(1));
    });
  });
}
