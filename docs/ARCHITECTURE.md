# Kiến trúc KoreaQuest Phase 1

## Mục tiêu

Nền tảng dùng feature-first để mỗi thành viên làm việc trong một module riêng, trong khi UI, routing contract và dữ liệu mẫu được thống nhất ở lớp dùng chung.

## Cấu trúc

    lib/
    ├── app/                  # app bootstrap, Material theme, router, config
    ├── core/                 # responsive và tiện ích không phụ thuộc feature
    ├── design_system/        # token và component UI dùng chung
    ├── shared/
    │   ├── models/           # ubiquitous domain models và enum
    │   ├── repositories/     # interface + mock implementation
    │   ├── providers/        # Riverpod dependency/data providers
    │   └── widgets/          # layout dùng giữa nhiều feature
    └── features/
        └── <feature>/
            └── presentation/ # pages/widgets của module

Chỉ tạo data/, domain/, providers/ hoặc widgets/ bên trong feature khi có nội dung thật. Không tạo cây thư mục rỗng.

## Luồng phụ thuộc

    presentation → Riverpod provider → repository interface → mock repository
    presentation → design_system/core
    app router → feature pages

Feature không import presentation của feature khác. Điều hướng qua route; dữ liệu dùng chung qua repository/provider.

## Routing

lib/app/app_router.dart là hợp đồng URL dùng chung. Các trang sau đăng nhập dùng ShellRoute và AppShell; landing/auth/system state có scaffold phù hợp riêng. Không có auth redirect thật trong Phase 1.

## Dữ liệu

KoreaQuestRepository là seam thay thế. Phase 1 inject MockKoreaQuestRepository; tích hợp Supabase sau này phải tạo implementation mới và đổi provider, không làm UI gọi Supabase trực tiếp.

## Responsive và accessibility

Breakpoint tập trung tại ResponsiveBreakpoints: mobile dưới 600 px, tablet 600–1023 px, desktop từ 1024 px. Nội dung có chiều rộng tối đa 1240 px. Trạng thái luôn có nhãn/icon ngoài màu sắc và control chính có vùng bấm tối thiểu 48 px.
