import 'dart:typed_data';

import 'marker_icon.dart';

abstract class MarkerIconDataProcessor {
  Future<Uint8List> processAssetMarkerIcon(MarkerIconData<String> markerIconData);

  Future<Uint8List> processNetworkMarkerIcon(MarkerIconData<String> markerIconData);

  Future<Uint8List> processBitmapMarkerIcon(MarkerIconData<Uint8List> markerIconData);
}