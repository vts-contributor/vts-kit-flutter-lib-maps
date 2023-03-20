import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/models/core_map_type.dart';

import '../models/core_map_data.dart';
import '../models/polygon.dart';

abstract class CoreMapController extends ChangeNotifier {

  CoreMapType get coreMapType;
  late CoreMapData _data;

  CoreMapController(CoreMapData data) {
    _data = data;
  }

  CoreMapData get data => _data;

  Future<void> addPolygon(Polygon polygon);
  Future<bool> removePolygon(String polygonId);
  Future<void> reloadWithData(CoreMapData newData);
}

