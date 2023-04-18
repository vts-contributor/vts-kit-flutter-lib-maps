import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';

class RoutingViewModel extends ChangeNotifier {
  Directions? directions;
  final MapsAPIService mapsAPIService;

  RoutingViewModel(this.mapsAPIService);

  Future<Directions> downloadDirections(LatLng origin, LatLng dest) async {
   return  directions = await mapsAPIService.direction(
      originLat: origin.lat,
      originLng: origin.lng,
      destLat: dest.lat,
      destLng: dest.lng,
      alternatives: true,
    );
  }
}