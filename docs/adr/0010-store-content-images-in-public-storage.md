---
status: accepted
---

# Lưu ảnh nội dung trong public Supabase Storage

Ảnh dùng trong nội dung Địa điểm được Quản trị viên tải lên bucket công khai content-media; chỉ Quản trị viên có quyền ghi và xóa, còn Nhà thám hiểm có thể đọc bằng public URL. KoreaQuest không dùng URL ảnh bên ngoài làm tài sản hiển thị chính vì vòng đời, quyền nhúng và khả năng truy cập của chúng nằm ngoài hệ thống; URL trang nguồn, credit và thông tin kiểm chứng vẫn được lưu riêng để truy vết nguồn gốc.

Mỗi lần upload tạo một object mới thay vì ghi đè object cũ. Một object chỉ được xóa khi không còn Phiên bản nội dung nào tham chiếu, nhờ đó các Hành trình đã ghim vào phiên bản cũ không bị mất ảnh.

Bucket chỉ nhận JPEG, PNG và WebP với kích thước tối đa 5 MiB mỗi object. SVG và GIF không được nhận để tránh nội dung chủ động hoặc ảnh động nặng trong tài sản công khai.
