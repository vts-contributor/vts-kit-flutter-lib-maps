import 'package:collection/collection.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/models/models.dart';
import 'package:uuid/uuid.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class MapRoute {
  String id;
  final ViewPort? bounds;
  final String? copyrights;
  final List<LatLng>? points;
  final String? summary;
  final List<String>? warning;
  final List<String>? waypointOrder;
  final List<RouteLeg>? legs;

  RouteConfig? config;
  List<LatLng>? sortedWaypoints;

  List<LatLng>? shortenedPoints(int step) {
    return points?.whereIndexed((i, point) => i % step == 0).toList();
  }

  MapRoute({
    required this.id,
    this.bounds,
    this.copyrights,
    this.points,
    this.summary,
    this.warning,
    this.waypointOrder,
    this.legs,
    this.config,
  });

  factory MapRoute.fromJson(Map<String, dynamic>? json, {int? pointsSkipStep}) {
    final ViewPort bounds = ViewPort.fromJson(json?['bounds']);
    final String? copyrights = json?['copyrights'];
    final String? encodedPoints = json?['overview_polyline']?['points'];
    final List<LatLng> points = _decodePolyline(encodedPoints ?? '', skipStep: pointsSkipStep);
    final String? summary = json?['summary'];
    final List<RouteLeg>? legs = (json?['legs'] as List<dynamic>?)
        ?.map((json) => RouteLeg.fromJson(json)).toList();
    return MapRoute(
      id: const Uuid().v4(),
      bounds: bounds,
      copyrights: copyrights,
      points: points,
      summary: summary,
      legs: legs,
    );
  }

  List<LatLng>? get pointsFromLegs {
    return legs?.map((leg) =>
        //return points of steps of a leg
        leg.steps?.map((step) => step.points).whereNotNull().reduce((value, element) => value + element)
    ).whereNotNull().reduce((value, element) => value + element).toList();
  }

  List<LatLng>? tryGetNonNullOrEmptyPoints() {
    List<LatLng>? points = this.points;
    return (points != null && points.isNotEmpty) ? points: pointsFromLegs;
  }


  Map<String, dynamic> toJson() {
    return {
      'bounds': bounds?.toJson(),
      'copyrights': copyrights,
      'overview_polyline': {
        'points': points?.isNotEmpty == true ? _encodePolyline(points!) : null,
      },
      'summary': summary,
      'warning': warning,
      'waypoint_order': waypointOrder,
      'legs': legs?.map((leg) => {
        'distance': {
          'text': leg.distance?.text,
          'value': leg.distance?.value,
        },
        'duration': {
          'text': leg.duration?.text,
          'value': leg.duration?.value,
        },
        'start_address': leg.startAddress,
        'end_address': leg.endAddress,
        'start_location': leg.startLocation?.toJson(),
        'end_location': leg.endLocation?.toJson(),
        'steps': leg.steps?.map((step) => {
          'distance': {
            'text': step.distance?.text,
            'value': step.distance?.value,
          },
          'duration': {
            'text': step.duration?.text,
            'value': step.duration?.value,
          },
          'start_location': step.startLocation?.toJson(),
          'end_location': step.endLocation?.toJson(),
          'html_instructions': step.instructions,
          'maneuver': step.maneuver,
          'polyline': {
            'points': step.points?.isNotEmpty == true ? _encodePolyline(step.points!) : null,
          },
          'travel_mode': step.travelMode?.toString(),
        }).toList(),
      }).toList(),
    };
  }
}

class RouteLeg {
  final RouteDistance? distance;
  final RouteDuration? duration;
  final String? endAddress;
  final String? startAddress;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final List<RouteStep>? steps;

  //traffic speed entry and via_waypoint

  RouteLeg({
    this.distance,
    this.duration,
    this.startAddress,
    this.endAddress,
    this.startLocation,
    this.endLocation,
    this.steps
  });

  factory RouteLeg.fromJson(Map<String, dynamic>? json) {
    return RouteLeg(
      distance: RouteDistance.fromJson(json?["distance"]),
      duration: RouteDuration.fromJson(json?["duration"]),
      startAddress: json?["start_address"],
      endAddress: json?["end_address"],
      startLocation: LatLng.fromJson(json?["start_location"]),
      endLocation: LatLng.fromJson(json?["fromJson"]),
      steps: (json?["steps"] as List<dynamic>?)?.map((json) => RouteStep.fromJson(json)).toList()
    );
  }
}

class RouteDistance {
  final String? text;
  final double? value;

  RouteDistance(this.text, this.value);

  factory RouteDistance.fromJson(Map<String, dynamic>? json) =>
      RouteDistance(
        json?["text"] as String?,
        (json?["value"] is int
            ? (json?["value"] as int).toDouble()
            : json?["value"] as double?),
      );

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "value": value,
    };
  }
}

class RouteDuration {
  final String? text;
  final double? value;

  RouteDuration(this.text, this.value);

  factory RouteDuration.fromJson(Map<String, dynamic>? json) {
    return RouteDuration(
      json?["text"] as String?,
      (json?["value"] is int
          ? (json?["value"] as int).toDouble()
          : json?["value"] as double?),
    );
  }

  toJson() {
    return {
      "text": text,
      "value": value,
    };
  }
}

class RouteStep {
  final RouteDistance? distance;
  final RouteDuration? duration;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final String? instructions;
  final String? maneuver;
  final List<LatLng>? points;
  final TravelMode? travelMode;

  RouteStep({
    this.distance,
    this.duration,
    this.startLocation,
    this.endLocation,
    this.instructions,
    this.maneuver,
    this.points,
    this.travelMode
  });

  factory RouteStep.fromJson(Map<String, dynamic>? json) {
    List<LatLng> points = _decodePolyline(json?["polyline"]?["points"]);
    return RouteStep(
      distance: RouteDistance.fromJson(json?["distance"]),
      duration: RouteDuration.fromJson(json?["duration"]),
      startLocation: LatLng.fromJson(json?["start_location"]),
      endLocation: LatLng.fromJson(json?["start_location"]),
      instructions: json?["html_instructions"],
      maneuver: json?["maneuver"],
      points: points,
      travelMode: TravelMode.fromString(json?["travel_mode"]),
    );
  }
}

enum TravelMode {
  driving,
  drivingWithTraffic,
  walking;

  static TravelMode? fromString(String? string) {
    string = string?.toLowerCase();

    if (string == "driving") {
      return TravelMode.driving;
    } else if (string == "walking") {
      return TravelMode.walking;
    } else {
      return null;
    }
  }

  @override
  String toString() {
    switch(this) {
      case TravelMode.driving:
        return "driving";
      case TravelMode.walking:
        return "walking";
      case TravelMode.drivingWithTraffic:
        return "driving";
    }
  }

  vt.VTMapNavigationMode toViettel() {
    switch(this) {
      case TravelMode.driving:
        return vt.VTMapNavigationMode.driving;
      case TravelMode.drivingWithTraffic:
        return vt.VTMapNavigationMode.drivingWithTraffic;
      case TravelMode.walking:
        return vt.VTMapNavigationMode.walking;
    }
  }
}

///[skipStep]: skip this amount of points between two consecutive points
///
/// Ex: skipStep = 2: ... point14, point15, point16, point17... => ...point14, point17...
List<LatLng> _decodePolyline(String encoded, {int? skipStep}) {
  final poly = encoded;
  int len = poly.length;
  int index = 0;
  List<LatLng> decoded = [];
  int lat = 0;
  int lng = 0;
  while (index < len) {
    int b;
    int shift = 0;
    int result = 1;
    do {
      b = poly.codeUnitAt(index++) - 63 - 1;
      result += b << shift;
      shift += 5;
    } while (b >= 0x1f);
    lat += (result & 1) != 0? ~(result >> 1): (result >> 1);

    shift = 0;
    result = 1;
    do {
      b = poly.codeUnitAt(index++) - 63 - 1;
      result += b << shift;
      shift += 5;
    } while (b >= 0x1f);
    lng += (result & 1) != 0? ~(result >> 1): (result >> 1);

    decoded.add(LatLng(lat * 1e-5, lng * 1e-5));
  }
  return decoded;
}

String _encodePolyline(List<LatLng> points) {
  var result = StringBuffer();
  var lat = 0;
  var lng = 0;

  for (var point in points) {
    var latNew = (point.latitude * 1e5).round();
    var lngNew = (point.longitude * 1e5).round();

    _encodeValue(result, latNew - lat);
    _encodeValue(result, lngNew - lng);

    lat = latNew;
    lng = lngNew;
  }

  return result.toString();
}

void _encodeValue(StringBuffer result, int value) {
  value = (value < 0) ? ~(value << 1) : (value << 1);
  while (value >= 0x20) {
    result.writeCharCode((0x20 | (value & 0x1f)) + 63);
    value >>= 5;
  }
  result.writeCharCode(value + 63);
}
