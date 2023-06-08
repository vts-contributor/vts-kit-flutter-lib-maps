import 'dart:typed_data';

abstract class BitmapCacheFactory {
  Uint8List? getCachedBitmap(String name);
  Future<void> validateCache(List<String> validNames);
}