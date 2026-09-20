# Tạo phiên bản cho nội dung Địa điểm đã Xuất bản

Nội dung đang hiển thị cho Nhà thám hiểm không được sửa trực tiếp. Một Địa điểm có một phiên bản `published` và tối đa một phiên bản `draft`; khi biên tập nội dung đã Xuất bản, hệ thống tạo Bản nháp từ phiên bản hiện tại và chỉ chuyển phiên bản mới thành `published` bằng một transaction sau khi validation thành công. Cấu trúc này tăng độ phức tạp của schema nhưng ngăn nội dung chỉnh sửa dở xuất hiện trong ứng dụng.
