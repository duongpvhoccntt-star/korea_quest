---
status: accepted
---

# Lưu ảnh nội dung trong public Supabase Storage

Ảnh nội dung Địa điểm được Quản trị viên tải lên bucket công khai `content-media`; chỉ Quản trị viên có quyền ghi và xóa, còn Nhà thám hiểm đọc qua public URL. Bản ghi nội dung vẫn lưu URL Storage vào các cột URL hiện có.

Mỗi lần upload tạo object mới thay vì ghi đè object cũ. Bucket chỉ nhận JPEG, PNG và WebP, tối đa 5 MiB. Với ảnh Admin tải trực tiếp, credit, URL nguồn và alt là thông tin tùy chọn khi xuất bản; ảnh từ URL ngoài vẫn có thể bổ sung các thông tin này khi cần truy vết.