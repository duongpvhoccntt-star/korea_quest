import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/korea_quest_repository.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

final koreaQuestRepositoryProvider = Provider<KoreaQuestRepository>(
  (ref) => MockKoreaQuestRepository(),
);

final currentUserProvider = FutureProvider<AppUser>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getCurrentUser(),
);

final userProgressProvider = FutureProvider<UserProgress>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getUserProgress(),
);

final locationsProvider = FutureProvider<List<Location>>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getLocations(),
);

final achievementsProvider = FutureProvider<List<Achievement>>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getAchievements(),
);

final passportStampsProvider = FutureProvider<List<PassportStamp>>(
  (ref) => ref.watch(koreaQuestRepositoryProvider).getPassportStamps(),
);

final locationProvider = FutureProvider.family<Location?, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getLocation(id),
);

final journeyProvider = FutureProvider.family<JourneyProgress, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getJourney(id),
);

final missionsProvider = FutureProvider.family<List<Mission>, String>(
  (ref, id) => ref.watch(koreaQuestRepositoryProvider).getMissions(id),
);
