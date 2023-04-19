import 'dart:typed_data';

import 'marker_icon.dart';

abstract class MarkerIconDataProcessor {
  Future<Uint8List> processAssetMarkerIcon(AssetMarkerIconData markerIconData);

  Future<Uint8List> processNetworkMarkerIcon(NetworkMarkerIconData markerIconData);

  Future<Uint8List> processBitmapMarkerIcon(BitmapMarkerIconData markerIconData);
}