Bạn đang làm việc trong repository của dự án KoreaQuest. Hãy xây dựng GIAI ĐOẠN 1: NỀN TẢNG FLUTTER WEB DÙNG CHUNG để nhiều thành viên có thể phát triển các chức năng song song mà hạn chế xung đột mã nguồn.

## 1. Mục tiêu

Tạo một nền tảng Flutter Web:

* Chạy được ngay trên trình duyệt.
* Responsive cho desktop, laptop, tablet và điện thoại.
* Có kiến trúc feature-first rõ ràng.
* Mỗi thành viên có thể phụ trách một module độc lập.
* Có design system và component dùng chung.
* Có routing giữa các màn hình mẫu.
* Sử dụng dữ liệu giả lập, chưa kết nối backend.
* Dễ tích hợp Supabase trong giai đoạn sau.
* Dễ chuyển thiết kế prototype KoreaQuest hiện có thành Flutter widget.

Không triển khai sâu toàn bộ nghiệp vụ ở giai đoạn này.

## 2. Trước khi chỉnh sửa

Hãy tự kiểm tra:

* Cấu trúc repository hiện tại.
* Phiên bản Flutter và Dart.
* Các file hướng dẫn như README.md, AGENTS.md hoặc tài liệu kiến trúc.
* Trạng thái Git hiện tại.
* Những thay đổi chưa commit của người dùng.

Nếu dự án Flutter đã tồn tại, hãy giữ nguyên phần đang hoạt động và mở rộng có kiểm soát.

Nếu thư mục chưa có dự án Flutter, hãy khởi tạo Flutter project hỗ trợ Web ngay tại repository hiện tại, không tạo thêm một project lồng bên trong.

Không xóa hoặc ghi đè thay đổi hiện có không liên quan. Không dùng lệnh Git có tính phá hủy. Không push lên remote.

## 3. Công nghệ nền tảng

Sử dụng:

* Flutter stable.
* Dart null safety.
* Material 3.
* go_router cho điều hướng.
* flutter_riverpod cho quản lý trạng thái và dependency injection.
* flutter_localizations và intl để chuẩn bị đa ngôn ngữ.
* Dữ liệu mock cục bộ.
* Repository interface để sau này thay mock repository bằng Supabase repository.

Chỉ thêm package khi thực sự cần thiết. Không thêm quá nhiều dependency hoặc code generator trong giai đoạn nền tảng.

## 4. Kiến trúc thư mục

Tổ chức source code theo cấu trúc feature-first tương tự:

lib/
main.dart
app/
app.dart
app_router.dart
app_theme.dart
app_config.dart
core/
constants/
errors/
extensions/
responsive/
utils/
design_system/
colors/
typography/
spacing/
radius/
shadows/
components/
shared/
models/
repositories/
services/
widgets/
features/
landing/
auth/
home/
explore/
journey/
passport/
achievements/
profile/
settings/
system_states/
l10n/

Mỗi feature nên có cấu trúc phù hợp:

feature_name/
data/
domain/
presentation/
pages/
widgets/
providers/

Không bắt buộc tạo file rỗng cho mọi tầng. Chỉ tạo những file có nội dung thực tế và hữu ích.

Không đặt toàn bộ giao diện hoặc logic vào main.dart.

## 5. Phân chia module cho nhóm

Chuẩn bị không gian làm việc độc lập:

* Nền tảng chung: app, core, design_system, shared.
* Thành viên Auth: features/auth.
* Thành viên Trang chủ: features/home.
* Thành viên Khám phá: features/explore.
* Thành viên Hành trình: features/journey.
* Phạm Văn Dương: features/passport, features/achievements, features/profile và XP/Level dùng chung.
* Thành viên Cài đặt và trạng thái: features/settings, features/system_states.

Tạo file `docs/TEAM_OWNERSHIP.md` ghi rõ:

* Module.
* Thư mục phụ trách.
* Thành viên phụ trách nếu đã biết.
* Các file dùng chung cần trao đổi trước khi sửa.
* Quy tắc không sửa trực tiếp module của người khác.

Các file có nguy cơ xung đột cao cần được ghi chú:

* pubspec.yaml
* lib/app/app_router.dart
* lib/app/app_theme.dart
* Các token trong design_system
* File localization
* README.md

## 6. Design system KoreaQuest

Tạo bộ token dùng chung, tránh hard-code màu và kích thước trong màn hình:

* Navy/chàm: màu nền đậm và tiêu đề.
* Đỏ san hô: hành động chính.
* Trắng kem: nền chính.
* Vàng: XP, Level và phần thưởng.
* Xanh lá: hoàn thành.
* Xám: chưa mở khóa hoặc vô hiệu hóa.

Chuẩn bị:

* AppColors.
* AppTypography.
* AppSpacing.
* AppRadius.
* AppShadows.
* ResponsiveBreakpoints.
* AppTheme sáng.

Font phải hiển thị tốt tiếng Việt và tiếng Hàn. Nếu dùng font tải từ mạng, phải có giải pháp fallback an toàn.

Tạo các component nền tảng:

* AppScaffold.
* AppHeader.
* AppFooter.
* PrimaryButton.
* SecondaryButton.
* DangerButton.
* AppTextField.
* PasswordField.
* SearchField.
* UserAvatar.
* StatusChip.
* XPProgressBar.
* LevelBadge.
* LoadingIndicator.
* EmptyState.
* ErrorState.
* ResponsiveContent.
* ConfirmationDialog.
* Toast/Snackbar helper.

Component phải hỗ trợ các trạng thái phù hợp như default, hover, focus, disabled, loading, error, success, locked và completed.

Đảm bảo vùng bấm đủ lớn, độ tương phản dễ đọc và trạng thái không chỉ được thể hiện bằng màu sắc.

## 7. Model và dữ liệu mẫu dùng chung

Tạo các model nền tảng, có kiểu dữ liệu rõ ràng:

* AppUser.
* UserProgress.
* Location.
* JourneyProgress.
* Achievement.
* PassportStamp.
* Mission.
* XPTransaction nếu cần.

Sử dụng enum thay cho chuỗi tùy ý cho các trạng thái như:

* LocationStatus.
* MissionStatus.
* JourneyStage.
* AchievementStatus.

Tạo mock repository và dữ liệu thống nhất:

Người dùng:

* Họ tên: Phạm Văn Dương.
* Tên hiển thị: Dương.
* Level: 5.
* XP hiện tại: 1.250 XP.
* Mốc Level tiếp theo: 1.500 XP.
* Chuỗi khám phá: 7 ngày.
* Ngày tham gia: 02/08/2026.

Địa điểm:

* Cung điện Gyeongbokgung: đã hoàn thành.
* Làng Bukchon Hanok: đang thực hiện.
* Tháp Namsan: chưa bắt đầu.
* Đảo Jeju: chưa mở khóa.

Huy hiệu:

* Nhà thám hiểm đầu tiên.
* Người yêu lịch sử.
* Cao thủ từ vựng.
* Hành trình 7 ngày.

Các feature phải lấy dữ liệu qua provider/repository, không sao chép lại dữ liệu mẫu trong từng màn hình.

## 8. Routing và màn hình mẫu

Tạo named routes với URL thân thiện:

* `/`
* `/register`
* `/login`
* `/forgot-password`
* `/home`
* `/explore`
* `/locations/:locationId`
* `/journey/:locationId`
* `/journey/:locationId/check-in`
* `/journey/:locationId/culture`
* `/journey/:locationId/vocabulary`
* `/journey/:locationId/summary`
* `/passport`
* `/achievements`
* `/profile`
* `/profile/edit`
* `/settings`
* `/403`
* `/offline`
* `/error`
* Route 404.

Mỗi route cần có một trang khung tối thiểu nhưng chạy được:

* Tiêu đề trang.
* Mô tả module.
* Component dùng chung.
* Dữ liệu mock phù hợp.
* Nút điều hướng thử.

Các trang khung không cần hoàn thiện thiết kế chi tiết. Mục đích là kiểm tra routing, responsive, theme và ranh giới module.

Tạo AppShell dùng chung cho các trang sau đăng nhập. Trên desktop dùng header; không dùng bottom navigation làm điều hướng desktop.

## 9. Responsive

Chuẩn bị breakpoint rõ ràng, ví dụ:

* Mobile: dưới 600 px.
* Tablet: 600–1023 px.
* Desktop: từ 1024 px.
* Nội dung desktop tối ưu cho khung 1440 × 900 px.

Không kiểm tra kích thước màn hình rải rác trong từng widget. Gom logic responsive vào core/responsive hoặc component dùng chung.

Kiểm tra để không bị tràn nội dung ở các kích thước phổ biến.



## 10. Quy trình GitHub cho nhóm

Repository đã được tạo trên GitHub và đang được nhiều thành viên sử dụng.

Trước khi thay đổi mã nguồn, hãy kiểm tra:

- Remote repository hiện tại.
- Nhánh đang làm việc.
- Các nhánh đã tồn tại.
- Trạng thái Git và thay đổi chưa commit.
- Workflow, pull request template và tài liệu Git hiện có.

Không khởi tạo lại Git, không thay đổi remote, không force-push và không xóa
nhánh của thành viên khác.

Tạo hoặc cập nhật `docs/GIT_WORKFLOW.md` với quy trình:

1. Nhánh `main` chỉ chứa phiên bản ổn định.
2. Không lập trình trực tiếp trên `main`.
3. Mỗi chức năng dùng một nhánh riêng:
   - `feature/<ten-chuc-nang>`
   - `fix/<ten-loi>`
   - `docs/<noi-dung>`
   - `refactor/<pham-vi>`
4. Trước khi bắt đầu:
   - Cập nhật nhánh `main`.
   - Tạo nhánh mới từ `main` mới nhất.
5. Mỗi pull request chỉ giải quyết một chức năng hoặc một phạm vi rõ ràng.
6. Trước khi tạo pull request phải chạy:
   - `dart format .`
   - `flutter analyze`
   - `flutter test`
7. Không merge khi kiểm tra tự động chưa thành công.
8. Không tự merge pull request của mình nếu nhóm yêu cầu review.
9. Khi xảy ra conflict, người phụ trách module phải phối hợp giải quyết,
   không tự ý xóa mã của thành viên khác.
10. Không commit secret, API key, file build hoặc cấu hình IDE cá nhân.
Thêm quy ước commit ngắn gọn:

* feat:
* fix:
* refactor:
* docs:
* test:
* chore:

## 11. AGENTS.md

Tạo hoặc cập nhật `AGENTS.md` ở thư mục gốc để Codex và các coding agent khác hiểu dự án.

Nội dung cần nêu:

* Mục tiêu KoreaQuest.
* Công nghệ sử dụng.
* Kiến trúc feature-first.
* Quy tắc chỉ sửa module liên quan.
* Không ghi đè thay đổi của thành viên khác.
* Không hard-code token thiết kế và dữ liệu dùng chung.
* Không kết nối backend thật trong giai đoạn này.
* Các lệnh bắt buộc trước khi bàn giao.
* Yêu cầu cập nhật tài liệu khi thay đổi kiến trúc.

Nếu đã có AGENTS.md, hãy đọc kỹ rồi cập nhật có kiểm soát, không xóa quy tắc đang hữu ích.

## 12. Kiểm thử nền tảng

Tạo một số test có giá trị thực tế:

* Test tính toán phần trăm XP.
* Test trạng thái Level.
* Test một component dùng chung.
* Test router hoặc trang chính nếu phù hợp.
* Test mock repository trả dữ liệu nhất quán.

Sau khi triển khai, bắt buộc chạy:

* `dart format .`
* `flutter pub get`
* `flutter analyze`
* `flutter test`
* `flutter build web`

Nếu có lỗi, hãy sửa lỗi thuộc phạm vi công việc này rồi chạy lại.

## 13. README

Cập nhật README.md bằng tiếng Việt, gồm:

* Giới thiệu KoreaQuest.
* Yêu cầu môi trường.
* Cách cài Flutter.
* Cách chạy Flutter Web.
* Cách chạy analyze và test.
* Cách build web.
* Kiến trúc thư mục.
* Cách một thành viên bắt đầu làm feature mới.
* Quy trình tạo branch và pull request.
* Danh sách module.
* Trạng thái hiện tại: Foundation/Phase 1.
* Những phần chưa triển khai: backend, Supabase thật và logic nghiệp vụ sâu.

## 14. Giới hạn

Trong giai đoạn này không được:

* Kết nối Supabase thật.
* Tạo backend.
* Thêm thanh toán, cửa hàng, mạng xã hội hoặc chat.
* Triển khai toàn bộ giao diện chi tiết.
* Đặt tất cả code trong một file.
* Tự ý thay đổi dữ liệu và định hướng KoreaQuest.
* Push hoặc force-push lên GitHub.
* Xóa thay đổi có sẵn của người dùng.
* Tạo commit nếu người dùng chưa yêu cầu.

## 15. Tiêu chí hoàn thành

Chỉ coi là hoàn thành khi:

* Flutter Web chạy được.
* Các route mẫu điều hướng được.
* Design system được sử dụng trong màn hình mẫu.
* Dữ liệu mock được lấy qua repository/provider.
* Các module được tách rõ.
* Không có lỗi `flutter analyze`.
* Toàn bộ test vượt qua.
* `flutter build web` thành công.
* Tài liệu cho nhóm đã đầy đủ.
* Không có secret trong repository.

Hãy thực hiện trọn vẹn công việc, không chỉ viết kế hoạch.

Khi hoàn thành, hãy báo cáo ngắn gọn:

1. Những gì đã tạo hoặc thay đổi.
2. Cấu trúc module hiện tại.
3. Kết quả analyze, test và build.
4. Những giả định đã sử dụng.
5. Các file dùng chung mà thành viên cần cẩn thận khi sửa.
6. Việc đầu tiên mỗi thành viên nên làm để bắt đầu module của mình.
7. Những phần được để lại cho giai đoạn tiếp theo.
