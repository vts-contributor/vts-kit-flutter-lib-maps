import 'package:maps_core/maps/models/models.dart';

class PlaceListingResponse extends PlaceResponse {
  final String? nextPageToken;

  PlaceListingResponse(
      {List<dynamic>? list,
      String? message,
      int? errorCode,
      String? status,
      this.nextPageToken})
      : super(
          content: {'first': list},
          message: message,
          errorCode: errorCode,
          status: status,
        );

  List<Map<String, dynamic>>? get list {
    return (content?['first'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>))
        .toList();
  }
}
