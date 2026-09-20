# Xuất bản nội dung trong database

Flutter không được đổi trực tiếp trạng thái Phiên bản nội dung. Nút Xuất bản gọi một PostgreSQL RPC chịu trách nhiệm xác thực Quản trị viên, kiểm tra toàn bộ điều kiện nội dung và chuyển phiên bản cũ/mới trong một transaction; validation phía Flutter chỉ cung cấp phản hồi sớm. Cách này giữ quy tắc Xuất bản nhất quán nếu sau này có thêm client hoặc luồng quản trị khác.
