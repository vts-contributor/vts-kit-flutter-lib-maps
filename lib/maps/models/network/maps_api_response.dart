import 'json_response.dart';

class MapsAPIResponse extends JsonResponse {
  MapsAPIResponse({
    Map<String, dynamic>? content,
    String? message,
    int? errorCode,
  }) : super(
          content: content,
          errorMessage: message,
          errorCode: errorCode,
        );
}
