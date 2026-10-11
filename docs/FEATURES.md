# KoreaQuest — Tổng hợp Tính năng Dự án

> **Ghi chú**: Tài liệu này liệt kê các tính năng **thực sự được triển khai** trong codebase, không phải ý tưởng hay kế hoạch tương lai. Cập nhật lần cuối: 2026-10-10.

---

## Mục lục

1. [Xác thực & Tài khoản](#1-xác-thực--tài-khoản)
2. [Khám phá địa điểm (Explore)](#2-khám-phá-địa-điểm-explore)
3. [Nội dung địa điểm (Location Content)](#3-nội-dung-địa-điểm-location-content)
4. [Hệ thống tiến trình & XP](#4-hệ-thống-tiến-trình--xp)
5. [Hộ chiếu (Passport)](#5-hộ-chiếu-passport)
6. [Thành tích (Achievements)](#6-thành-tích-achievements)
7. [Hồ sơ người dùng (Profile)](#7-hồ-sơ-người-dùng-profile)
8. [Hành trình (Journey)](#8-hành-trình-journey)
9. [Admin — Quản trị nội dung](#9-admin--quản-trị-nội-dung)
10. [Đa ngôn ngữ (i18n)](#10-đa-ngôn-ngữ-i18n)
11. [Hạ tầng & Kỹ thuật](#11-hạ-tầng--kỹ-thuật)
12. [Tính năng phụ & Tiện ích](#12-tính-năng-phụ--tiện-ích)

---

## 1. Xác thực & Tài khoản

### Tính năng chính
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Đăng ký tài khoản (Email + Password) | ✅ Hoàn chỉnh | Có xác thực form, confirm password, full name + display name |
| Đăng nhập Email/Password | ✅ Hoàn chỉnh | Redirect sau login, xử lý admin vs user |
| Quên mật khẩu / Reset qua Email | ✅ Hoàn chỉnh | Gửi email reset, chuyển về login sau khi gửi |
| Đổi mật khẩu (khi đã đăng nhập) | ✅ Hoàn chỉnh | Trong trang Settings |
| Đăng xuất | ✅ Hoàn chỉnh | Có confirm dialog |

### Chế độ Khách (Guest Mode)
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Khám phá với tư cách Khách (không cần tài khoản) | ✅ Hoàn chỉnh | Nút "Khám phá với tư cách Khách" trên trang auth |
| Chơi với tên Khách tự chọn | ✅ Hoàn chỉnh | Dialog nhập tên hiển thị (`guest_name_dialog.dart`) |
| Giới hạn đường dẫn cho Khách | ✅ Hoàn chỉnh | Chỉ cho phép `/explore`, `/locations/*`, `/journey/*`, `/passport/shared/*` |
| Prompt đăng ký khi hoàn thành địa điểm | ✅ Hoàn chỉnh | `GuestRegistrationPromptDialog` hiện sau khi Khách hoàn thành |
| Điền trước tên Khách vào form đăng ký | ✅ Hoàn chỉnh | Truyền `prefilledName` sang trang register |

### Demo / Quick Login
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Quick login Admin (demo mode) | ✅ Hoàn chỉnh | Chỉ hiện khi `!AppConfig.hasSupabaseConfiguration` hoặc `adminDemoMode` |
| Quick login Student (demo mode) | ✅ Hoàn chỉnh | Tài khoản demo `duong@example.com` |

---

## 2. Khám phá địa điểm (Explore)

### Tính năng chính
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Danh sách địa điểm đã publish | ✅ Hoàn chỉnh | Kết nối Supabase RPC `list_published_locations` |
| Bản đồ tương tác (MapTiler) | ✅ Hoàn chỉnh | `KoreaLocationsMap` widget, chọn địa điểm trên bản đồ |
| Chuyển đổi Map ↔ Danh sách (List) | ✅ Hoàn chỉnh | Toggle button trong header map |
| Tìm kiếm địa điểm (search) | ✅ Hoàn chỉnh | Tìm theo tên, tên tiếng Hàn, thành phố, mô tả, category |
| Lọc theo category / thành phố | ✅ Hoàn chỉnh | ChoiceChip filter bar, tối đa 12 filter |
| Lọc "Sắp ra mắt" (Coming Soon) | ✅ Hoàn chỉnh | Filter riêng cho địa điểm chưa phát hành |
| Preview card địa điểm (khi chọn trên map) | ✅ Hoàn chỉnh | `_DestinationPreviewCard` với ảnh, tên, mô tả, thời gian |
| Gợi ý địa điểm (Recommendation Strip) | ✅ Hoàn chỉnh | Top 3 địa điểm đầu tiên |
| Badge collection trên trang Explore | ✅ Hoàn chỉnh | Hiện huy hiệu đã nhận |
| Panel cá nhân (tiến độ, điểm đến tiếp theo) | ✅ Hoàn chỉnh | Tùy layout wide/narrow |
| Layout responsive (wide/narrow) | ✅ Hoàn chỉnh | Breakpoint 1050px: sidebar + map vs stacked |

### Địa điểm hiện có (Seeded)
| Địa điểm | Trạng thái |
|----------|-----------|
| Cung điện Gyeongbokgung (경복궁) | ✅ Released |
| Tháp Namsan (남산서울타워) | ✅ Released |
| Làng Bukchon Hanok (북촌한옥마을) | ✅ Released |
| Đảo Jeju (제주도) | 🔜 Coming Soon |

---

## 3. Nội dung địa điểm (Location Content)

### Cấu trúc nội dung (các Stage)
Mỗi địa điểm có nhiều **stage** (chặng), mỗi stage là một trang nội dung:

| Stage | Nội dung |
|-------|---------|
| Mở đầu (Intro) | Tổng quan ngắn, ảnh đại diện |
| Tổng quan (Overview) | Mô tả chung địa điểm |
| Lịch sử (History) | Nội dung lịch sử có thể phân trang |
| Điểm đến (Highlights) | Các điểm tham quan nổi bật |
| Trải nghiệm (Experience) | Hoạt động có thể làm tại địa điểm |
| Ẩm thực (Food) | Đặc sản ẩm thực |
| Fun Facts | Sự thật thú vị |
| Quiz tổng kết (Final Quiz) | Câu hỏi trắc nghiệm để kiếm XP |
| Du lịch (Travel Tips) | Thông tin thực tiễn khi đến thăm |

### Tính năng nội dung
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Đọc nội dung phân stage | ✅ Hoàn chỉnh | Điều hướng qua các stage bằng `stageNumber` param |
| Image gallery (tối đa 10 ảnh/section) | ✅ Hoàn chỉnh | `ContentImageGallery` widget, hiển thị 1 ảnh tại một thời điểm |
| Nhúng video YouTube | ✅ Hoàn chỉnh | `YoutubePlayer` widget (web + stub) |
| Read Aloud / Text-to-Speech | ✅ Hoàn chỉnh | `ContentReadAloudControls` widget |
| Quiz trắc nghiệm + chấm điểm | ✅ Hoàn chỉnh | Gửi đáp án qua `submitQuizAnswer`, nhận kết quả + XP reward |
| Hiển thị XP reward sau quiz | ✅ Hoàn chỉnh | Toast/snackbar hiện điểm nhận được |
| Hoàn thành stage để mở stage tiếp | ✅ Hoàn chỉnh | `completeStage` RPC |
| Prompt đăng ký sau khi Khách hoàn thành | ✅ Hoàn chỉnh | Hiện dialog khi `isGuest == true` và stage cuối |
| Fallback locale (Vi khi thiếu bản dịch) | ✅ Hoàn chỉnh | `isFallback` flag, badge "Bản tiếng Việt" |
| Tọa độ GPS cho địa điểm (lat/lng) | ✅ Hoàn chỉnh | Expose qua migration `expose_location_coordinates` |

---

## 4. Hệ thống tiến trình & XP

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Hệ thống Level (cấp độ) | ✅ Hoàn chỉnh | `UserProgress.level`, RPC `get_my_progress` |
| Điểm XP | ✅ Hoàn chỉnh | Cộng XP khi hoàn thành quiz, stage, địa điểm |
| Thanh tiến trình XP lên cấp | ✅ Hoàn chỉnh | `XpProgressBar` widget |
| Streak (chuỗi ngày liên tục) | ✅ Hoàn chỉnh | `streakDays`, ghi nhận qua `record_daily_visit` |
| XP Ledger (lý do cộng XP) | ✅ Hoàn chỉnh | Bảng `xp_ledger` trong DB, migration `add_progression_xp_reasons` |
| Reset tiến trình | ✅ Hoàn chỉnh | RPC `reset_my_progress`, có trong Settings |
| Cấp độ tối đa (max level) | ✅ Hoàn chỉnh | `isMaxLevel` flag trong UserProgress |
| Title theo cấp độ | ✅ Hoàn chỉnh | Field `title` trong `get_my_progress` response |

---

## 5. Hộ chiếu (Passport)

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Trang hộ chiếu cá nhân | ✅ Hoàn chỉnh | Hiển thị thông tin user, level, XP, streak |
| Dấu mộc (Passport Stamp) | ✅ Hoàn chỉnh | Mỗi địa điểm hoàn thành → 1 stamp với seal ký tự |
| Tạo link chia sẻ hộ chiếu | ✅ Hoàn chỉnh | RPC `regenerate_passport_share_link`, tạo token unique |
| Sao chép link chia sẻ | ✅ Hoàn chỉnh | Clipboard copy, dialog hiện link |
| Thu hồi link chia sẻ | ✅ Hoàn chỉnh | RPC `revoke_passport_share_link` |
| Trang hộ chiếu công khai (shared) | ✅ Hoàn chỉnh | Route `/passport/shared/:token`, `SharedPassportPage` |
| Xem hộ chiếu người khác (chỉ đọc) | ✅ Hoàn chỉnh | Hiển thị tên, level, stamps, achievements |
| Truy cập trang shared không cần đăng nhập | ✅ Hoàn chỉnh | Route được phép cho cả guest |

---

## 6. Thành tích (Achievements)

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Trang thành tích | ✅ Hoàn chỉnh | Grid view các badge |
| Filter: Tất cả / Đã đạt / Chưa đạt | ✅ Hoàn chỉnh | `SegmentedButton` 3 tab |
| Badge icon (emoji) | ✅ Hoàn chỉnh | Field `icon` trong Achievement model |
| Hiển thị badge trên Explore page | ✅ Hoàn chỉnh | `_BadgeCollection` widget |
| Kết nối Supabase `get_my_achievements` | ✅ Hoàn chỉnh | Trả về `[]` khi chưa đăng nhập (guest-safe) |

---

## 7. Hồ sơ người dùng (Profile)

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Trang hồ sơ | ✅ Hoàn chỉnh | Hero section + dashboard thống kê |
| Chỉnh sửa hồ sơ | ✅ Hoàn chỉnh | Full name, display name, bio |
| Chọn avatar preset | ✅ Hoàn chỉnh | `AvatarSelectorModal`, chọn từ bộ avatar có sẵn |
| Upload ảnh avatar tùy chỉnh | ✅ Hoàn chỉnh | Upload `Uint8List` bytes lên Supabase |
| Thống kê: địa điểm đã hoàn thành | ✅ Hoàn chỉnh | Đếm từ danh sách locations |
| Thống kê: level, XP, streak | ✅ Hoàn chỉnh | Từ `userProgressProvider` |
| Ngày tham gia | ✅ Hoàn chỉnh | `joinedDate` từ profile |

---

## 8. Hành trình (Journey)

> **Lưu ý**: Journey hiện là **scaffold / framework**, logic chấm điểm thực tế đã được chuyển sang hệ thống Location Content (stage-based).

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Danh sách mission trong hành trình | ✅ Có (scaffold) | Hiển thị mission list với status icon |
| 4 stage: Check-in, Văn hóa, Từ vựng, Tổng kết | ✅ Có (scaffold) | Điều hướng tuần tự qua các stage |
| Hiển thị trạng thái mission | ✅ Hoàn chỉnh | Color-coded icon: not started / in progress / completed |
| Prompt đăng ký khi Khách hoàn thành hành trình | ✅ Hoàn chỉnh | Trigger khi `stage == summary && isGuest` |
| Mock data đầy đủ cho Gyeongbokgung + Jeju | ✅ Hoàn chỉnh | 9 missions cho Jeju, 3 missions default |

---

## 9. Admin — Quản trị nội dung

### Truy cập Admin
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Đăng nhập Admin (Supabase Auth) | ✅ Hoàn chỉnh | Kiểm tra role `is_admin` trong DB |
| Demo Admin login (không cần Supabase) | ✅ Hoàn chỉnh | `adminDemoMode` flag |
| Redirect về `/admin` sau đăng nhập Admin | ✅ Hoàn chỉnh | |

### Quản lý địa điểm
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Dashboard danh sách địa điểm | ✅ Hoàn chỉnh | `AdminDashboard` widget |
| Tạo địa điểm mới | ✅ Hoàn chỉnh | Form đầy đủ 10 bước |
| Chỉnh sửa địa điểm | ✅ Hoàn chỉnh | Load draft từ DB, edit, save |
| Publish / Archive địa điểm | ✅ Hoàn chỉnh | `PublishAction` trong editor |

### Editor 10 bước (Location Editor)
| Bước | Nội dung |
|------|---------|
| Bước 1 — Mở đầu | Slug, tên, tên Hàn, thành phố, mô tả ngắn, thời gian ước tính |
| Bước 2 — Tổng quan | Mô tả tổng quan dài |
| Bước 3 — Lịch sử | Nội dung lịch sử |
| Bước 4 — Điểm đến | Highlights (gallery, mô tả) |
| Bước 5 — Trải nghiệm | Experience sections |
| Bước 6 — Ẩm thực | Food sections |
| Bước 7 — Fun Facts | Danh sách fun facts |
| Bước 8 — Quiz | Câu hỏi trắc nghiệm (tạo, sửa, xóa) |
| Bước 9 — Du lịch | Travel tips (giờ mở cửa, giá vé, giao thông) |
| Bước 10 — Kiểm tra & Xuất bản | Validation + publish |

### Quản lý nội dung nâng cao
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Biên tập đa ngôn ngữ (Vi / En / Ko) | ✅ Hoàn chỉnh | `LocationTranslationEditor`, tab theo locale |
| Upload ảnh vào gallery | ✅ Hoàn chỉnh | `AdminImageUploadButton` → Supabase Storage |
| Quản lý gallery ảnh (sắp xếp, xóa) | ✅ Hoàn chỉnh | `AdminImageGalleryEditor` |
| Thêm/sửa/xóa câu hỏi Quiz | ✅ Hoàn chỉnh | `LocationEditorQuiz` với highlight khi có lỗi |
| Cấu hình Game (XP rules) | ✅ Hoàn chỉnh | `GameConfigAdmin` widget |
| Validation trước publish | ✅ Hoàn chỉnh | Danh sách lỗi, highlight bước bị lỗi |
| Auto-save draft | ✅ Hoàn chỉnh | Dirty-tracking theo step, lưu khi chuyển bước |
| `AdminDiagnostic` item index | ✅ Hoàn chỉnh | Định vị chính xác câu hỏi/section bị lỗi |

---

## 10. Đa ngôn ngữ (i18n)

| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Tiếng Việt (vi) | ✅ Mặc định | File `app_vi.arb` (~200+ keys) |
| Tiếng Anh (en) | ✅ Hoàn chỉnh | File `app_en.arb` |
| Tiếng Hàn (ko) | ✅ Hoàn chỉnh | File `app_ko.arb` |
| Tự nhận ngôn ngữ thiết bị | ✅ Hoàn chỉnh | `localeProvider`, theo device locale |
| Ghi nhớ lựa chọn ngôn ngữ | ✅ Hoàn chỉnh | Persist qua `localeController` |
| Chọn ngôn ngữ thủ công trong Settings | ✅ Hoàn chỉnh | Dropdown trong `SettingsPage` |
| Fallback locale cho nội dung địa điểm | ✅ Hoàn chỉnh | Hiện badge "Bản tiếng Việt" khi thiếu bản dịch |

---

## 11. Hạ tầng & Kỹ thuật

### Backend — Supabase
| Thành phần | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| 27 Database migrations | ✅ Deployed | Toàn bộ schema, RLS policy, seed data |
| RLS (Row Level Security) | ✅ Hoàn chỉnh | Phân quyền anon / user / admin |
| Supabase Storage (ảnh) | ✅ Hoàn chỉnh | Bucket `content-media`, upload từ Admin |
| Edge Function: `translate-location` | ✅ Deployed | Dịch nội dung địa điểm tự động |
| Edge Function: `suggest-location-coordinates` | ✅ Deployed | Gợi ý tọa độ GPS cho địa điểm mới |
| RPC `list_published_locations` | ✅ Hoàn chỉnh | Public, không cần auth |
| RPC `get_my_progress` | ✅ Hoàn chỉnh | Level, XP, streak của user |
| RPC `get_my_achievements` | ✅ Hoàn chỉnh | Danh sách huy hiệu |
| RPC `get_my_passport` | ✅ Hoàn chỉnh | Stamps + thông tin passport |
| RPC `submit_quiz_answer` | ✅ Hoàn chỉnh | Chấm điểm quiz, cộng XP |
| RPC `complete_stage` | ✅ Hoàn chỉnh | Hoàn thành stage, cộng XP |
| RPC `regenerate/revoke_passport_share_link` | ✅ Hoàn chỉnh | Quản lý link chia sẻ |
| RPC `record_daily_visit` | ✅ Hoàn chỉnh | Ghi nhận visit, cập nhật streak |
| RPC `reset_my_progress` | ✅ Hoàn chỉnh | Reset toàn bộ tiến độ user |

### Frontend — Flutter Web
| Thành phần | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Flutter Web (Chrome) | ✅ Hoàn chỉnh | Target platform chính |
| go_router navigation | ✅ Hoàn chỉnh | Hash-based routing (`#/explore`) |
| Riverpod state management | ✅ Hoàn chỉnh | FutureProvider, StateNotifierProvider |
| Design System riêng | ✅ Hoàn chỉnh | Colors, Spacing, Radius, Shadows, Components |
| Responsive layout | ✅ Hoàn chỉnh | Breakpoints cho mobile/tablet/desktop |
| Repository Pattern | ✅ Hoàn chỉnh | Interface + Mock + Supabase impl |
| Feature flag (Supabase vs Mock) | ✅ Hoàn chỉnh | `AppConfig.hasSupabaseConfiguration` |
| CI/CD GitHub Actions | ✅ Hoàn chỉnh | Deploy web tự động |
| pgTAP database tests | ✅ Hoàn chỉnh | 83 test cases |

---

## 12. Tính năng phụ & Tiện ích

### Navigation & UX
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Header nav (Khám phá, Hộ chiếu, Thành tích, Hồ sơ) | ✅ Hoàn chỉnh | Responsive, collapse trên mobile |
| Footer | ✅ Hoàn chỉnh | Hiện ở trang auth và landing |
| Trang Landing | ✅ Hoàn chỉnh | Trang giới thiệu dự án |
| Redirect về `/explore` sau đăng nhập | ✅ Hoàn chỉnh | Default redirect target |
| Route `/home` → redirect `/explore` | ✅ Hoàn chỉnh | Backward compat |
| Trang 403 Forbidden | ✅ Hoàn chỉnh | `SystemStatePage(kind: forbidden)` |
| Trang 404 Not Found | ✅ Hoàn chỉnh | GoRouter errorBuilder |
| Trang Offline | ✅ Hoàn chỉnh | `SystemStatePage(kind: offline)` |
| Auth guard (redirect về login) | ✅ Hoàn chỉnh | GoRouter redirect middleware |

### Settings
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Chọn ngôn ngữ ứng dụng | ✅ Hoàn chỉnh | 3 ngôn ngữ: Vi / En / Ko |
| Đổi mật khẩu | ✅ Hoàn chỉnh | `ChangePasswordDialog` |
| Reset tiến trình học | ✅ Hoàn chỉnh | Confirm dialog, gọi `reset_my_progress` |

### Toast & Feedback
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Toast notification (`AppToast`) | ✅ Hoàn chỉnh | Hiện thông báo thành công/lỗi |
| Loading indicator | ✅ Hoàn chỉnh | `LoadingIndicator` widget |
| Empty state | ✅ Hoàn chỉnh | `EmptyState` widget có action |
| Error state với retry | ✅ Hoàn chỉnh | `ErrorState` widget có nút Thử lại |

### Bản đồ
| Tính năng | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Bản đồ Hàn Quốc (MapTiler) | ✅ Hoàn chỉnh | `KoreaLocationsMap` widget |
| Marker cho địa điểm trên bản đồ | ✅ Hoàn chỉnh | Released vs Coming Soon khác màu |
| Chọn địa điểm từ marker | ✅ Hoàn chỉnh | `onPlaceSelected` callback |
| Reset zoom/view bản đồ | ✅ Hoàn chỉnh | Nút "Reset map" |
| Fallback list khi bản đồ không load | ✅ Hoàn chỉnh | `unavailableBuilder` → `_DestinationList` |

---

## Tóm tắt số liệu

| Hạng mục | Con số |
|---------|--------|
| Feature modules | 10 modules |
| Tổng file `.dart` trong `lib/` | ~70 files |
| Database migrations | 27 |
| Edge Functions (Supabase) | 2 |
| Database RPC functions | ~15 |
| Ngôn ngữ giao diện | 3 (Vi / En / Ko) |
| Địa điểm đã seed | 3 released + 1 coming soon |
| pgTAP test cases | 83 |
