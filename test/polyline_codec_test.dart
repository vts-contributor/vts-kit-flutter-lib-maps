import 'package:flutter_test/flutter_test.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/utils/polyline_codec.dart';

void main() {
  test("polyline codec", () {
    List<LatLng> listLatLng = [
      LatLng(10.2461, 105.5216),
      LatLng(10.9712, -108.2512),
      LatLng(10.5025, -107.0828),
      LatLng(10.5025, -107.0828),
      LatLng(10.8023, 108.8126),
      LatLng(10.5025, -107.0828),
    ];

    String encodedPolyline = PolylineCodec.encode(listLatLng);
    expect(encodedPolyline, "cep}@_u`cS{rlC~nwwg@jpzAoecF??wpy@gavdh@vpy@favdh@");

    List<LatLng> decodedListLatLng = PolylineCodec.decode(encodedPolyline);
    for (int i = 0; i < decodedListLatLng.length; i++) {
      expect(decodedListLatLng[i], listLatLng[i]);
    }
  });
}