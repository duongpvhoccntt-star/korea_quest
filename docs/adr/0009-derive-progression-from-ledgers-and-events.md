---
status: accepted
---

# Suy ra tiến triển từ sổ XP và sự kiện duy nhất

`explorer_xp_ledger` là nguồn dữ liệu gốc của tổng XP; bảng tổng hợp chỉ là projection để đọc nhanh. Các chỉ số thành tích và Thử thách đếm sự kiện duy nhất như Câu hỏi lần đầu trả lời đúng hoặc nội dung lần đầu xem, thay vì cho Quản trị viên sửa trực tiếp tiến độ người dùng. Mọi phần thưởng dùng `reference_key` duy nhất để tránh trao lặp khi retry.
