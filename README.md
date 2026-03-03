# TH3 - Ứng dụng Menu Ẩm Thực (Flutter)

Ứng dụng Flutter theo định hướng **khám phá/giới thiệu món ăn**.

## Mục tiêu dự án

- Hiển thị danh sách món ăn từ dữ liệu mạng, map về model chuẩn.
- Đảm bảo đủ trạng thái UX: **Loading / Success / Error + Retry**.
- Cung cấp trải nghiệm hiện đại: tìm kiếm, sắp xếp, bộ lọc, yêu thích, chi tiết món.
- Tổ chức code theo module rõ ràng, dễ bảo trì.

## Tính năng chính

- Danh sách món ăn dạng **Grid/List** có thể chuyển đổi.
- Tìm kiếm theo tên món, loại món, quốc gia.
- Sắp xếp theo:
	- Đánh giá
	- Số thành phần
	- Tên A → Z
- Bộ lọc theo:
	- Quốc gia
	- Loại món
	- Khẩu vị
- Tab `Tất cả` và `Yêu thích`.
- Trang chi tiết món ăn:
	- Thông tin tóm tắt
	- Thành phần
	- Thông tin chi tiết
	- Mô tả món ăn
	- Nút lưu yêu thích + hoàn tác qua Snackbar

## Luồng dữ liệu

- Nguồn dữ liệu seed ban đầu: `DummyJSON Recipes API`.
- Dữ liệu được lưu/đọc qua `Cloud Firestore` (collection `recipes`).
- Xác thực người dùng bằng `Firebase Authentication` (anonymous sign-in).
- Toàn bộ dữ liệu được map về model `FoodItem`.

## Trạng thái giao diện

- **Loading**: luôn hiển thị hiệu ứng chờ (`CircularProgressIndicator`) ở lúc khởi tạo và lúc tải dữ liệu.
- **Success**: hiển thị danh sách món ăn bằng card/list gọn, có cắt chữ dài (`ellipsis`).
- **Error + Retry**: hiển thị màn lỗi rõ ràng và nút `Thử lại` để gọi lại dữ liệu.

## Cấu trúc thư mục chính

- `lib/main.dart`: khởi tạo app, theme, bootstrap Firebase/Auth.
- `lib/models/food_item.dart`: model dữ liệu món ăn.
- `lib/services/food_api_service.dart`: seed + đọc dữ liệu Firestore.
- `lib/services/favorite_service.dart`: quản lý trạng thái yêu thích.
- `lib/screens/menu_home_page.dart`: màn danh sách, tìm kiếm, lọc, sắp xếp.
- `lib/screens/food_detail_page.dart`: màn chi tiết món ăn.
- `lib/widgets/food_card.dart`: item dạng card.
- `lib/widgets/food_list_tile.dart`: item dạng list.
- `lib/widgets/error_state_view.dart`: UI lỗi + nút thử lại.
- `lib/utils/food_tags_mapper.dart`: chuẩn hóa quốc gia, suy luận tag khẩu vị.

## Công nghệ sử dụng

- Flutter
- Dart
- Firebase Core
- Firebase Auth
- Cloud Firestore
- HTTP

## Cách chạy dự án

```bash
flutter pub get
flutter run
```

Chạy theo thiết bị cụ thể:

```bash
flutter run -d emulator-5554
flutter run -d edge
flutter run -d chrome
```