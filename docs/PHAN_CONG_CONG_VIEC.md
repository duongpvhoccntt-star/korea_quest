**KOREAQUEST**

**PHÂN CÔNG CÔNG VIỆC NHÓM**

MVP khám phá văn hóa Hàn Quốc theo hướng game-based learning

| **Phạm Văn Dương**   | Tài khoản • Trang chủ • Hồ sơ • Hộ chiếu   |
|----------------------|--------------------------------------------|
| **Nguyễn Viết Thức** | Bản đồ • Địa điểm • Check-in               |
| **Lê Uyên Nhi**      | Văn hóa • Từ vựng • Tổng kết • Phần thưởng |

**Mỗi thành viên chịu trách nhiệm trọn gói tính năng mình nhận: frontend, dữ liệu, backend/API và kiểm thử.**

## 1. Tổng quan

**KoreaQuest** là ứng dụng khám phá văn hóa Hàn Quốc theo hướng game-based learning.

Người dùng chọn một địa điểm, hoàn thành các phần nội dung và nhiệm vụ để nhận XP, huy hiệu, dấu mộc và mở khóa địa điểm tiếp theo.

### Luồng MVP

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Đăng nhập<br />
→ Trang chủ<br />
→ Bản đồ<br />
→ Chọn địa điểm<br />
→ Check-in<br />
→ Văn hóa<br />
→ Từ vựng<br />
→ Tổng kết<br />
→ Nhận XP / Huy hiệu / Dấu mộc<br />
→ Mở khóa địa điểm tiếp theo</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### Quy tắc gameplay

- Mỗi phần có nhiều nhiệm vụ riêng.

- Người dùng phải hoàn thành tất cả nhiệm vụ của phần hiện tại mới mở được phần tiếp theo.

- Trả lời sai vẫn được tính là hoàn thành nhiệm vụ.

- Đúng / sai chỉ ảnh hưởng đến XP, số sao và đánh giá cuối địa điểm.

- Sau khi trả lời phải hiển thị đáp án đúng và phần giải thích.

---

# 2. Nguyên tắc phân chia

Nhóm chia công việc theo **tính năng**, không chia riêng frontend/backend.

|     | **Ai phụ trách tính năng nào thì người đó chịu trách nhiệm toàn bộ:** |
|-----|-----------------------------------------------------------------------|

|     |     |
|-----|-----|

|     | **- Frontend** |
|-----|----------------|

|     | **- Logic** |
|-----|-------------|

|     | **- Database liên quan** |
|-----|--------------------------|

|     | **- API/backend liên quan** |
|-----|-----------------------------|

|     | **- Lưu tiến độ** |
|-----|-------------------|

|     | **- Kiểm thử tính năng** |
|-----|--------------------------|

Ba thành viên:

1.  Phạm Văn Dương

2.  Nguyễn Viết Thức

3.  Lê Uyên Nhi

---

# 3. Phạm Văn Dương

## Cụm tính năng phụ trách

**Tài khoản + Trang chủ + Hồ sơ + Hộ chiếu**

---

## 3.1. Đăng ký / Đăng nhập

### Frontend

- Form đăng ký.

- Form đăng nhập.

- Đăng xuất.

- Hiển thị lỗi.

- Loading.

- Chuyển hướng sau đăng nhập.

- Kiểm tra trạng thái đăng nhập.

### Backend / Data

- Authentication.

- Session người dùng.

- User profile.

Dữ liệu gợi ý:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>users<br />
<br />
id<br />
name<br />
email<br />
avatar_url<br />
xp<br />
level<br />
created_at</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 3.2. Trang chủ

Hiển thị:

- Tên người dùng.

- Avatar.

- XP.

- Level.

- Địa điểm đang khám phá.

- Tiến độ hiện tại.

- Nút "Tiếp tục khám phá".

- Huy hiệu mới nhất.

- Địa điểm tiếp theo.

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Xin chào Minh Khang<br />
<br />
Level 2<br />
850 XP<br />
<br />
Đang khám phá:<br />
Chợ Gwangjang<br />
<br />
Tiến độ: 64%<br />
<br />
[ Tiếp tục khám phá ]</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### API / Data liên quan

Ví dụ:

| GET /me/home |
|--------------|

Trả về:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>{<br />
"name": "Minh Khang",<br />
"xp": 850,<br />
"level": 2,<br />
"currentLocation": "Gwangjang",<br />
"progress": 64<br />
}</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 3.3. Hệ thống Level

Phụ trách logic cấp độ người dùng.

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>0–499 XP → Level 1<br />
500–999 XP → Level 2<br />
1000–1999 XP → Level 3</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 3.4. Hộ chiếu khám phá

Frontend:

- Thông tin người dùng.

- Tổng XP.

- Level.

- Danh sách huy hiệu.

- Danh sách dấu mộc.

- Danh sách địa điểm đã hoàn thành.

- Điểm / số sao từng địa điểm.

Database liên quan:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_badges<br />
user_stamps</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

API gợi ý:

| GET /me/passport |
|------------------|

---

## 3.5. Kết quả cần bàn giao

Luồng hoàn chỉnh:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Đăng ký<br />
→ Đăng nhập<br />
→ Trang chủ<br />
→ Xem XP / Level<br />
→ Xem Hộ chiếu<br />
→ Xem huy hiệu / dấu mộc</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

# 4. Nguyễn Viết Thức

## Cụm tính năng phụ trách

**Bản đồ + Địa điểm + Check-in**

---

## 4.1. Bản đồ khám phá

Frontend:

- Hiển thị các địa điểm trên bản đồ.

- Click vào địa điểm.

- Popup / card thông tin địa điểm.

Các trạng thái:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Completed<br />
Current<br />
Unlocked<br />
Locked</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>✅ Seoul<br />
🏮 Gwangjang<br />
📍 Gyeongbokgung<br />
🔒 Busan</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Database:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>locations<br />
<br />
id<br />
name<br />
slug<br />
description<br />
thumbnail_url<br />
order_number<br />
unlock_condition<br />
status</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

API:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>GET /locations<br />
GET /locations/:id</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 4.2. Trang giới thiệu địa điểm

Hiển thị trước khi bắt đầu gameplay:

- Tên địa điểm.

- Ảnh đại diện.

- Mô tả ngắn.

- Số nhiệm vụ.

- Thời gian ước tính.

- Nội dung sẽ khám phá.

- Phần thưởng.

- Nút "Bắt đầu khám phá".

---

## 4.3. Check-in

Check-in chỉ tập trung vào **giới thiệu địa điểm**, chưa đi sâu vào văn hóa.

Nội dung:

- Mô tả tổng quan.

- Vị trí.

- Điểm nổi bật.

- Lịch sử.

- Timeline.

- Gallery ảnh.

- Video giới thiệu.

### Dữ liệu Check-in

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>location_checkin<br />
<br />
location_id<br />
introduction<br />
address<br />
highlight<br />
description</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### Dữ liệu lịch sử

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>location_history<br />
<br />
id<br />
location_id<br />
year<br />
title<br />
content<br />
order_number</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### Media

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>location_media<br />
<br />
id<br />
location_id<br />
type<br />
url<br />
caption</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

\`type\` có thể là:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>image<br />
video</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 4.4. Nhiệm vụ Check-in

Câu hỏi phải dựa trực tiếp vào:

- Nội dung mô tả.

- Hình ảnh.

- Video.

- Lịch sử.

- Timeline.

Ví dụ:

| Gwangjang bắt đầu hình thành vào giai đoạn nào? |
|-------------------------------------------------|

Nếu đúng:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>✅ Chính xác!<br />
<br />
+ XP bonus<br />
<br />
✓ Nhiệm vụ hoàn thành</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Nếu sai:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>❌ Chưa chính xác.<br />
<br />
Đáp án đúng: ...<br />
<br />
Giải thích: ...<br />
<br />
✓ Nhiệm vụ vẫn hoàn thành</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 4.5. Database câu hỏi Check-in

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>checkin_questions<br />
<br />
id<br />
location_id<br />
question<br />
explanation<br />
order_number</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>checkin_answers<br />
<br />
id<br />
question_id<br />
answer<br />
is_correct</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 4.6. Lưu tiến độ Check-in

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_checkin_progress<br />
<br />
user_id<br />
location_id<br />
question_id<br />
selected_answer<br />
completed<br />
correct<br />
completed_at</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Điều quan trọng:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>completed = true<br />
correct = false</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

vẫn được xem là đã hoàn thành.

Khi:

| completed_questions = total_questions |
|---------------------------------------|

thì Check-in hoàn thành và mở phần Văn hóa.

---

## 4.7. Kết quả cần bàn giao

Luồng hoàn chỉnh:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Bản đồ<br />
→ Chọn địa điểm<br />
→ Xem giới thiệu<br />
→ Bắt đầu Check-in<br />
→ Xem mô tả / lịch sử / ảnh / video<br />
→ Làm nhiệm vụ<br />
→ Hoàn thành Check-in<br />
→ Mở Văn hóa</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

# 5. Lê Uyên Nhi

## Cụm tính năng phụ trách

**Văn hóa + Từ vựng + Tổng kết + Phần thưởng cuối địa điểm**

---

## 5.1. Văn hóa

Mỗi nội dung văn hóa gồm:

- Hình ảnh / icon.

- Tiêu đề.

- Nội dung.

- Nút "Đã đọc".

- Một câu hỏi.

- Các đáp án.

- Giải thích.

Luồng:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Đọc nội dung<br />
→ Bấm "Đã đọc"<br />
→ Hiện câu hỏi<br />
→ Trả lời<br />
→ Hiện đúng / sai<br />
→ Hiện giải thích<br />
→ Đánh dấu hoàn thành</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Sai vẫn được tính hoàn thành.

---

## 5.2. Database Văn hóa

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>culture_contents<br />
<br />
id<br />
location_id<br />
title<br />
content<br />
image_url<br />
order_number</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>culture_questions<br />
<br />
id<br />
culture_content_id<br />
question<br />
explanation</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>culture_answers<br />
<br />
id<br />
question_id<br />
answer<br />
is_correct</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_culture_progress<br />
<br />
user_id<br />
culture_content_id<br />
selected_answer<br />
completed<br />
correct<br />
completed_at</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 5.3. Từ vựng

Mỗi từ gồm:

- Từ tiếng Hàn.

- Nghĩa tiếng Việt.

- Phiên âm.

- Audio.

- Câu ví dụ.

- Nút "Học từ".

- Câu hỏi kiểm tra.

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>시장<br />
<br />
sijang<br />
<br />
Chợ<br />
<br />
🔊 Phát âm<br />
<br />
Ví dụ:<br />
광장시장은 유명해요.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 5.4. Database Từ vựng

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>vocabularies<br />
<br />
id<br />
location_id<br />
korean<br />
vietnamese<br />
romanization<br />
audio_url<br />
example<br />
order_number</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Có thể thêm:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>vocabulary_questions<br />
vocabulary_answers<br />
user_vocabulary_progress</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 5.5. Tổng kết địa điểm

Sau khi hoàn thành Check-in, Văn hóa và Từ vựng:

Hiển thị:

| GWANGJANG COMPLETED |
|---------------------|

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Check-in<br />
5/5 nhiệm vụ<br />
Đúng 3/5<br />
<br />
Văn hóa<br />
5/5 nhiệm vụ<br />
Đúng 4/5<br />
<br />
Từ vựng<br />
6/6 nhiệm vụ<br />
Đúng 5/6</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Tổng:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>12/16 câu đúng<br />
<br />
★★★★☆<br />
<br />
+ XP</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 5.6. XP gameplay

Công thức gợi ý:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Hoàn thành nhiệm vụ: +2 XP<br />
Trả lời đúng: +8 XP bonus</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Tức là:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Sai → 2 XP<br />
Đúng → 10 XP</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Có thể cộng thêm:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Hoàn thành một section: +20 XP<br />
Hoàn thành địa điểm: +50 XP</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Phải bảo đảm một nhiệm vụ không thể nhận XP nhiều lần.

---

## 5.7. Tính số sao

Dựa trên tỷ lệ câu trả lời đúng:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>0–20% → ★<br />
21–40% → ★★<br />
41–60% → ★★★<br />
61–80% → ★★★★<br />
81–100% → ★★★★★</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Số sao **không ảnh hưởng đến việc mở khóa**.

---

## 5.8. Huy hiệu

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Hoàn thành Seoul<br />
→ Seoul Explorer<br />
<br />
Hoàn thành Gwangjang<br />
→ Korean Food Explorer<br />
<br />
Hoàn thành Gyeongbokgung<br />
→ Royal Korea Explorer</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Database:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>badges<br />
user_badges</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

## 5.9. Dấu mộc

Khi hoàn thành địa điểm:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_stamps<br />
<br />
user_id<br />
location_id<br />
earned_at</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Dương sẽ lấy dữ liệu này để hiển thị trong Hộ chiếu.

---

## 5.10. Mở khóa địa điểm tiếp theo

Ví dụ:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Gwangjang completed<br />
↓<br />
Gyeongbokgung unlocked</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Sau khi cập nhật trạng thái, module Bản đồ của Thức sẽ hiển thị địa điểm mới.

---

## 5.11. Kết quả cần bàn giao

Luồng hoàn chỉnh:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>Văn hóa<br />
→ Từ vựng<br />
→ Tổng kết<br />
→ Tính XP<br />
→ Tính sao<br />
→ Nhận huy hiệu<br />
→ Nhận dấu mộc<br />
→ Mở khóa địa điểm tiếp theo</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

# 6. Bảng ownership tính năng

| **Tính năng**              | **Người phụ trách**  |
|----------------------------|----------------------|
| Đăng ký                    | **Phạm Văn Dương**   |
| Đăng nhập                  | **Phạm Văn Dương**   |
| Hồ sơ người dùng           | **Phạm Văn Dương**   |
| Trang chủ                  | **Phạm Văn Dương**   |
| Level                      | **Phạm Văn Dương**   |
| Hộ chiếu                   | **Phạm Văn Dương**   |
| Hiển thị huy hiệu          | **Phạm Văn Dương**   |
| Hiển thị dấu mộc           | **Phạm Văn Dương**   |
| Bản đồ                     | **Nguyễn Viết Thức** |
| Danh sách địa điểm         | **Nguyễn Viết Thức** |
| Chi tiết địa điểm          | **Nguyễn Viết Thức** |
| Check-in                   | **Nguyễn Viết Thức** |
| Mô tả địa điểm             | **Nguyễn Viết Thức** |
| Lịch sử / Timeline         | **Nguyễn Viết Thức** |
| Gallery ảnh                | **Nguyễn Viết Thức** |
| Video giới thiệu           | **Nguyễn Viết Thức** |
| Quiz Check-in              | **Nguyễn Viết Thức** |
| Progress Check-in          | **Nguyễn Viết Thức** |
| Văn hóa                    | **Lê Uyên Nhi**      |
| Quiz Văn hóa               | **Lê Uyên Nhi**      |
| Progress Văn hóa           | **Lê Uyên Nhi**      |
| Từ vựng                    | **Lê Uyên Nhi**      |
| Audio từ vựng              | **Lê Uyên Nhi**      |
| Quiz từ vựng               | **Lê Uyên Nhi**      |
| Progress từ vựng           | **Lê Uyên Nhi**      |
| Tổng kết địa điểm          | **Lê Uyên Nhi**      |
| XP gameplay                | **Lê Uyên Nhi**      |
| Số sao                     | **Lê Uyên Nhi**      |
| Trao huy hiệu              | **Lê Uyên Nhi**      |
| Trao dấu mộc               | **Lê Uyên Nhi**      |
| Mở khóa địa điểm tiếp theo | **Lê Uyên Nhi**      |

---

# 7. Dữ liệu chung ba người phải thống nhất

Các ID dùng xuyên suốt hệ thống:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_id<br />
location_id<br />
section_id<br />
question_id</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Trạng thái section:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>locked<br />
unlocked<br />
in_progress<br />
completed</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Trạng thái location:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>locked<br />
unlocked<br />
current<br />
completed</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Kết quả câu hỏi:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>completed<br />
correct<br />
selected_answer</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

---

# 8. Quy tắc tích hợp

### Dương → Thức

Dương truyền:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>user_id<br />
location_id</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

khi người dùng chọn địa điểm.

### Thức → Nhi

Sau Check-in:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>location_id<br />
checkin_completed = true</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Nhi dùng trạng thái này để cho phép mở Văn hóa.

### Nhi → Thức

Sau khi hoàn thành địa điểm:

| next_location_unlocked = true |
|-------------------------------|

Thức hiển thị trạng thái mới trên bản đồ.

### Nhi → Dương

Sau khi hoàn thành địa điểm:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th>xp<br />
badge<br />
stamp</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Dương hiển thị trong Trang chủ và Hộ chiếu.

---

# 9. Definition of Done

Một tính năng chỉ được coi là hoàn thành khi:

- \[ \] Có giao diện hoàn chỉnh.

- \[ \] Có dữ liệu/database cần thiết.

- \[ \] Có backend/API nếu cần.

- \[ \] Có xử lý loading.

- \[ \] Có xử lý lỗi.

- \[ \] Lưu được trạng thái.

- \[ \] Reload trang không làm mất tiến độ.

- \[ \] Không cộng XP / phần thưởng lặp.

- \[ \] Responsive cơ bản.

- \[ \] Được ít nhất một thành viên khác kiểm thử.

- \[ \] Đã merge vào branch chung.

---

# 10. Tóm tắt

### Phạm Văn Dương

|     | **Tài khoản → Trang chủ → Level → Hộ chiếu.** |
|-----|-----------------------------------------------|

### Nguyễn Viết Thức

|     | **Bản đồ → Địa điểm → Check-in → Lịch sử → Media → Nhiệm vụ Check-in.** |
|-----|-------------------------------------------------------------------------|

### Lê Uyên Nhi

|     | **Văn hóa → Từ vựng → Tổng kết → XP → Sao → Huy hiệu → Dấu mộc → Mở khóa địa điểm.** |
|-----|--------------------------------------------------------------------------------------|

Mỗi thành viên chịu trách nhiệm **trọn gói tính năng mình nhận**, từ giao diện đến dữ liệu và backend.
