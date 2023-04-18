import 'package:maps_core/maps/models/models.dart';

class PlaceList<T extends Place> {
  final List<T> values;
  final String? nextPageToken;

  PlaceList({
    required this.values,
    this.nextPageToken,
  });

  factory PlaceList.fromResponse(
      PlaceListingResponse response, T Function(Map<String, dynamic> json) map) {
    final result = response.list?.map((json) => map(json)).toList() ?? [];
    return PlaceList(
      values: result,
      nextPageToken: response.nextPageToken,
    );
  }
}
