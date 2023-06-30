import 'dart:typed_data';
import 'dart:ui';

abstract class BitmapCacheFactory {
  Uint8List? getCachedBitmap(String name);
  Future<void> validateCache(List<String> validNames);
  Size? sizeOf(String name);
}