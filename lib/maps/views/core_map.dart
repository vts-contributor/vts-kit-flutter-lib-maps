import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/views/core_google_map.dart';
import 'package:maps_core/maps/views/core_viettel_map.dart';

class CoreMap extends StatefulWidget {

  final CoreMapType type;

  final CoreMapData data;

  final CoreMapShapes? shapes;

  final CoreMapCallbacks? callbacks;

  const CoreMap({super.key,
    this.type = CoreMapType.viettel,
    this.callbacks,
    required this.data,
    this.shapes,
  });

  @override
  State<CoreMap> createState() => _CoreMapState();
}

class _CoreMapState extends State<CoreMap> {

  CoreMapController? _controller;

  // StreamSubscription<Position>? _locationStreamSubscription;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    CoreMapCallbacks callbacks = widget.callbacks ?? CoreMapCallbacks();
    return _buildMap(
      type: widget.type,
      data: widget.data.copyWith(
          initialCameraPosition: _controller?.getCurrentPosition() ?? widget.data.initialCameraPosition
      ),
      shapes: widget.shapes,
      callbacks: callbacks.copyWith(
        onMapCreated: (controller) {
          _controller = controller;
          widget.callbacks?.onMapCreated?.call(controller);
        },
      ),
    );
  }

  Widget _buildMap({
    required CoreMapType type,
    required CoreMapData data,
    CoreMapShapes? shapes,
    CoreMapCallbacks? callbacks,
  }) {
    switch (type) {
      case CoreMapType.google:
        return CoreGoogleMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes(),
        );
      case CoreMapType.viettel:
        return CoreViettelMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes()
        );
    }
  }

  // void _initUserLocationListener() {
  //   late LocationSettings locationSettings;
  //
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     locationSettings = AndroidSettings(
  //         accuracy: LocationAccuracy.high,
  //         distanceFilter: 100,
  //         forceLocationManager: true,
  //         intervalDuration: const Duration(seconds: 10),
  //         //(Optional) Set foreground notification config to keep the app alive
  //         //when going to the background
  //         foregroundNotificationConfig: const ForegroundNotificationConfig(
  //           notificationText:
  //           "Example app will continue to receive your location even when you aren't using it",
  //           notificationTitle: "Running in Background",
  //           enableWakeLock: true,
  //         )
  //     );
  //   } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
  //     locationSettings = AppleSettings(
  //       accuracy: LocationAccuracy.high,
  //       activityType: ActivityType.fitness,
  //       distanceFilter: 100,
  //       pauseLocationUpdatesAutomatically: true,
  //       // Only set to true if our app will be started up in the background.
  //       showBackgroundLocationIndicator: false,
  //     );
  //   } else {
  //     locationSettings = LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 100,
  //     );
  //   }
  //
  //   _locationStreamSubscription = Geolocator
  //       .getPositionStream(locationSettings: locationSettings)
  //       .listen((Position? position) {
  //         Log.d("CORELOCATION", position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
  //       },
  //     onError: (error, stackTrace) {
  //         Log.e("CORELOCATION", error.toString(), stackTrace: stackTrace);
  //         Geolocator.openAppSettings();
  //     }
  //   );
  // }
  //
  // @override
  // void dispose() {
  //   _locationStreamSubscription?.cancel();
  //   super.dispose();
  // }
}