import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/models/core_map_type.dart';

import '../models/core_map_data.dart';
import '../models/polygon.dart';

abstract class CoreMapController {

  CoreMapType get coreMapType;
  CoreMapData get data;

  Future<void> addPolygon(Polygon polygon);
  Future<bool> removePolygon(String polygonId);
  Future<void> reloadWithData(CoreMapData data);
  void changeMapType(CoreMapType type);
}

