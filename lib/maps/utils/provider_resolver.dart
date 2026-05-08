import 'package:flutter/foundation.dart';
import '../constants.dart';
import '../models/core_map_type.dart';

/// Resolves a legacy Viettel Map request to a Google Maps equivalent.
CoreMapType resolveCoreMapType(CoreMapType originalType) {
  if (originalType == CoreMapType.viettel) {
    debugPrint('WARNING: Viettel runtime implementation has been removed. Falling back to Google Maps.');
    return CoreMapType.google;
  }
  return originalType;
}

/// Resolves a legacy Viettel provider string.
String resolveMapProvider(String? provider) {
  if (provider == MapProviderConst.VIETTEL || provider == 'viettel') {
    return MapProviderConst.VIETTEL;
  }
  return provider ?? MapProviderConst.GOOGLE;
}
