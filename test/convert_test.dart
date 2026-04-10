import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps.dart';

void main() {
  group("convert test", () {
    test("latlng test", () {
      // expect(latLng.toGoogle(), ggLatLng);
      // expect(latLng.toViettel(), vtLatLng);

      for (int i = 0; i < 500; i++) {
        LatLng stringLatLng = const LatLng(10.83571439676659, 106.67236659058827);
        LatLng converted = LatLng.fromString(stringLatLng.toString());

        expect(stringLatLng, converted);
      }
    });

    test("camera zoom convert test", () {
      const target = LatLng(10.3091231, 105.102020321);
      CameraPosition position = CameraPosition(
        target: target,
        zoom: 5,
      );
      expect(position.zoom, position.toGoogle().toCore().zoom);
      expect(position.zoom, position.toViettel().toCore().zoom);
    });

    test("polyline test", () {
      expect(JointType.bevel.toGoogle(), gg.JointType.bevel);
      expect(JointType.mitered.toGoogle(), gg.JointType.mitered);
      expect(JointType.round.toGoogle(), gg.JointType.round);

      expect(JointType.bevel.toViettel(), "bevel");
      expect(JointType.mitered.toViettel(), "mitered");
      expect(JointType.round.toViettel(), "round");

      debugPrint(double.tryParse("   ").toString());
    });
  });
}
