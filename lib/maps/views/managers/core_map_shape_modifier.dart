import 'package:maps_core/maps.dart';

abstract class CoreMapShapeModifier {
  CoreMapShapes modifyShapes(CoreMapShapes? original);
}