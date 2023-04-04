import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';

class RoutingViewModel extends ChangeNotifier {
  late Directions _directions;
  final MapsAPIService mapsAPIService;

  RoutingViewModel(this.mapsAPIService);

  Future<Directions> downloadDirections() async {
   return  _directions = await mapsAPIService.direction(
      originLat: 16.073977,
      originLng: 108.214190,
      destLat: 16.078536,
      destLng: 108.209439,
      alternatives: true
    );
  }
}