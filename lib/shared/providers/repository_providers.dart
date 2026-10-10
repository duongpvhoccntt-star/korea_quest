import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/l10n/locale_controller.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/korea_quest_repository.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';
import 'package:korea_quest/shared/repositories/supabase_korea_quest_repository.dart';

final koreaQuestRepositoryProvider = Provider<KoreaQuestRepository>((ref) {
  if (AppConfig.hasSupabaseConfiguration) {
    return SupabaseKoreaQuestRepository();
  }
  return MockKoreaQuestRepository();
});

final currentUserProvider = FutureProvider<AppUser>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getCurrentUser(),
);

final userProgressProvider = FutureProvider<UserProgress>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  return ref
      .watch(koreaQuestRepositoryProvider)
      .getUserProgress(locale: locale);
});

final locationsProvider = FutureProvider<List<Location>>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getLocations(),
);

final earnedAchievementsProvider = FutureProvider<List<Achievement>>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  return ref
      .watch(koreaQuestRepositoryProvider)
      .getEarnedAchievements(locale: locale);
});

final earnedPassportStampsProvider = FutureProvider<List<PassportStamp>>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  return ref
      .watch(koreaQuestRepositoryProvider)
      .getEarnedPassportStamps(locale: locale);
});

final sharedPassportProvider = FutureProvider.family<SharedPassport?, String>((
  ref,
  token,
) {
  final locale = ref.watch(localeProvider).languageCode;
  return ref
      .watch(koreaQuestRepositoryProvider)
      .getSharedPassport(token, locale: locale);
});

final locationProvider = FutureProvider.family<Location?, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getLocation(id),
);

final journeyProvider = FutureProvider.family<JourneyProgress, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getJourney(id),
);

final missionsProvider = FutureProvider.family<List<Mission>, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getMissions(id),
);
