# 🇰🇷 KoreaQuest

KoreaQuest là ứng dụng đa nền tảng giúp người dùng khám phá văn hóa, lịch sử và ngôn ngữ Hàn Quốc thông qua các hành trình và nhiệm vụ tương tác.

## 📌 Trạng thái dự án

Dự án hiện đang ở **Phase 1 – Foundation**.

Trong giai đoạn này, nhóm tập trung xây dựng:

* Kiến trúc Flutter dùng chung.
* Design system và component tái sử dụng.
* Điều hướng giữa các module.
* Dữ liệu giả lập.
* Quy trình làm việc nhóm trên GitHub.

Backend, Supabase thật và nghiệp vụ chuyên sâu chưa được triển khai.

## 🚀 Chức năng định hướng

* Khám phá các địa điểm văn hóa Hàn Quốc.
* Hoàn thành nhiệm vụ Check-in, Văn hóa và Từ vựng.
* Tích lũy XP và nâng cấp Level.
* Thu thập huy hiệu và dấu mộc hộ chiếu.
* Theo dõi tiến trình của từng hành trình.
* Quản lý hồ sơ cá nhân.

## 🛠️ Công nghệ sử dụng

* **Framework:** Flutter và Dart.
* **UI:** Material 3.
* **Routing:** `go_router`.
* **State management:** `flutter_riverpod`.
* **Localization:** `flutter_localizations` và `intl`.
* **Kiến trúc:** Feature-first.
* **Dữ liệu hiện tại:** Mock repository.
* **Nền tảng ưu tiên:** Flutter Web.
* **Nền tảng mở rộng:** Android và iOS.

## 📋 Yêu cầu môi trường

* Flutter SDK phiên bản stable phù hợp với dự án.
* Git.
* Chrome để chạy Flutter Web.
* Android Studio, VS Code hoặc IDE hỗ trợ Flutter.

Kiểm tra môi trường Flutter:

```bash
flutter doctor
```

## 🏁 Cài đặt và chạy dự án

Tải repository về máy:

```bash
git clone https://github.com/duongpvhoccntt-star/korea_quest.git
cd korea_quest
```

Cài đặt các dependency:

```bash
flutter pub get
```

Chạy dự án trên Chrome:

```bash
flutter run -d chrome
```

Xem danh sách thiết bị có thể sử dụng:

```bash
flutter devices
```

Chạy trên một thiết bị cụ thể:

```bash
flutter run -d <device-id>
```

> Chỉ cần chạy `git clone` một lần khi tải dự án về máy.

## 📁 Cấu trúc dự án

```text
lib/
├── app/                 # Cấu hình ứng dụng, theme và router
├── core/                # Tiện ích và responsive dùng chung
├── design_system/       # Token và component giao diện
├── shared/              # Model, repository và widget dùng chung
├── features/            # Các module nghiệp vụ
└── l10n/                # Đa ngôn ngữ
```

Các module dự kiến:

```text
features/
├── auth/
├── home/
├── explore/
├── journey/
├── passport/
├── achievements/
├── profile/
├── settings/
└── system_states/
```

## 👥 Quy trình làm việc nhóm

Không lập trình trực tiếp trên nhánh `main`.

Trước khi bắt đầu một chức năng mới, cập nhật nhánh `main` và tạo nhánh riêng:

```bash
git checkout main
git pull origin main
git checkout -b feature/ten-chuc-nang
```

Ví dụ:

```bash
git checkout -b feature/user-profile
```

Quy ước đặt tên nhánh:

* `feature/<ten-chuc-nang>`
* `fix/<ten-loi>`
* `docs/<noi-dung>`
* `refactor/<pham-vi>`

Quy ước nội dung commit:

* `feat:` thêm chức năng.
* `fix:` sửa lỗi.
* `refactor:` cải tổ mã nguồn.
* `docs:` cập nhật tài liệu.
* `test:` thêm hoặc sửa kiểm thử.
* `chore:` cấu hình và bảo trì.

Ví dụ:

```bash
git add .
git commit -m "feat: add user profile page"
git push origin feature/user-profile
```

Sau khi push, tạo Pull Request trên GitHub để đưa thay đổi vào `main`.

Mỗi Pull Request chỉ nên giải quyết một chức năng hoặc một phạm vi rõ ràng. Không tự ý sửa hoặc xóa mã nguồn thuộc module do thành viên khác phụ trách.

## ✅ Kiểm tra trước khi tạo Pull Request

Chạy lần lượt:

```bash
dart format .
flutter analyze
flutter test
flutter build web
```

Chỉ tạo Pull Request khi các lệnh kiểm tra đã chạy thành công.

Không commit thư mục build, cấu hình IDE cá nhân, mật khẩu, API key hoặc secret lên repository.

## 📚 Tài liệu dự án

* [Yêu cầu xây dựng nền tảng](docs/FOUNDATION_SPEC.md)
* [Phân công module](docs/TEAM_OWNERSHIP.md)
* [Kiến trúc dự án](docs/ARCHITECTURE.md)
* [Quy trình GitHub](docs/GIT_WORKFLOW.md)
* [Hướng dẫn đóng góp](CONTRIBUTING.md)
* [Giao diện tham chiếu](design-reference/koreaquest-prototype.html)

Nếu một tài liệu chưa được tạo, tài liệu đó sẽ được bổ sung trong quá trình xây dựng Phase 1.

## 🔐 Bảo mật

Không đưa các nội dung sau lên repository:

* API key.
* Supabase service role key.
* Mật khẩu hoặc access token.
* File `.env` chứa dữ liệu thật.
* File build.
* Cấu hình IDE cá nhân.

## Bắt đầu một feature

1. Đọc AGENTS.md, docs/ARCHITECTURE.md và docs/TEAM_OWNERSHIP.md.
2. Tạo nhánh feature từ main mới nhất theo docs/GIT_WORKFLOW.md.
3. Làm việc trong lib/features/<feature>; chỉ thêm layer có nội dung thật.
4. Dùng token/component trong lib/design_system và dữ liệu qua provider trong lib/shared/providers.
5. Đăng ký URL mới tại lib/app/app_router.dart sau khi phối hợp với nhóm.
6. Chạy đủ format, analyze, test và build web trước khi mở pull request.

Phase 1 hiện cung cấp đầy đủ page shell, routing, design system, mock repository và provider. Xác thực thật, Supabase/backend và nghiệp vụ chuyên sâu được để lại cho giai đoạn sau.



