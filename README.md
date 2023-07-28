#Thư viện maps_core

Thư viện maps_core là wrapper cho 2 thư viện bản đồ [Google Map](https://pub.dev/packages/google_maps_flutter) và [Viettel Map](https://pub.dev/packages/vtmap_gl).

**Lưu ý: **
- Thư viện này chỉ là wrapper cho nên có thể tồn tại bug của Viettel Map
- Nếu có bug như tham số flag không có tác dụng, vui lòng tạo issue trên gitlab

## Giới thiệu

Thư viện này sử dụng cách thiết kế của Google map (widget based thay vì controller based), cho nên các loại shape như Maker, Polyline,... sẽ được update theo cơ chế: thay đổi dữ liệu -> rebuild widget.

## Điều kiện
Để sử dụng thư viện này cần phiên bản Flutter <= 3.3.10 (do thư viện Viettel Map chưa update)

Truy cập được vào gitlab private (Thư viện sẽ được publish lên pub.dev sau)

Thêm package vào pubspec:
```
dependencies:
  maps_core:
    git:
      url: http://gitlab.gpdn.net/mobile-library/map-core.git
      ref: develop
```

## Hướng dẫn sử dụng

### 1. Token
Nếu sử dụng loại map nào thì cần setting token của loại map đó:
- [Setting google map](https://pub.dev/packages/google_maps_flutter#getting-started)
- [Setting VTMap](https://pub.dev/packages/vtmap_gl#adding-a-vtmaps-access-token). Sau khi lấy được token của VTMap cần truyền vào widget CoreMap.

### 2. Một số lưu ý
CoreMap sẽ nhận các object thay vì truyền thẳng primitive type, mỗi object sẽ chứa các tham số chi tiết:
- type: Google hoặc Viettel.
- data: các tham số dữ liệu như token, vị trí camera,...
- callbacks: các callback như onMapCreated để lấy controller,...
- shapes: các loại shape trên bản đồ như marker, polyline

> Ví dụ cần lắng nghe camera move thì tìm trong CoreMapCallbacks, cần truyền gesture, padding thì tìm trong data...

Đa số các tham số đã có comment nên hướng dẫn sử dụng sẽ **tập trung vào một số phần quan trọng chứ không đi vào chi tiết.**

Ngoài ra, khi thay đổi dữ liệu truyền vào CoreMap cần rebuild widget để các thay đổi hiển thị trên UI

### 3. Data
Data chứa các tham số như flag, map access token, cấu hình button như zoom, cấu hình map,...
### 4. Callbacks
Chứa các callback như onCameraMove, onCameraIdle,..

Có 3 callback quan trọng:
- *onMapCreated*: Dùng để lấy CoreMapController (Xem phần CoreMapController)
- *onRoutingManagerReady*: dùng để lấy RoutingManager (Xem phần RoutingManager)
- *onInfoWindowManagerReady*: dùng để lấy InfoWindowManager (Xem phần InfoWindowManager)

**Lưu ý**, do CoreMap có thể đổi type (từ Google thành Viettel và ngược lại) nên *onMapCreated* sẽ được gọi lần nữa mỗi khi đổi loại map (*onRoutingManagerReady* và *onInfoWindowManagerReady* thì chỉ được gọi 1 lần).

Có 2 cách để lưu các controller và manager trên:
- Dùng ReusableCompleter. Do Completer thông thường chỉ có thể complete 1 lần duy nhất và sẽ lỗi nếu dùng để lưu CoreMapController trong trường hợp đổi loại map. Vì vậy hãy dùng ReusableCompleter do nó có thể gọi complete nhiều lần.
- Đơn giản hơn bạn có thể dùng biến nullable thay vì Completer nếu muốn.

#### a) CoreMapController
Lưu ý *onMapCreated* sẽ được gọi mỗi khi type của CoreMap thay đổi.

Dùng để di chuyển camera, lấy vị trí trên màn hình, trên bản đồ,...

#### b) RoutingManager

Dùng để vẽ Route trên bản đồ.
Hiện đang dùng Polyline để vẽ nên trên VTMap gặp vấn đề sau: khi zoom max thì route bị lệch so với đường.
*Nếu bạn có nhu cầu dùng native build route của VTMap (phương thức này dùng RouteLine của Mapbox nên sẽ chính xác và đẹp hơn nhưng không đổi màu được) thì bạn hãy tạo issue và liên hệ chúng tôi để thêm phương thức VTMap native*

#### c) InfoWindowManager
Do InfoWindow sử dụng class và logic xử lý khác với 2 thư viện map nên một manager được tạo riêng thay vì tích hợp vào CoreMapController.

Dùng để show/hide info window của marker.

### 5. Shapes
CoreMap hỗ trợ 4 loại hình: marker, polyline, polygon, circle...

Các hình có hỗ trợ zIndex (nhưng đối với VTMap, zIndex chỉ tác dụng trong cùng một loại hình do ở native các loại hình có thứ tự vẽ cố định)
#### a) Marker:
*Một số tham số như drag, visible sẽ không hoạt dộng ở VTMap*
##### Icon
Marker cung cấp một số loại icon sau:
- asset: truyền đường dẫn asset trong project của bạn
- network: truyền url của hình ảnh
- bitmap: truyền bitmap dạng UInt8List
- widget: truyền widget (widget nên có size)

Lưu ý rằng ngoài data hình ảnh cho marker icon như trên, còn một tham số là name, khi bạn muốn đổi icon khác nên đổi name do marker icon sẽ được cache lại theo name. Vì vậy trong trường hợp icon đổi thường xuyên cho một marker, nên đặt tên kiểu như url hoặc name + thêm size phía sau như "marker1img200x210".

#### InfoWindow

Mặc định infowindow 