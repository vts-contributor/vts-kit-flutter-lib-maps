import 'dart:typed_data';

import '../models/map_objects/marker_icon.dart';

abstract class MarkerIconDataProcessor {
  Future<void> processAssetMarkerIcon(MarkerIconData<String> markerIconData);

  Future<void> processNetworkMarkerIcon(MarkerIconData<String> markerIconData);

  Future<void> processBitmapMarkerIcon(MarkerIconData<Uint8List> markerIconData);
}