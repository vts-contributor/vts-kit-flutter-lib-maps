library core_map;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_core/log/log.dart';

import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/models/auto_route.dart';
import 'package:maps_core/maps/views/widgets/measure_size_widget.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

import 'maps/models/map_objects/bitmap_cache_factory.dart';
import 'maps/models/map_objects/marker_icon_data_factory.dart';
import 'maps/models/map_objects/marker_icon_data_processor.dart';


export 'maps/models/models.dart';
export 'maps/controllers/controllers.dart';
export 'maps/extensions/extensions.dart';
export 'maps/services/services.dart';
export 'maps/views/managers/managers.dart';
export 'maps/utils/utils.dart';

part 'maps/views/core_map.dart';
part 'maps/views/core_viettel_map.dart';
part 'maps/views/core_google_map.dart';

part 'maps/views/managers/location_manager.dart';
part 'maps/views/managers/routing_manager_impl.dart';
part 'maps/views/managers/info_window_manager_impl.dart';
part 'maps/views/managers/info_window_manager.dart';
part 'maps/views/managers/cluster_manager_internal.dart';
part 'maps/views/managers/cluster_manager_internal_impl.dart';
part 'maps/views/managers/cluster_manager.dart';
part 'maps/views/managers/default_cluster_manager_impl.dart';

part 'maps/controllers/implementations/google_map_controller.dart';
part 'maps/controllers/implementations/viettel_map_controller.dart';
part 'maps/controllers/base_core_map_controller.dart';