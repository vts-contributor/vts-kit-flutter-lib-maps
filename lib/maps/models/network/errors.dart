import 'language.dart';

class ServerResponseError implements Exception {
  final String message;

  ServerResponseError(this.message);

  @override
  String toString() => message;
}

class ImplicitServerResponseError extends ServerResponseError {
  final Exception rootCause;

  ImplicitServerResponseError({required this.rootCause}) : super('');
}

class UnsupportedLanguageException implements Exception {
  final String message;
  final Language? language;

  UnsupportedLanguageException(this.message, this.language);

  @override
  String toString() => message;
}
