import 'package:flutter_test/flutter_test.dart';
import 'package:maps_core/maps/extensions/helper.dart';
import 'package:maps_core/maps/models/map_objects/lat_lng.dart';

void main() {
  group("convert test", () {
    test("latlng test", () {
      const latLng1 = LatLng(42.42421, 105.31313131);
      const latLng2 = LatLng(43.42421, 106.31313131);
      print(latLng1.getDistanceFrom(latLng2));
    });
  });
}