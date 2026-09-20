# Tách UUID của Địa điểm khỏi slug công khai

Mỗi Địa điểm dùng UUID do PostgreSQL sinh làm khóa chính và foreign key, còn slug duy nhất được dùng trong URL và tra cứu công khai. Mock hiện tại dùng slug như `gyeongbokgung` làm ID sẽ được điều chỉnh khi kết nối repository thật; việc tách hai giá trị giữ quan hệ dữ liệu ổn định trong khi vẫn cung cấp URL dễ đọc, và slug không được đổi sau khi Địa điểm đã Xuất bản.
