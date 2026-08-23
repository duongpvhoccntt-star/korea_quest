# 👥 TEAM OWNERSHIP — KOREAQUEST

> **Nguồn chính xác:** [`docs/PHAN_CONG_CONG_VIEC.md`](PHAN_CONG_CONG_VIEC.md)  
> **Cập nhật:** 2026-08-11  
> **Giai đoạn:** MVP — game-based learning khám phá văn hóa Hàn Quốc

---

## Nguyên tắc cốt lõi

Nhóm chia công việc theo **tính năng**, không chia riêng frontend/backend.  
**Ai phụ trách tính năng nào thì chịu trách nhiệm toàn bộ:** frontend, logic, database, API/backend, lưu tiến độ và kiểm thử.

---

## Bảng phân công tổng quan

| Thành viên | Cụm tính năng |
| :--- | :--- |
| **Phạm Văn Dương** | Tài khoản · Trang chủ · Hồ sơ · Hộ chiếu |
| **Nguyễn Viết Thức** | Bản đồ · Địa điểm · Check-in |
| **Lê Uyên Nhi** | Văn hóa · Từ vựng · Tổng kết · Phần thưởng |

---

## 1. Phạm Văn Dương

### Tính năng phụ trách

| Tính năng | Thư mục dự kiến |
| :--- | :--- |
| Đăng ký | `lib/features/auth/` |
| Đăng nhập | `lib/features/auth/` |
| Đăng xuất | `lib/features/auth/` |
| Trang chủ (Home) | `lib/features/home/` |
| Hệ thống Level | `lib/shared/models/`, `lib/features/home/` |
| Hồ sơ người dùng (Profile) | `lib/features/profile/` |
| Hộ chiếu khám phá (Passport) | `lib/features/passport/` |
| Hiển thị huy hiệu | `lib/features/passport/` |
| Hiển thị dấu mộc | `lib/features/passport/` |

### Database phụ trách

```
users          (id, name, email, avatar_url, xp, level, created_at)
user_badges    (đọc — Nhi trao)
user_stamps    (đọc — Nhi trao)
```

### API phụ trách

```
POST /auth/register
POST /auth/login
GET  /me/home
GET  /me/passport
```

### Luồng bàn giao

```
Đăng ký → Đăng nhập → Trang chủ → Xem XP / Level → Xem Hộ chiếu → Xem huy hiệu / dấu mộc
```

### Điểm tích hợp

| Nhận từ | Nội dung |
| :--- | :--- |
| **Nguyễn Viết Thức** | `user_id`, `location_id` khi người dùng chọn địa điểm |
| **Lê Uyên Nhi** | `xp`, `badge`, `stamp` sau khi hoàn thành địa điểm — Dương hiển thị trong Trang chủ và Hộ chiếu |

---

## 2. Nguyễn Viết Thức

### Tính năng phụ trách

| Tính năng | Thư mục dự kiến |
| :--- | :--- |
| Bản đồ khám phá | `lib/features/explore/` |
| Danh sách địa điểm | `lib/features/explore/` |
| Chi tiết địa điểm (trang giới thiệu) | `lib/features/journey/` |
| Check-in (mô tả, lịch sử, timeline) | `lib/features/journey/` |
| Gallery ảnh | `lib/features/journey/` |
| Video giới thiệu | `lib/features/journey/` |
| Quiz Check-in | `lib/features/journey/` |
| Lưu tiến độ Check-in | `lib/features/journey/` |

### Trạng thái địa điểm trên bản đồ

```
Completed | Current | Unlocked | Locked
```

### Database phụ trách

```
locations              (id, name, slug, description, thumbnail_url, order_number, unlock_condition, status)
location_checkin       (location_id, introduction, address, highlight, description)
location_history       (id, location_id, year, title, content, order_number)
location_media         (id, location_id, type, url, caption)   -- type: image | video
checkin_questions      (id, location_id, question, explanation, order_number)
checkin_answers        (id, question_id, answer, is_correct)
user_checkin_progress  (user_id, location_id, question_id, selected_answer, completed, correct, completed_at)
```

### API phụ trách

```
GET /locations
GET /locations/:id
```

### Luồng bàn giao

```
Bản đồ → Chọn địa điểm → Xem giới thiệu → Bắt đầu Check-in
→ Xem mô tả / lịch sử / ảnh / video → Làm nhiệm vụ
→ Hoàn thành Check-in → Mở Văn hóa (Nhi nhận)
```

### Điều kiện mở phần tiếp theo

```
completed_questions == total_questions  →  Check-in hoàn thành
→ Nhi được phép mở phần Văn hóa
```

### Điểm tích hợp

| Nhận từ | Nội dung |
| :--- | :--- |
| **Phạm Văn Dương** | `user_id`, `location_id` khi người dùng chọn địa điểm |
| **Lê Uyên Nhi** | `next_location_unlocked = true` → Thức cập nhật trạng thái bản đồ |

| Truyền cho | Nội dung |
| :--- | :--- |
| **Lê Uyên Nhi** | `location_id`, `checkin_completed = true` |

---

## 3. Lê Uyên Nhi

### Tính năng phụ trách

| Tính năng | Thư mục dự kiến |
| :--- | :--- |
| Văn hóa (nội dung + quiz) | `lib/features/journey/` |
| Lưu tiến độ Văn hóa | `lib/features/journey/` |
| Từ vựng (thẻ + audio + quiz) | `lib/features/journey/` |
| Lưu tiến độ Từ vựng | `lib/features/journey/` |
| Tổng kết địa điểm | `lib/features/journey/` |
| Tính XP gameplay | `lib/shared/` hoặc `lib/features/journey/` |
| Tính số sao | `lib/features/journey/` |
| Trao huy hiệu | `lib/features/achievements/` |
| Trao dấu mộc | `lib/features/achievements/` |
| Mở khóa địa điểm tiếp theo | `lib/features/journey/` |

### Công thức XP

```
Hoàn thành nhiệm vụ  →  +2 XP
Trả lời đúng bonus   →  +8 XP
Hoàn thành section   → +20 XP
Hoàn thành địa điểm  → +50 XP
Một nhiệm vụ không được cộng XP nhiều lần.
```

### Công thức số sao

```
0–20%   → ★
21–40%  → ★★
41–60%  → ★★★
61–80%  → ★★★★
81–100% → ★★★★★
Số sao không ảnh hưởng đến việc mở khóa địa điểm.
```

### Database phụ trách

```
culture_contents        (id, location_id, title, content, image_url, order_number)
culture_questions       (id, culture_content_id, question, explanation)
culture_answers         (id, question_id, answer, is_correct)
user_culture_progress   (user_id, culture_content_id, selected_answer, completed, correct, completed_at)

vocabularies            (id, location_id, korean, vietnamese, romanization, audio_url, example, order_number)
vocabulary_questions    (tùy chọn)
vocabulary_answers      (tùy chọn)
user_vocabulary_progress(tùy chọn)

badges                  (định nghĩa huy hiệu)
user_badges             (user_id, badge_id, earned_at)
user_stamps             (user_id, location_id, earned_at)
```

### Luồng bàn giao

```
Văn hóa → Từ vựng → Tổng kết → Tính XP → Tính sao
→ Nhận huy hiệu → Nhận dấu mộc → Mở khóa địa điểm tiếp theo
```

### Điểm tích hợp

| Nhận từ | Nội dung |
| :--- | :--- |
| **Nguyễn Viết Thức** | `location_id`, `checkin_completed = true` để mở phần Văn hóa |

| Truyền cho | Nội dung |
| :--- | :--- |
| **Nguyễn Viết Thức** | `next_location_unlocked = true` để cập nhật bản đồ |
| **Phạm Văn Dương** | `xp`, `badge`, `stamp` để hiển thị ở Trang chủ & Hộ chiếu |

---

## Dữ liệu chung — ba thành viên phải thống nhất

### ID xuyên suốt hệ thống

```
user_id · location_id · section_id · question_id
```

### Enum trạng thái section

```
locked | unlocked | in_progress | completed
```

### Enum trạng thái location

```
locked | unlocked | current | completed
```

### Cấu trúc kết quả câu hỏi

```
completed       (bool)  -- true dù đúng hay sai
correct         (bool)
selected_answer (string)
```

> **Quy tắc quan trọng:** Trả lời sai vẫn `completed = true`. Đúng/sai chỉ ảnh hưởng XP và số sao, không chặn tiến độ.

---

## File dùng chung — nguy cơ xung đột cao

| File | Lý do | Quy tắc |
| :--- | :--- | :--- |
| `pubspec.yaml` | Dependency toàn dự án | Báo nhóm trước; tạo PR riêng nếu thêm package |
| `lib/app/app_router.dart` | Route toàn cục | Thảo luận trước khi thêm route mới |
| `lib/app/app_theme.dart` | Theme toàn bộ UI | Đề xuất qua PR, mô tả rõ lý do |
| `lib/design_system/**` | Token màu, spacing, typography | Không hard-code trong screen; dùng token có sẵn |
| `lib/shared/models/**` | Model dùng chung | Thông báo trước; thay đổi ảnh hưởng nhiều feature |
| `lib/shared/repositories/**` | Repository interface | Sửa interface phải cập nhật mọi implementation |
| `lib/l10n/**` | Ngôn ngữ dùng chung | Thêm key mới phải cập nhật tất cả file locale |
| `README.md` | Tài liệu chính | Cập nhật theo thực tế; không xóa mục đã có |
| `AGENTS.md` | Hướng dẫn cho AI agent | Chỉ sửa khi kiến trúc hoặc quy tắc thay đổi |

---

## Quy tắc phối hợp

1. **Không sửa module của thành viên khác** khi chưa trao đổi.
2. **Không hard-code màu, spacing, radius** trong màn hình — dùng token từ `lib/design_system/`.
3. **Lấy dữ liệu qua provider/repository** — không sao chép mock data vào từng screen.
4. **Khi sửa file dùng chung**, ghi rõ trong commit message và mô tả PR lý do và phạm vi thay đổi.
5. **Trước khi tạo Pull Request**, chạy đủ bốn lệnh:
   ```bash
   dart format .
   flutter analyze
   flutter test
   flutter build web
   ```
6. **Không tự merge PR của mình** khi nhóm yêu cầu review.
7. **Conflict xảy ra** → người phụ trách module phối hợp giải quyết; không tự ý xóa code của người khác.

---

## Definition of Done

Một tính năng chỉ được coi là hoàn thành khi:

- [ ] Có giao diện hoàn chỉnh.
- [ ] Có dữ liệu/database cần thiết.
- [ ] Có backend/API nếu cần.
- [ ] Có xử lý loading.
- [ ] Có xử lý lỗi.
- [ ] Lưu được trạng thái.
- [ ] Reload trang không làm mất tiến độ.
- [ ] Không cộng XP / phần thưởng lặp.
- [ ] Responsive cơ bản.
- [ ] Được ít nhất một thành viên khác kiểm thử.
- [ ] Đã merge vào branch chính.

---

> Mọi thay đổi phân công phải cập nhật đồng thời file nguồn [`docs/PHAN_CONG_CONG_VIEC.md`](PHAN_CONG_CONG_VIEC.md) và file này.
