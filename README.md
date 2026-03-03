# TH3 - Call API App (Menu món ăn)

Ứng dụng Flutter hiển thị menu món ăn bằng dữ liệu mạng (Public API từ TheMealDB), đáp ứng yêu cầu bài thực hành 3:

- Có đủ 3 trạng thái: `Loading` / `Success` / `Error + Retry`.
- Dữ liệu được map qua model `FoodItem`.
- Hàm gọi API có `try-catch` để bắt lỗi an toàn.
- Code tách file theo từng tầng: `models`, `services`, `screens`, `widgets`.
- AppBar hiển thị đúng cú pháp: `TH3 - [Họ tên Sinh viên] - [Mã SV]`.

## Cấu trúc chính

- `lib/models/food_item.dart`: Model món ăn.
- `lib/services/food_api_service.dart`: Gọi API và parse JSON.
- `lib/screens/menu_home_page.dart`: Quản lý luồng bất đồng bộ và render trạng thái UI.
- `lib/widgets/food_card.dart`: Card hiển thị item món ăn.
- `lib/widgets/error_state_view.dart`: UI lỗi và nút `Thử lại`.
- `lib/main.dart`: Khởi tạo Material 3 theme và màn hình chính.

## Chạy ứng dụng

```bash
flutter pub get
flutter run
```

## Tùy chỉnh thông tin sinh viên

Sửa trong `MenuHomePage` tại file `lib/screens/menu_home_page.dart`:

- `studentName`
- `studentId`
