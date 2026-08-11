import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    return ModulePage(
      eyebrow: 'Bản đồ khám phá',
      title: 'Chọn nơi câu chuyện bắt đầu',
      description:
          'Danh sách địa điểm dùng chung; feature Khám phá chỉ trình bày và điều hướng.',
      child: locations.when(
        loading: LoadingIndicator.new,
        error: (error, stack) => ErrorState(
          message: 'Không thể tải địa điểm: $error',
          onRetry: () => ref.invalidate(locationsProvider),
        ),
        data: (items) => Column(
          children: [
            const SearchField(),
            const SizedBox(height: AppSpacing.lg),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 270,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) =>
                  _LocationCard(location: items[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: location.status == LocationStatus.locked
          ? null
          : () => context.go('/locations/${location.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusChip(status: location.status),
                const Spacer(),
                Text('+${location.rewardXp} XP'),
              ],
            ),
            const Spacer(),
            Text(
              location.koreanName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(location.name, style: Theme.of(context).textTheme.titleLarge),
            Text('${location.city} · ${location.description}'),
          ],
        ),
      ),
    ),
  );
}
