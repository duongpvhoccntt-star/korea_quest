---
status: accepted
date: 2026-10-08
supersedes: 0004-model-location-state-per-explorer
---

# Tách quyền truy cập nội dung khỏi tiến độ cá nhân

Mọi Địa điểm có Tình trạng ra mắt `released` và toàn bộ chín Chặng của Địa điểm đó được truy cập trực tiếp. Thứ tự Chặng chỉ hướng dẫn hành trình; tiến độ `not_started`, `in_progress`, `completed`, XP, Quiz, Huy hiệu và Dấu mộc chỉ ghi nhận hoạt động và không được dùng làm điều kiện truy cập.

`coming_soon` là trạng thái biên tập duy nhất khiến chi tiết Địa điểm chưa thể mở. Draft và Archived tiếp tục ẩn khỏi danh mục công khai. Fun Fact là nội dung thông thường; lượt xem được ghi bằng `explorer_content_views(kind = 'fun_fact')`. Bộ sưu tập Huy hiệu và Hộ chiếu chỉ trả và hiển thị phần thưởng đã nhận.

Quyết định này loại bỏ Địa điểm tiên quyết, trạng thái gameplay `locked`/`available` ở cấp Chặng và cơ chế mở khóa Fun Fact. Optimistic locking của Admin, tiêu chí Huy hiệu đã trao, bảo mật tài khoản và quyền biên tập không bị ảnh hưởng.
