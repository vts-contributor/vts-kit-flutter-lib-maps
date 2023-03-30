import '../lat_lng.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class ViettelCircle {
  String id;
  vt.Fill fill;
  vt.Line outline;

  ViettelCircle(this.id, this.fill, this.outline);
}