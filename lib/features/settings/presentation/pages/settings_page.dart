import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool reducedMotion = false;

  @override
  Widget build(BuildContext context) => ModulePage(
    eyebrow: 'Tùy chỉnh',
    title: 'Cài đặt',
    description: 'Các tùy chọn khung được giữ cục bộ; chưa đồng bộ backend.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SwitchListTile(
              value: notifications,
              onChanged: (value) => setState(() => notifications = value),
              title: const Text('Thông báo hành trình'),
              subtitle: const Text('Nhắc khi có nhiệm vụ và phần thưởng mới'),
            ),
            SwitchListTile(
              value: reducedMotion,
              onChanged: (value) => setState(() => reducedMotion = value),
              title: const Text('Giảm hiệu ứng chuyển động'),
              subtitle: const Text('Hỗ trợ trải nghiệm dễ tiếp cận hơn'),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: DangerButton(
                label: 'Xóa dữ liệu bản mẫu',
                onPressed: () async {
                  final confirmed = await ConfirmationDialog.show(
                    context,
                    title: 'Xóa dữ liệu bản mẫu?',
                    message:
                        'Đây chỉ là thao tác mô phỏng và không xóa dữ liệu thật.',
                    confirmLabel: 'Xác nhận',
                  );
                  if (confirmed && context.mounted) {
                    AppToast.show(context, 'Không có dữ liệu thật nào bị xóa.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
