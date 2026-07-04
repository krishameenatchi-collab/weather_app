# Weather App with Live API

A Flutter mobile application that fetches real-time weather data and forecasts using the Open-Meteo public API. Built as part of the Unlox App Development Week 03 Minor Project.

## Project Overview

This app lets users search for any city and instantly view current weather conditions, a 5-day forecast, and additional details like humidity, wind speed, and feels-like temperature. It demonstrates core Flutter and Dart concepts including stateful widgets, async/await, JSON parsing, and clean API service architecture.

## Features Implemented

### Core Features
- **Home Screen** — App title, search bar, and search button
- **Weather Information Screen** — City name, current temperature, weather condition, humidity, wind speed, feels-like temperature, and weather icon
- **Search Functionality** — Search weather by city name with dynamic updates
- **Error Handling** — Handles invalid city names and network errors with user-friendly messages
- **Responsive UI** — Clean, modern gradient design that adapts to different screen sizes

### Bonus Features
- **Current Location Weather** — Uses device GPS (via `geolocator`) to fetch weather for the user's current location
- **5-Day Weather Forecast** — Horizontal scrollable forecast cards showing daily highs, lows, and conditions
- **Weather-Based Background Changes** — Background gradient dynamically changes based on current weather condition (clear, cloudy, rainy, snowy, stormy, foggy)
- **Dark Mode** — Toggle switch with preference saved locally using `shared_preferences`
- **Search History** — Displays recent searches as tappable chips, with a clear history option
- **Multiple City Tracking** — Save cities to a tracked list, view their weather at a glance, and remove them anytime

## API Used

**[Open-Meteo](https://open-meteo.com/)** — a free, open-source weather API that requires no API key or sign-up.

- **Geocoding API** — converts city names to latitude/longitude coordinates
- **Forecast API** — provides current weather conditions and 5-day daily forecasts

## Tech Stack

| Category | Tool/Package |
|---|---|
| Framework | Flutter (Dart) |
| HTTP Requests | `http` |
| Location Services | `geolocator` |
| Local Storage | `shared_preferences` |
| API | Open-Meteo (Geocoding + Forecast) |

## Project Structure

```
lib/
 ├── screens/
 │   └── home_screen.dart
 ├── services/
 │   ├── weather_service.dart
 │   ├── location_service.dart
 │   └── storage_service.dart
 ├── models/
 │   └── weather_model.dart
 ├── widgets/
 │   ├── weather_detail_card.dart
 │   ├── forecast_card.dart
 │   └── saved_city_tile.dart
 ├── utils/
 │   ├── app_exceptions.dart
 │   └── background_helper.dart
 └── main.dart
```

## Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/krishameenatchi-collab/weather_app.git
   cd weather_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up permissions** (already configured in this repo)
   - Android: location permissions added in `android/app/src/main/AndroidManifest.xml`
   - iOS: location usage description added in `ios/Runner/Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```
   Select a connected device or emulator when prompted.

5. **Grant location permission** when prompted, to use the "Use Current Location" feature.


## Notes

- No API key is required — Open-Meteo is completely free and open.
- Tested on Android emulator with mock GPS locations and physical device GPS.
- Error handling gracefully covers invalid city names, no internet connection, and location permission denial.

## Author

Krisha Meenatchi — B.E. Computer Science and Engineering, SIMATS Engineering University
Built as part of Unlox App Development Internship, Week 03 Minor Project.
