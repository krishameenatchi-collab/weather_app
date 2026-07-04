class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}

class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final double latitude;
  final double longitude;
  final List<DailyForecast> forecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.latitude,
    required this.longitude,
    required this.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String cityName, double lat, double lon) {
    final current = json['current'];
    final daily = json['daily'];

    List<DailyForecast> forecastList = [];
    if (daily != null) {
      final dates = List<String>.from(daily['time']);
      final maxTemps = List<num>.from(daily['temperature_2m_max']);
      final minTemps = List<num>.from(daily['temperature_2m_min']);
      final codes = List<num>.from(daily['weather_code']);

      for (int i = 0; i < dates.length; i++) {
        forecastList.add(DailyForecast(
          date: DateTime.parse(dates[i]),
          maxTemp: maxTemps[i].toDouble(),
          minTemp: minTemps[i].toDouble(),
          weatherCode: codes[i].toInt(),
        ));
      }
    }

    return WeatherModel(
      cityName: cityName,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      condition: mapWeatherCode(current['weather_code']),
      latitude: lat,
      longitude: lon,
      forecast: forecastList,
    );
  }

  static String mapWeatherCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Fog';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String getIconForCode(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 57) return '🌦️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌧️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }

  String getWeatherIcon() => getIconForCode(weatherCode);

  bool get isNightOrCold => weatherCode >= 45; // used for background logic

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'temperature': temperature,
        'weatherCode': weatherCode,
        'condition': condition,
        'latitude': latitude,
        'longitude': longitude,
      };
}