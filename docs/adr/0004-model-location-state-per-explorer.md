---
status: superseded
superseded_by: 0012-keep-content-access-independent-from-progress
---

# Lưu trạng thái gameplay theo Nhà thám hiểm

Các trạng thái `locked`, `available`, `current` và `completed` không được lưu trực tiếp trên Địa điểm vì chúng khác nhau với từng Nhà thám hiểm. Địa điểm chỉ khai báo thứ tự hiển thị và tối đa một Địa điểm tiên quyết trong MVP; trạng thái gameplay được suy ra từ tiến độ cá nhân, còn `draft`, `published` và `archived` chỉ mô tả vòng đời nội dung.

Quyết định này đã được ADR-0012 thay thế: tiến độ cá nhân vẫn được lưu nhưng không còn tạo trạng thái khóa hoặc kiểm soát quyền truy cập.
