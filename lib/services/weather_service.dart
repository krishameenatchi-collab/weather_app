import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/app_exceptions.dart';

class WeatherService {
  static const String geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final geoUrl = Uri.parse('$geoBaseUrl?name=$cityName&count=1');
      final geoResponse = await http.get(geoUrl).timeout(const Duration(seconds: 10));

      if (geoResponse.statusCode != 200) throw NetworkException();

      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || geoData['results'].isEmpty) {
        throw CityNotFoundException();
      }

      final lat = (geoData['results'][0]['latitude'] as num).toDouble();
      final lon = (geoData['results'][0]['longitude'] as num).toDouble();
      final resolvedName = geoData['results'][0]['name'];

      return await getWeatherByCoords(lat, lon, cityName: resolvedName);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException();
    }
  }

  Future<WeatherModel> getWeatherByCoords(double lat, double lon, {String cityName = 'Current Location'}) async {
    try {
      final weatherUrl = Uri.parse(
        '$weatherBaseUrl?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&timezone=auto&forecast_days=5',
      );
      final weatherResponse = await http.get(weatherUrl).timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) throw NetworkException();

      final weatherData = jsonDecode(weatherResponse.body);
      return WeatherModel.fromJson(weatherData, cityName, lat, lon);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException();
    }
  }
}