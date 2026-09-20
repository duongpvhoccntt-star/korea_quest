import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_models.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';

enum GameConfigSection { levels, achievements, challenges }

class GameConfigAdmin extends ConsumerWidget {
  const GameConfigAdmin({required this.section, super.key});

  final GameConfigSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(adminGameConfigProvider);
    return config.when(
      loading: () => const LoadingIndicator(label: 'Đang tải cấu hình…'),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(adminGameConfigProvider),
      ),
      data: (data) => switch (section) {
        GameConfigSection.levels => _LevelsPanel(config: data),
        GameConfigSection.achievements => _AchievementsPanel(config: data),
        GameConfigSection.challenges => _ChallengesPanel(config: data),
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.onAdd,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
      PrimaryButton(label: buttonLabel, icon: icon, onPressed: onAdd),
    ],
  );
}

class _LevelsPanel extends ConsumerWidget {
  const _LevelsPanel({required this.config});
  final AdminGameConfig config;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AdminLevelDefinition? current,
  ]) async {
    final value = await showDialog<AdminLevelDefinition>(
      context: context,
      builder: (_) => _LevelDialog(current: current),
    );
    if (value == null) return;
    try {
      await ref.read(adminRepositoryProvider).saveLevel(value);
      ref.invalidate(adminGameConfigProvider);
      if (context.mounted) AppToast.show(context, 'Đã lưu cấp độ.');
    } catch (error) {
      if (context.mounted) AppToast.show(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionHeader(
        title: 'Cấp độ & danh hiệu',
        description:
            'XP là nguồn dữ liệu gốc. Cấp độ và danh hiệu được suy ra từ các ngưỡng dưới đây.',
        buttonLabel: 'Thêm cấp độ',
        icon: Icons.trending_up_rounded,
        onAdd: () => _edit(context, ref),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (config.levels.isEmpty)
        const _EmptyConfig(message: 'Chưa có cấp độ nào được cấu hình.')
      else
        ...config.levels.map(
          (item) => _ConfigCard(
            icon: Icons.military_tech_outlined,
            title: 'Cấp ${item.levelNumber} · ${item.title}',
            subtitle:
                'Từ ${NumberFormat.decimalPattern('vi').format(item.minXp)} XP${item.isActive ? '' : ' · Đã tắt'}',
            onEdit: () => _edit(context, ref, item),
          ),
        ),
    ],
  );
}

class _AchievementsPanel extends ConsumerWidget {
  const _AchievementsPanel({required this.config});
  final AdminGameConfig config;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AdminAchievementDefinition? current,
  ]) async {
    final value = await showDialog<AdminAchievementDefinition>(
      context: context,
      builder: (_) => _AchievementDialog(current: current),
    );
    if (value == null) return;
    try {
      await ref.read(adminRepositoryProvider).saveAchievement(value);
      ref.invalidate(adminGameConfigProvider);
      if (context.mounted) AppToast.show(context, 'Đã lưu huy hiệu.');
    } catch (error) {
      if (context.mounted) AppToast.show(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionHeader(
        title: 'Huy hiệu',
        description:
            'Cấu hình điều kiện tự động. Tiêu chí sẽ bị khóa sau khi huy hiệu đầu tiên được trao.',
        buttonLabel: 'Tạo huy hiệu',
        icon: Icons.workspace_premium_outlined,
        onAdd: () => _edit(context, ref),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (config.achievements.isEmpty)
        const _EmptyConfig(message: 'Chưa có huy hiệu nào được cấu hình.')
      else
        ...config.achievements.map(
          (item) => _ConfigCard(
            icon: item.isSecret
                ? Icons.visibility_off_outlined
                : Icons.workspace_premium_outlined,
            title: item.title,
            subtitle:
                '${item.metric.label}: ${item.target} · /${item.slug}${item.isLimited ? ' · Giới hạn' : ''}${item.isCriteriaLocked ? ' · Tiêu chí đã khóa' : ''}',
            onEdit: () => _edit(context, ref, item),
          ),
        ),
    ],
  );
}

class _ChallengesPanel extends ConsumerWidget {
  const _ChallengesPanel({required this.config});
  final AdminGameConfig config;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AdminChallengeDefinition? current,
  ]) async {
    final value = await showDialog<AdminChallengeDefinition>(
      context: context,
      builder: (_) =>
          _ChallengeDialog(current: current, achievements: config.achievements),
    );
    if (value == null) return;
    try {
      await ref.read(adminRepositoryProvider).saveChallenge(value);
      ref.invalidate(adminGameConfigProvider);
      if (context.mounted) AppToast.show(context, 'Đã lưu thử thách.');
    } catch (error) {
      if (context.mounted) AppToast.show(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionHeader(
        title: 'Thử thách',
        description:
            'Thiết lập thời gian, nhiều mục tiêu và phần thưởng XP hoặc huy hiệu.',
        buttonLabel: 'Tạo thử thách',
        icon: Icons.flag_outlined,
        onAdd: () => _edit(context, ref),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (config.challenges.isEmpty)
        const _EmptyConfig(message: 'Chưa có thử thách nào được cấu hình.')
      else
        ...config.challenges.map(
          (item) => _ConfigCard(
            icon: Icons.flag_outlined,
            title: item.title,
            subtitle:
                '${DateFormat('dd/MM/yyyy').format(item.startsAt.toLocal())}–${DateFormat('dd/MM/yyyy').format(item.endsAt.toLocal())} · ${item.goals.length} mục tiêu · ${item.rewardXp} XP · ${item.status}',
            onEdit: () => _edit(context, ref, item),
          ),
        ),
    ],
  );
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onEdit,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Icon(icon, color: AppColors.coral),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'Chỉnh sửa',
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
      ),
    ),
  );
}

class _EmptyConfig extends StatelessWidget {
  const _EmptyConfig({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

class _LevelDialog extends StatefulWidget {
  const _LevelDialog({this.current});
  final AdminLevelDefinition? current;

  @override
  State<_LevelDialog> createState() => _LevelDialogState();
}

class _LevelDialogState extends State<_LevelDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _level;
  late final TextEditingController _xp;
  late final TextEditingController _title;
  late final TextEditingController _icon;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final item = widget.current;
    _level = TextEditingController(text: item?.levelNumber.toString());
    _xp = TextEditingController(text: item?.minXp.toString());
    _title = TextEditingController(text: item?.title);
    _icon = TextEditingController(text: item?.iconUrl);
    _active = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _level.dispose();
    _xp.dispose();
    _title.dispose();
    _icon.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      AdminLevelDefinition(
        id: widget.current?.id,
        levelNumber: int.parse(_level.text),
        minXp: int.parse(_xp.text),
        title: _title.text.trim(),
        iconUrl: _icon.text.trim(),
        isActive: _active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.current == null ? 'Thêm cấp độ' : 'Sửa cấp độ'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _numberField(_level, 'Số cấp')),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _numberField(_xp, 'XP tối thiểu', allowZero: true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _requiredField(_title, 'Danh hiệu'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _icon,
              decoration: const InputDecoration(
                labelText: 'URL icon (tùy chọn)',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đang sử dụng'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(onPressed: _save, child: const Text('Lưu')),
    ],
  );
}

class _AchievementDialog extends StatefulWidget {
  const _AchievementDialog({this.current});
  final AdminAchievementDefinition? current;

  @override
  State<_AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<_AchievementDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _slug;
  late final TextEditingController _title;
  late final TextEditingController _korean;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _icon;
  late final TextEditingController _target;
  late final TextEditingController _filter;
  late AdminAchievementMetric _metric;
  late bool _secret;
  late bool _limited;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final item = widget.current;
    _slug = TextEditingController(text: item?.slug);
    _title = TextEditingController(text: item?.title);
    _korean = TextEditingController(text: item?.koreanTitle);
    _description = TextEditingController(text: item?.description);
    _category = TextEditingController(text: item?.category ?? 'general');
    _icon = TextEditingController(text: item?.iconUrl);
    _target = TextEditingController(text: item?.target.toString() ?? '1');
    _filter = TextEditingController(
      text: const JsonEncoder.withIndent(
        '  ',
      ).convert(item?.criteriaFilter ?? {}),
    );
    _metric = item?.metric ?? AdminAchievementMetric.completedLocations;
    _secret = item?.isSecret ?? false;
    _limited = item?.isLimited ?? false;
    _active = item?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final controller in [
      _slug,
      _title,
      _korean,
      _description,
      _category,
      _icon,
      _target,
      _filter,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    try {
      final decoded = jsonDecode(_filter.text);
      if (decoded is! Map) throw const FormatException();
      Navigator.pop(
        context,
        AdminAchievementDefinition(
          id: widget.current?.id,
          slug: _slug.text.trim(),
          title: _title.text.trim(),
          koreanTitle: _korean.text.trim(),
          description: _description.text.trim(),
          category: _category.text.trim(),
          iconUrl: _icon.text.trim(),
          metric: _metric,
          target: int.parse(_target.text),
          criteriaFilter: decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
          isSecret: _secret,
          isLimited: _limited,
          isActive: _active,
          availableFrom: widget.current?.availableFrom,
          availableUntil: widget.current?.availableUntil,
          displayOrder: widget.current?.displayOrder ?? 0,
          criteriaLockedAt: widget.current?.criteriaLockedAt,
        ),
      );
    } on FormatException {
      AppToast.show(context, 'Bộ lọc phải là JSON object hợp lệ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.current?.isCriteriaLocked ?? false;
    return AlertDialog(
      title: Text(widget.current == null ? 'Tạo huy hiệu' : 'Sửa huy hiệu'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _slugField(_slug),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _requiredField(_title, 'Tên huy hiệu')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _korean,
                        decoration: const InputDecoration(
                          labelText: 'Tên tiếng Hàn',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _requiredField(_category, 'Nhóm')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _icon,
                        decoration: const InputDecoration(
                          labelText: 'URL icon',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AdminAchievementMetric>(
                        initialValue: _metric,
                        decoration: const InputDecoration(labelText: 'Chỉ số'),
                        items: AdminAchievementMetric.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: locked
                            ? null
                            : (value) => setState(() => _metric = value!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: IgnorePointer(
                        ignoring: locked,
                        child: _numberField(_target, 'Mục tiêu'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _filter,
                  enabled: !locked,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Bộ lọc tiêu chí (JSON)',
                    helperText: locked
                        ? 'Đã khóa vì huy hiệu đã được trao.'
                        : 'Ví dụ: {location_id: ...}',
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Huy hiệu bí mật'),
                  value: _secret,
                  onChanged: (value) =>
                      setState(() => _secret = value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Huy hiệu giới hạn thời gian'),
                  value: _limited,
                  onChanged: locked
                      ? null
                      : (value) => setState(() => _limited = value ?? false),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang sử dụng'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}

class _ChallengeDialog extends StatefulWidget {
  const _ChallengeDialog({this.current, required this.achievements});
  final AdminChallengeDefinition? current;
  final List<AdminAchievementDefinition> achievements;

  @override
  State<_ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<_ChallengeDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _slug;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _rewardXp;
  late DateTime _startsAt;
  late DateTime _endsAt;
  late String _status;
  late String? _rewardAchievementId;
  late List<AdminChallengeGoal> _goals;

  @override
  void initState() {
    super.initState();
    final item = widget.current;
    final now = DateTime.now();
    _slug = TextEditingController(text: item?.slug);
    _title = TextEditingController(text: item?.title);
    _description = TextEditingController(text: item?.description);
    _rewardXp = TextEditingController(text: item?.rewardXp.toString() ?? '0');
    _startsAt = item?.startsAt.toLocal() ?? now;
    _endsAt = item?.endsAt.toLocal() ?? now.add(const Duration(days: 7));
    _status = item?.status ?? 'draft';
    _rewardAchievementId = item?.rewardAchievementId;
    _goals = List.of(item?.goals ?? const []);
  }

  @override
  void dispose() {
    _slug.dispose();
    _title.dispose();
    _description.dispose();
    _rewardXp.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final current = start ? _startsAt : _endsAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startsAt = picked;
      } else {
        _endsAt = picked.add(const Duration(hours: 23, minutes: 59));
      }
    });
  }

  Future<void> _addGoal([int? index]) async {
    final value = await showDialog<AdminChallengeGoal>(
      context: context,
      builder: (_) =>
          _GoalDialog(current: index == null ? null : _goals[index]),
    );
    if (value == null) return;
    setState(() {
      if (index == null) {
        _goals.add(value);
      } else {
        _goals[index] = value;
      }
    });
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    if (!_endsAt.isAfter(_startsAt)) {
      AppToast.show(context, 'Ngày kết thúc phải sau ngày bắt đầu.');
      return;
    }
    if (_goals.isEmpty) {
      AppToast.show(context, 'Thử thách cần ít nhất một mục tiêu.');
      return;
    }
    if (int.parse(_rewardXp.text) == 0 && _rewardAchievementId == null) {
      AppToast.show(context, 'Chọn ít nhất một phần thưởng XP hoặc Huy hiệu.');
      return;
    }
    Navigator.pop(
      context,
      AdminChallengeDefinition(
        id: widget.current?.id,
        slug: _slug.text.trim(),
        title: _title.text.trim(),
        description: _description.text.trim(),
        startsAt: _startsAt,
        endsAt: _endsAt,
        rewardXp: int.parse(_rewardXp.text),
        rewardAchievementId: _rewardAchievementId,
        status: _status,
        goals: _goals,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.current == null ? 'Tạo thử thách' : 'Sửa thử thách'),
    content: SizedBox(
      width: 680,
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _slugField(_slug),
              const SizedBox(height: AppSpacing.md),
              _requiredField(_title, 'Tên thử thách'),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(true),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        'Bắt đầu ${DateFormat('dd/MM/yyyy').format(_startsAt)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(false),
                      icon: const Icon(Icons.event_available_outlined),
                      label: Text(
                        'Kết thúc ${DateFormat('dd/MM/yyyy').format(_endsAt)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _rewardAchievementId,
                decoration: const InputDecoration(
                  labelText: 'Huy hiệu thưởng (tùy chọn)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Không có huy hiệu'),
                  ),
                  ...widget.achievements
                      .where((item) => item.id != null)
                      .map(
                        (item) => DropdownMenuItem<String?>(
                          value: item.id,
                          child: Text(item.title),
                        ),
                      ),
                ],
                onChanged: (value) =>
                    setState(() => _rewardAchievementId = value),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      _rewardXp,
                      'Thưởng XP',
                      allowZero: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                      items:
                          const [
                                'draft',
                                'scheduled',
                                'active',
                                'ended',
                                'archived',
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mục tiêu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addGoal,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mục tiêu'),
                  ),
                ],
              ),
              ..._goals.asMap().entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value.metric.label),
                  subtitle: Text('Mục tiêu: ${entry.value.target}'),
                  onTap: () => _addGoal(entry.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _goals.removeAt(entry.key)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(onPressed: _save, child: const Text('Lưu')),
    ],
  );
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({this.current});
  final AdminChallengeGoal? current;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late AdminAchievementMetric _metric;
  late final TextEditingController _target;
  late final TextEditingController _filter;

  @override
  void initState() {
    super.initState();
    _metric = widget.current?.metric ?? AdminAchievementMetric.contentViews;
    _target = TextEditingController(
      text: widget.current?.target.toString() ?? '1',
    );
    _filter = TextEditingController(
      text: jsonEncode(widget.current?.criteriaFilter ?? {}),
    );
  }

  @override
  void dispose() {
    _target.dispose();
    _filter.dispose();
    super.dispose();
  }

  void _save() {
    final target = int.tryParse(_target.text);
    try {
      final filter = jsonDecode(_filter.text);
      if (target == null || target < 1 || filter is! Map) {
        throw const FormatException();
      }
      Navigator.pop(
        context,
        AdminChallengeGoal(
          metric: _metric,
          target: target,
          criteriaFilter: filter.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );
    } on FormatException {
      AppToast.show(context, 'Kiểm tra lại mục tiêu và JSON bộ lọc.');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Mục tiêu thử thách'),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<AdminAchievementMetric>(
            initialValue: _metric,
            decoration: const InputDecoration(labelText: 'Chỉ số'),
            items: AdminAchievementMetric.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: (value) => setState(() => _metric = value!),
          ),
          const SizedBox(height: AppSpacing.md),
          _numberField(_target, 'Giá trị mục tiêu'),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _filter,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bộ lọc (JSON)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(onPressed: _save, child: const Text('Lưu mục tiêu')),
    ],
  );
}

TextFormField _requiredField(TextEditingController controller, String label) =>
    TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Không được để trống' : null,
    );

TextFormField _slugField(TextEditingController controller) => TextFormField(
  controller: controller,
  decoration: const InputDecoration(labelText: 'Slug'),
  validator: (value) =>
      value != null && RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value)
      ? null
      : 'Dùng chữ thường, số và dấu gạch ngang',
);

TextFormField _numberField(
  TextEditingController controller,
  String label, {
  bool allowZero = false,
}) => TextFormField(
  controller: controller,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(labelText: label),
  validator: (value) {
    final number = int.tryParse(value ?? '');
    if (number == null || (allowZero ? number < 0 : number < 1)) {
      return allowZero ? 'Nhập số từ 0' : 'Nhập số lớn hơn 0';
    }
    return null;
  },
);
