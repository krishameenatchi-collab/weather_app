class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class CityNotFoundException extends AppException {
  CityNotFoundException() : super('City not found. Please check the spelling and try again.');
}

class NetworkException extends AppException {
  NetworkException() : super('Network error. Please check your internet connection.');
}