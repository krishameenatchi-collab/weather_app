import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class SavedCityTile extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SavedCityTile({
    super.key,
    required this.weather,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Text(weather.getWeatherIcon(), style: const TextStyle(fontSize: 28)),
        title: Text(weather.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(weather.condition),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${weather.temperature.round()}°C', style: const TextStyle(fontSize: 18)),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}