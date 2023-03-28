import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;

void main() {
  group("convert test", ()  {
    test("polyline test", () {
      expect(JointType.bevel.toGoogle(), gg.JointType.bevel);
      expect(JointType.mitered.toGoogle(), gg.JointType.mitered);
      expect(JointType.round.toGoogle(), gg.JointType.round);

      expect(JointType.bevel.toViettel(), "bevel");
      expect(JointType.mitered.toViettel(), "mitered");
      expect(JointType.round.toViettel(), "round");
    });

    test("camera update test", () {
      CameraPosition position1 = CameraPosition(
        target: LatLng(10.3091231, 105.102020321),
        zoom: 5,
      );

    });
  });
}