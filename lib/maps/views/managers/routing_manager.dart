import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/models/auto_route.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;


abstract class RoutingManager {

  static const double moveCameraPadding = 10;

  static const String logTag = "ROUTING MANAGER";

  ///build routes base on [directions]
  Future<void> buildListMapRoute(List<MapRoute>? routes);

  ///options
  Future<void> buildRoutes(RoutingOptions options);

  ///add a route go that will go through waypoints 
  Future<void> addRoute(RouteConfig routeConfig);

  ///add multiple routes
  Future<void> addRoutes(List<RouteConfig> routeConfigs);

  ///clear all routes
  Future<void> clearAllRoutes();

  ///remove all routes with [id]
  Future<void> removeRoutes(String id);

  ///start navigation with the selected route
  ///
  /// if no route is selected, this will has no effect
  Future<void> startNavigation();

  ///listener will be notified when a route was tapped
  void addRouteTapListener(void Function(String id) listener);

  ///remove listener
  void removeRouteTapListener(void Function(String id) listener);

  ///select a route with id,
  ///have to buildDirections first or else this always return false
  bool selectRoute(String id, {
    bool zoomToRoute = true,
  });

  // set start location of a route with icon
  void setStartLocation(LatLng position, [Widget? icon]);
  
  // set end location of a route with icon
  void setEndLocation(LatLng position, [Widget? icon]);

  ///get current selected route if possible
  MapRoute? get selectedRoute;
}

class RoutingOptions {

  /// The initial Latitude of the Map View
  final double? initialLatitude;

  /// The initial Longitude of the Map View
  final double? initialLongitude;

  /// 2-letter ISO 639-1 code for language. This property affects the sentence contained within the RouteStep.instructions property, but it does not affect any road names contained in that property or other properties such as RouteStep.name. Defaults to "en" if an unsupported language is specified. The languages in this link are supported: https://docs.mapbox.com/android/navigation/overview/localization/ or https://docs.mapbox.com/ios/api/navigation/0.14.1/localization-and-internationalization.html
  final String? language;

  /// Zoom controls the scale of the map and consumes any value between 0 and 22. At zoom level 0, the viewport shows continents and other world features. A middle value of 11 will show city level details, and at a higher zoom level, the map will begin to show buildings and points of interest.
  final double? zoom;

  /// Bearing is the direction that the camera is pointing in and measured in degrees clockwise from north.
  ///
  /// The camera's default bearing is 0 degrees (i.e. "true north") causing the map compass to hide until the camera bearing becomes a non-zero value. The mapbox_uiCompass boolean XML attribute allows adjustment of the compass' visibility. Bearing levels use six decimal point precision, which enables you to restrict/set/lock a map's bearing with extreme precision. Besides programmatically adjusting the camera bearing, the user can place two fingertips on the map and rotate their fingers.
  final double? bearing;

  /// Tilt is the camera's angle from the nadir (directly facing the Earth) and uses unit degrees. The camera's minimum (default) tilt is 0 degrees, and the maximum tilt is 60. Tilt levels use six decimal point of precision, which enables you to restrict/set/lock a map's bearing with extreme precision.
  ///
  /// The map camera tilt can also adjust by placing two fingertips on the map and moving both fingers up and down in parallel at the same time or
  final double? tilt;

  ///
  /// When true, alternate routes will be presented
  final bool alternatives;

  /// If the value of this property is true, a returned route may require an immediate U-turn at an intermediate waypoint. At an intermediate waypoint, if the value of this property is false, each returned route may continue straight ahead or turn to either side but may not U-turn. This property has no effect if only two waypoints are specified.
  /// same as 'not continueStraight' on Android
  final bool? allowsUTurnAtWayPoints;

  final bool? enableRefresh;
  // if true voice instruction is enabled
  final bool? voiceInstructionsEnabled;
  //if true, banner instruction is shown and returned
  final bool? bannerInstructionsEnabled;

  /// if true will simulate the route as if you were driving. Always true on iOS Simulator
  final bool? simulateRoute;

  /// The Url of the style the Navigation MapView should use during the day
  final String? mapStyleUrlDay;

  /// The Url of the style the Navigation MapView should use at night
  final String? mapStyleUrlNight;

  /// if true, will reorder the routes to optimize navigation for time and shortest distance using the Travelling Salesman Algorithm. Always false for now
  final bool? isOptimized;

  /// Should animate the building of the Route. Default is True
  final bool? animateBuildRoute;

  /// When the user long presses on a point on the map, set that as the destination
  final bool? longPressDestinationEnabled;

  /// Free-drive mode is a unique Mapbox Navigation SDK feature that allows drivers to navigate without a set destination. This mode is sometimes referred to as passive navigation.
  /// No destination is required when set to true.
  final bool? enableFreeDriveMode;
  // final String padding;//left,top,right,bottom. example '50,100,50,100'
  final EdgeInsets padding;

  final int startIndex;

  final List<LatLng> points;
  final String apiKey;

  final TravelMode mode;

  RoutingOptions(this.apiKey, {
    required this.points,
      this.alternatives = false,
      this.mode = TravelMode.driving,
      this.initialLatitude,
      this.initialLongitude,
      this.language,
      this.zoom,
      this.bearing,
      this.tilt,
      this.allowsUTurnAtWayPoints,
      this.enableRefresh,
      this.voiceInstructionsEnabled,
      this.bannerInstructionsEnabled,
      this.longPressDestinationEnabled,
      this.simulateRoute,
      this.isOptimized,
      this.mapStyleUrlDay,
      this.mapStyleUrlNight,
      this.enableFreeDriveMode,
      this.animateBuildRoute,
      this.padding =
          const EdgeInsets.only(left: 50, top: 100, right: 50, bottom: 100),
      this.startIndex = 0
  });

  vt.VTMapOptions toViettelMapOptions() {
    return vt.VTMapOptions(
      access_token: apiKey,
      allowsUTurnAtWayPoints: allowsUTurnAtWayPoints,
      alternatives: alternatives,
      animateBuildRoute: animateBuildRoute,
      enableFreeDriveMode: enableFreeDriveMode,
      enableRefresh: enableRefresh,
      mode: mode.toViettel(),
      padding: padding,
      startIndex: startIndex,
      language: language,
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
      zoom: zoom,
      bannerInstructionsEnabled: bannerInstructionsEnabled,
      bearing: bearing,
      tilt: tilt,
      voiceInstructionsEnabled: voiceInstructionsEnabled,
      simulateRoute: simulateRoute,
    );
  }
  List<vt.WayPoint> getViettelWaypoints() {
    return points.map((e) => vt.WayPoint(latitude: e.latitude, longitude: e.longitude, name: e.toString())).toList();
  }
}
