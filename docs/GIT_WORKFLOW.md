# Quy trình GitHub

1. main chỉ chứa phiên bản ổn định; không phát triển trực tiếp trên main.
2. Cập nhật main, sau đó tạo nhánh riêng: feature/<ten>, fix/<ten>, docs/<ten> hoặc refactor/<ten>.
3. Mỗi pull request giải quyết một feature hoặc phạm vi rõ ràng.
4. Không tự ý xóa code hay giải conflict bằng cách ghi đè module của người khác; phối hợp với chủ module.
5. Trước pull request, chạy dart format ., flutter analyze, flutter test và flutter build web.
6. Không merge khi kiểm tra tự động chưa thành công; tuân thủ yêu cầu review của nhóm.
7. Không commit secret, API key, output build hoặc cấu hình IDE cá nhân.

Commit dùng tiền tố ngắn: feat:, fix:, refactor:, docs:, test: hoặc chore:.

Ví dụ:

    git checkout main
    git pull origin main
    git checkout -b feature/explore-filter
    flutter analyze
    flutter test
    git push origin feature/explore-filter
