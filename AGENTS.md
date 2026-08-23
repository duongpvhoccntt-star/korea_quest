# KoreaQuest — Agent Guide

## Mục tiêu dự án

**KoreaQuest** là ứng dụng khám phá văn hóa Hàn Quốc theo hướng **game-based learning**.

Người dùng chọn địa điểm, hoàn thành các phần nội dung (Check-in → Văn hóa → Từ vựng), nhận XP, huy hiệu, dấu mộc và mở khóa địa điểm tiếp theo.

**Phạm vi MVP:**

```
Đăng nhập → Trang chủ → Bản đồ → Chọn địa điểm
→ Check-in → Văn hóa → Từ vựng → Tổng kết
→ Nhận XP / Huy hiệu / Dấu mộc → Mở khóa địa điểm tiếp theo
```

---

## Công nghệ thực tế (pubspec.yaml)

| Package | Phiên bản | Mục đích |
| :--- | :--- | :--- |
| Flutter | stable | Framework chính |
| Dart SDK | ^3.12.2 | Ngôn ngữ |
| `flutter_riverpod` | ^3.0.3 | State management & DI |
| `go_router` | ^17.0.1 | Routing |
| `flutter_localizations` | sdk | Đa ngôn ngữ |
| `intl` | ^0.20.2 | Định dạng ngày/số |
| `supabase_flutter` | ^2.17.1 | Backend (chưa kết nối thật) |
| `cupertino_icons` | ^1.0.8 | Icons |

- **Nền tảng ưu tiên:** Flutter Web.
- **Material 3** — không dùng Material 2.

---

## Kiến trúc

### Cấu trúc thư mục (feature-first)

```
lib/
├── main.dart
├── app/             # Router, Theme, Config, App widget
├── core/            # Constants, Extensions, Responsive, Utils, Errors
├── design_system/   # Token (Colors, Typography, Spacing, Radius, Shadows) + Components
├── shared/          # Models, Repositories, Services, Widgets dùng chung
├── features/
│   ├── auth/        # Phạm Văn Dương
│   ├── home/        # Phạm Văn Dương
│   ├── profile/     # Phạm Văn Dương
│   ├── passport/    # Phạm Văn Dương
│   ├── explore/     # Nguyễn Viết Thức
│   ├── journey/     # Nguyễn Viết Thức + Lê Uyên Nhi
│   └── achievements/# Lê Uyên Nhi
└── l10n/
```

### Cấu trúc bên trong mỗi feature

```
feature_name/
├── data/        # Repository implementation, datasource
├── domain/      # Models, interfaces
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

---

## Phân công thành viên

Xem đầy đủ tại [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md).

| Thành viên | Module |
| :--- | :--- |
| **Phạm Văn Dương** | `auth`, `home`, `profile`, `passport` |
| **Nguyễn Viết Thức** | `explore`, `journey` (Check-in) |
| **Lê Uyên Nhi** | `journey` (Văn hóa, Từ vựng, Tổng kết), `achievements` |

---

## Quy tắc dành cho coding agent

### Phạm vi làm việc

- **Chỉ sửa module thuộc phạm vi công việc** được giao.
- **Không sửa module của thành viên khác** khi chưa trao đổi và ghi rõ lý do.
- Tuân thủ ownership trong [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md).

### Bảo toàn thay đổi hiện có

- **Không hoàn nguyên, xóa hoặc ghi đè** thay đổi chưa commit không liên quan đến nhiệm vụ hiện tại.
- Kiểm tra `git status` trước khi bắt đầu.

### Thiết kế và dữ liệu

- **Không hard-code màu, spacing, radius** trong màn hình — dùng token từ `lib/design_system/`.
- **Không sao chép mock data** vào từng screen — lấy qua provider/repository.
- **Không tự bịa dữ liệu** không có trong tài liệu; đánh dấu `[CẦN XÁC NHẬN]` nếu thiếu thông tin.

### File dùng chung — khi phải sửa

- Các file dưới đây cần **thông báo rõ trong kết quả và Pull Request** trước khi sửa:
  - `pubspec.yaml`
  - `lib/app/app_router.dart`
  - `lib/app/app_theme.dart`
  - `lib/design_system/**`
  - `lib/shared/models/**`, `lib/shared/repositories/**`, `lib/shared/providers/**`
  - `lib/l10n/**`
  - `README.md`, `AGENTS.md`

### Bảo mật

- **Không ghi secret, API key, `.env` thật, hoặc dữ liệu người dùng thật** vào bất kỳ file nào trong repository.
- `supabase_flutter` đã có trong pubspec nhưng **chưa kết nối backend thật** — dùng mock repository.

### Git

- **Không commit, push, merge, force-push hoặc đổi remote** nếu chưa được yêu cầu rõ ràng.
- Không tự ý xóa nhánh của thành viên khác.

---

## Kiểm tra bắt buộc trước khi bàn giao

Chạy đủ bốn lệnh theo thứ tự:

```bash
dart format .
flutter analyze
flutter test
flutter build web
```

Nếu có lỗi trong phạm vi công việc, sửa trước khi báo cáo hoàn thành.

---

## Tài liệu tham chiếu

| Tài liệu | Đường dẫn |
| :--- | :--- |
| Phân công chi tiết | [`docs/PHAN_CONG_CONG_VIEC.md`](docs/PHAN_CONG_CONG_VIEC.md) |
| Ownership module | [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md) |
| Spec nền tảng | [`docs/FOUNDATION_SPEC.md`](docs/FOUNDATION_SPEC.md) |
| Prototype thiết kế | [`design-reference/koreaquest-prototype.html`](design-reference/koreaquest-prototype.html) |
| README | [`README.md`](README.md) |
