import 'package:maps_core/maps/models/models.dart';
import 'package:maps_core/maps/extensions/extensions.dart';

class Route {
  final ViewPort? bounds;
  final String? copyrights;
  final List<LatLng>? points;
  final String? summary;
  final List<String>? warning;
  final List<String>? waypointOrder;
  final List<RouteLeg>? legs;

  List<LatLng>? shortenedPoints(int step) {
    return points?.whereIndexed((point, i) => i % step == 0).toList();
  }

  Route({
    this.bounds,
    this.copyrights,
    this.points,
    this.summary,
    this.warning,
    this.waypointOrder,
    this.legs
  });

  factory Route.fromJson(Map<String, dynamic>? json, {int? pointsSkipStep}) {
    final ViewPort bounds = ViewPort.fromJson(json?['bounds']);
    final String? copyrights = json?['copyrights'];
    final String? encodedPoints = json?['overview_polyline']?['points'];
    final List<LatLng> points = _decodePolyline(encodedPoints ?? '', skipStep: pointsSkipStep);
    final String? summary = json?['summary'];
    final List<RouteLeg>? legs = (json?['legs'] as List<dynamic>?)
        ?.map((json) => RouteLeg.fromJson(json)).toList();
    return Route(
      bounds: bounds,
      copyrights: copyrights,
      points: points,
      summary: summary,
      legs: legs,
    );
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

  factory RouteDistance.fromJson(Map<String, dynamic>? json) {
    return RouteDistance(json?["text"], json?["value"]);
  }
}

class RouteDuration {
  final String? text;
  final double? value;

  RouteDuration(this.text, this.value);

  factory RouteDuration.fromJson(Map<String, dynamic>? json) {
    return RouteDuration(json?["text"], json?["value"]);
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
  int i=0;
  while (index < len) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = (poly[index++]).codeUnitAt(0) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dLat = ((result & 1) != 0
        ? (result >> 1).toReversed8Bit().toSignedInt()
        : (result >> 1));
    lat += dLat;
    shift = 0;
    result = 0;
    do {
      b = (poly[index++]).codeUnitAt(0) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dLng = ((result & 1) != 0
        ? (result >> 1).toReversed8Bit().toSignedInt()
        : (result >> 1));
    lng += dLng;
    if (skipStep == null || skipStep <= 1 || i % skipStep == 0) {
      decoded.add(LatLng(lat / 100000.0, lng / 100000.0));
    }
    i++;
  }
  return decoded;
}