import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/features/achievements/presentation/pages/achievements_page.dart';
import 'package:korea_quest/features/auth/presentation/pages/auth_page.dart';
import 'package:korea_quest/features/explore/presentation/pages/explore_page.dart';
import 'package:korea_quest/features/explore/presentation/pages/location_detail_page.dart';
import 'package:korea_quest/features/home/presentation/pages/home_page.dart';
import 'package:korea_quest/features/journey/presentation/pages/journey_page.dart';
import 'package:korea_quest/features/landing/presentation/pages/landing_page.dart';
import 'package:korea_quest/features/passport/presentation/pages/passport_page.dart';
import 'package:korea_quest/features/profile/presentation/pages/profile_page.dart';
import 'package:korea_quest/features/settings/presentation/pages/settings_page.dart';
import 'package:korea_quest/features/system_states/presentation/pages/system_state_page.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

abstract final class AppRouteNames {
  static const landing = 'landing';
  static const register = 'register';
  static const login = 'login';
  static const forgotPassword = 'forgot-password';
  static const home = 'home';
  static const explore = 'explore';
  static const location = 'location';
  static const journey = 'journey';
  static const journeyCheckIn = 'journey-check-in';
  static const journeyCulture = 'journey-culture';
  static const journeyVocabulary = 'journey-vocabulary';
  static const journeySummary = 'journey-summary';
  static const passport = 'passport';
  static const achievements = 'achievements';
  static const profile = 'profile';
  static const profileEdit = 'profile-edit';
  static const settings = 'settings';
  static const forbidden = 'forbidden';
  static const offline = 'offline';
  static const error = 'error';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) =>
        const SystemStatePage(kind: SystemStateKind.notFound),
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteNames.landing,
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRouteNames.register,
        builder: (context, state) =>
            const AuthPage(mode: AuthPageMode.register),
      ),
      GoRoute(
        path: '/login',
        name: AppRouteNames.login,
        builder: (context, state) => const AuthPage(mode: AuthPageMode.login),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRouteNames.forgotPassword,
        builder: (context, state) =>
            const AuthPage(mode: AuthPageMode.forgotPassword),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: AppRouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/explore',
            name: AppRouteNames.explore,
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: '/locations/:locationId',
            name: AppRouteNames.location,
            builder: (context, state) => LocationDetailPage(
              locationId: state.pathParameters['locationId']!,
            ),
          ),
          GoRoute(
            path: '/journey/:locationId',
            name: AppRouteNames.journey,
            builder: (context, state) =>
                JourneyPage(locationId: state.pathParameters['locationId']!),
            routes: [
              GoRoute(
                path: 'check-in',
                name: AppRouteNames.journeyCheckIn,
                builder: (context, state) => JourneyPage(
                  locationId: state.pathParameters['locationId']!,
                  stage: JourneyStage.checkIn,
                ),
              ),
              GoRoute(
                path: 'culture',
                name: AppRouteNames.journeyCulture,
                builder: (context, state) => JourneyPage(
                  locationId: state.pathParameters['locationId']!,
                  stage: JourneyStage.culture,
                ),
              ),
              GoRoute(
                path: 'vocabulary',
                name: AppRouteNames.journeyVocabulary,
                builder: (context, state) => JourneyPage(
                  locationId: state.pathParameters['locationId']!,
                  stage: JourneyStage.vocabulary,
                ),
              ),
              GoRoute(
                path: 'summary',
                name: AppRouteNames.journeySummary,
                builder: (context, state) => JourneyPage(
                  locationId: state.pathParameters['locationId']!,
                  stage: JourneyStage.summary,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/passport',
            name: AppRouteNames.passport,
            builder: (context, state) => const PassportPage(),
          ),
          GoRoute(
            path: '/achievements',
            name: AppRouteNames.achievements,
            builder: (context, state) => const AchievementsPage(),
          ),
          GoRoute(
            path: '/profile',
            name: AppRouteNames.profile,
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                name: AppRouteNames.profileEdit,
                builder: (context, state) => const ProfilePage(isEditing: true),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: AppRouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/403',
        name: AppRouteNames.forbidden,
        builder: (context, state) =>
            const SystemStatePage(kind: SystemStateKind.forbidden),
      ),
      GoRoute(
        path: '/offline',
        name: AppRouteNames.offline,
        builder: (context, state) =>
            const SystemStatePage(kind: SystemStateKind.offline),
      ),
      GoRoute(
        path: '/error',
        name: AppRouteNames.error,
        builder: (context, state) =>
            const SystemStatePage(kind: SystemStateKind.error),
      ),
    ],
  );
});
