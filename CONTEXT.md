# KoreaQuest

KoreaQuest mô tả hành trình khám phá văn hóa Hàn Quốc được trò chơi hóa. Ngôn ngữ dưới đây thống nhất cách các module gọi cùng một khái niệm nghiệp vụ.

## Language

**Nhà thám hiểm**:
Người dùng tham gia các hành trình văn hóa và tích lũy tiến độ cá nhân.
_Avoid_: Người chơi, khách hàng

**Quản trị viên**:
Người được phép biên tập, xuất bản và lưu trữ nội dung khám phá.
_Avoid_: Nhà thám hiểm, editor

**Địa điểm**:
Một điểm đến văn hóa Hàn Quốc có thể được khám phá qua một hành trình.
_Avoid_: Màn chơi, map

**Địa điểm tiên quyết**:
Địa điểm mà Nhà thám hiểm phải hoàn thành trước khi một Địa điểm khác được mở khóa; mỗi Địa điểm có tối đa một Địa điểm tiên quyết trong MVP.
_Avoid_: Địa điểm trước, trạng thái khóa

**Tiến độ Địa điểm**:
Trạng thái khám phá của một Nhà thám hiểm đối với một Địa điểm, từ chưa khả dụng đến hoàn thành.
_Avoid_: Trạng thái nội dung, trạng thái Địa điểm toàn cục

**Tình trạng ra mắt**:
Trạng thái toàn cục cho biết Địa điểm đang Sắp ra mắt hay Đã phát hành trên bản đồ; trạng thái này không biểu thị tiến độ của từng Nhà thám hiểm.
_Avoid_: Tiến độ Địa điểm, trạng thái khóa

**Điểm nổi bật**:
Một địa danh hoặc khu vực đáng chú ý được giới thiệu bên trong một Địa điểm nhưng không sở hữu Hành trình hay tiến độ độc lập.
_Avoid_: Địa điểm con, Địa điểm

**Bản nháp**:
Nội dung Địa điểm đang được biên tập, có thể chưa hoàn chỉnh và chưa hiển thị cho Nhà thám hiểm.
_Avoid_: Địa điểm chưa mở khóa

**Phiên bản nội dung**:
Một bản nhất quán của toàn bộ nội dung biên tập thuộc một Địa điểm; Quản trị viên chỉnh sửa Bản nháp trong khi Nhà thám hiểm tiếp tục xem phiên bản đã Xuất bản.
_Avoid_: Địa điểm, bản sao

**Xuất bản**:
Việc đưa nội dung Địa điểm đã hoàn chỉnh vào danh mục mà Nhà thám hiểm có thể khám phá.
_Avoid_: Mở khóa

**Lưu trữ**:
Việc rút một Địa điểm khỏi danh mục khám phá mà không xóa nội dung đã biên tập.
_Avoid_: Xóa, khóa

**Nguồn tham khảo**:
Thông tin nhận diện nơi xuất phát của nội dung hoặc media để Quản trị viên kiểm chứng và truy vết; bản thân việc ghi nguồn không xác lập quyền sử dụng.
_Avoid_: Nội dung bài học, giấy phép

**Hành trình**:
Trải nghiệm khám phá gắn với một Địa điểm và gồm chín Chặng tuần tự: Mở đầu, Tổng quan, Lịch sử, Điểm đến, Trải nghiệm, Ẩm thực, Fun Facts, Quiz tổng kết và Du lịch.
_Avoid_: Khóa học, chiến dịch

**Chặng**:
Một phần có thứ tự trong Hành trình, tập trung vào một nhóm nội dung hoặc hoạt động khám phá.
_Avoid_: Level, bước

**Mở đầu**:
Chặng đầu tiên giới thiệu Địa điểm bằng media thu hút, tagline và caption trước khi Nhà thám hiểm đi vào nội dung chi tiết; chặng này không chứa Câu hỏi.
_Avoid_: Check-in, Quiz Check-in, Hook (khi gọi tên Chặng)

**Nhiệm vụ**:
Một hoạt động có mục tiêu rõ ràng nằm trong một chặng và có thể trao XP.
_Avoid_: Bài học, task

**Câu hỏi**:
Một Nhiệm vụ tương tác thuộc Quiz tổng kết, có lời giải đúng và phần giải thích sau khi trả lời.
_Avoid_: Nội dung đọc, Chặng

**Quiz tổng kết**:
Chặng gồm một nhóm 10–20 Câu hỏi khi Xuất bản, dùng để kiểm tra kiến thức toàn Địa điểm trước khi chuyển sang thông tin du lịch và hoàn thành Hành trình; Bản nháp có thể chứa 0–20 Câu hỏi.
_Avoid_: Quiz Check-in, Quiz Văn hóa

**Fun Fact**:
Một thông tin văn hóa ngắn thuộc bộ sưu tập của Địa điểm, được mở khi Nhà thám hiểm hoàn thành Chặng do nội dung quy định và được ghi nhận trong tiến độ cá nhân.
_Avoid_: Thông tin nhanh, Câu hỏi

**Quy tắc ứng xử**:
Danh sách điều nên và không nên làm áp dụng chung khi trải nghiệm văn hóa tại một Địa điểm, không phải hướng dẫn riêng của từng trải nghiệm.
_Avoid_: Nội quy hệ thống, mô tả Trải nghiệm

**XP**:
Điểm kinh nghiệm ghi nhận tiến độ khám phá của Nhà thám hiểm; XP có thể đến từ quy tắc Quiz cố định hoặc phần thưởng Thử thách được cấu hình.
_Avoid_: Điểm số, coin

**Cấp độ**:
Cột mốc tiến triển được xác định từ XP tích lũy.
_Avoid_: Hạng

**Dấu mộc**:
Vật phẩm kỷ niệm được ghi vào Hộ chiếu khi Nhà thám hiểm hoàn tất hành trình của một Địa điểm; giao diện bộ sưu tập có thể gọi vật phẩm này là Tem bưu chính.
_Avoid_: Con dấu, token, Huy hiệu

**Hộ chiếu**:
Bộ sưu tập Dấu mộc và thông tin nhận diện hành trình của một Nhà thám hiểm; Hộ chiếu là riêng tư trừ khi chủ sở hữu chủ động tạo quyền chia sẻ.
_Avoid_: Ví, album

**Huy hiệu**:
Cột mốc thành tích được trao khi Nhà thám hiểm đáp ứng một điều kiện khám phá.
_Avoid_: Dấu mộc, phần thưởng

**Chuỗi khám phá**:
Số ngày liên tiếp Nhà thám hiểm có ít nhất một phiên truy cập tương tác; mỗi ngày theo múi giờ hồ sơ chỉ được ghi nhận một lần và hoạt động nền không được tính.
_Avoid_: Streak, chuỗi học tập

**Hồ sơ**:
Thông tin nhận diện và tùy chọn cá nhân của Nhà thám hiểm; email đăng nhập và họ tên pháp lý không bao giờ xuất hiện trong Hộ chiếu được chia sẻ.
_Avoid_: Tài khoản, Hộ chiếu

**Liên kết chia sẻ**:
Quyền truy cập có thể thu hồi vào một phần Hộ chiếu; database chỉ lưu hash token và việc tạo liên kết mới làm mất hiệu lực liên kết cũ.
_Avoid_: Hồ sơ công khai, URL người dùng

**Thử thách**:
Hoạt động có thời hạn gồm một hoặc nhiều Mục tiêu và phần thưởng XP hoặc Huy hiệu; tiêu chí và phần thưởng không được đổi sau khi Thử thách bắt đầu.
_Avoid_: Hành trình, Nhiệm vụ trong Chặng

**Mục tiêu**:
Điều kiện đo lường được bên trong một Thử thách, ví dụ số nội dung đã xem hoặc số Câu hỏi trả lời đúng.
_Avoid_: Huy hiệu, Chặng

**Sổ lưu niệm**:
Bộ ảnh riêng tư do Nhà thám hiểm tải lên và chú thích; từng ảnh chỉ xuất hiện trong Hộ chiếu chia sẻ khi chủ sở hữu chủ động cho phép.
_Avoid_: Thư viện media nội dung, ảnh đại diện

**Bảng xếp hạng tuần**:
Bản chụp thứ hạng theo XP hợp lệ kiếm được trong một tuần, chỉ gồm người chủ động tham gia và giữ điểm số ẩn danh khi tài khoản bị xóa.
_Avoid_: Cấp độ, tổng XP trọn đời
