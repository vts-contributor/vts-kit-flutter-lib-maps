part of core_map;

abstract class MarkerOnTapEffectManager implements CoreMapShapeModifier {
  Future<void> onClickMaker(Marker marker);
}