import '../maps_api.dart';

class PlaceResponse extends MapsAPIResponse {
  final String? status;

  PlaceResponse({
    Map<String, dynamic>? content,
    String? message,
    int? errorCode,
    this.status,
  }) : super(
          content: content,
          message: message,
          errorCode: errorCode,
        );
}
