import 'package:maps_core/maps.dart';

class DistanceMatrix {
  String? id;
  final List<String>? destinationAddresses;
  final List<String>? originAddresses;
  final List<List<DistanceMatrixElement>>? rows;

  DistanceMatrix({
    this.destinationAddresses,
    this.originAddresses,
    this.rows
  });

  factory DistanceMatrix.fromJson(Map<String, dynamic>? json) {
    final List<dynamic> rowJson = json?["rows"];
    final List<List<DistanceMatrixElement>> rows = rowJson.map((json) {
      List<dynamic> listElements = json["elements"];
      return listElements.map((e) => DistanceMatrixElement.fromJson(e)).toList();
    }).toList();
    return DistanceMatrix(
      destinationAddresses: (json?["destination_addresses"] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      originAddresses: (json?["origin_addresses"] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      rows: rows
    );
  }
}

class DistanceMatrixElement {
  final RouteDistance? distance;
  final RouteDuration? duration;
  final String? status;

  DistanceMatrixElement({
    this.distance,
    this.duration,
    this.status,
  });

  factory DistanceMatrixElement.fromJson(Map<String, dynamic>? json) {
    final RouteDistance distance = RouteDistance.fromJson(json?["distance"]);
    final RouteDuration duration = RouteDuration.fromJson(json?["duration"]);
    return DistanceMatrixElement(
      distance: distance,
      duration: duration,
      status: json?["status"]
    );
  }
}