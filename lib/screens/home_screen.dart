import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../utils/app_exceptions.dart';
import '../utils/background_helper.dart';
import '../widgets/weather_detail_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/saved_city_tile.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _searchHistory = [];
  List<WeatherModel> _savedCities = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadSavedCities();
  }

  Future<void> _loadHistory() async {
    final history = await _storageService.getSearchHistory();
    setState(() => _searchHistory = history);
  }

  Future<void> _loadSavedCities() async {
    final cities = await _storageService.getSavedCities();
    List<WeatherModel> results = [];
    for (final city in cities) {
      try {
        final w = await _weatherService.getWeatherByCity(city);
        results.add(w);
      } catch (_) {
        // skip city that fails to load
      }
    }
    setState(() => _savedCities = results);
  }

  Future<void> _searchWeather([String? cityOverride]) async {
    final city = cityOverride ?? _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _errorMessage = 'Please enter a city name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getWeatherByCity(city);
      await _storageService.addToSearchHistory(weather.cityName);
      await _loadHistory();
      setState(() {
        _weather = weather;
        _isLoading = false;
        _cityController.text = weather.cityName;
      });
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _weather = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
        _weather = null;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _weatherService.getWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weather = weather;
        _isLoading = false;
        _cityController.text = weather.cityName;
      });
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not get current location.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCurrentCity() async {
    if (_weather == null) return;
    await _storageService.addSavedCity(_weather!.cityName);
    await _loadSavedCities();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_weather!.cityName} added to tracked cities')),
      );
    }
  }

  Future<void> _removeSavedCity(String city) async {
    await _storageService.removeSavedCity(city);
    await _loadSavedCities();
  }

  Future<void> _clearHistory() async {
    await _storageService.clearSearchHistory();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = BackgroundHelper.getGradient(
      _weather?.weatherCode ?? 0,
      widget.isDarkMode,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_weather != null) await _searchWeather(_weather!.cityName);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                  ),
                  const SizedBox(height: 10),
                  if (_searchHistory.isNotEmpty) _buildHistoryChips(),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(color: Colors.white),
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_weather != null && !_isLoading) _buildWeatherInfo(),
                  const SizedBox(height: 30),
                  if (_savedCities.isNotEmpty) _buildSavedCities(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Weather App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        Row(
          children: [
            Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
            Switch(
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
              activeTrackColor: Colors.white54,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter city name',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _searchWeather(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: () => _searchWeather(),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildHistoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Searches', style: TextStyle(color: Colors.white70, fontSize: 13)),
            TextButton(onPressed: _clearHistory, child: const Text('Clear', style: TextStyle(color: Colors.white70))),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _searchHistory.map((city) {
            return ActionChip(
              label: Text(city),
              onPressed: () => _searchWeather(city),
              backgroundColor: Colors.white.withOpacity(0.15),
              labelStyle: const TextStyle(color: Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final w = _weather!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(w.cityName, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: _saveCurrentCity,
              tooltip: 'Track this city',
            ),
          ],
        ),
        Text(w.getWeatherIcon(), style: const TextStyle(fontSize: 70)),
        Text('${w.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
        Text(w.condition, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WeatherDetailCard(icon: Icons.thermostat, label: 'Feels Like', value: '${w.feelsLike.toStringAsFixed(1)}°C'),
            WeatherDetailCard(icon: Icons.water_drop, label: 'Humidity', value: '${w.humidity}%'),
            WeatherDetailCard(icon: Icons.air, label: 'Wind', value: '${w.windSpeed.toStringAsFixed(1)} km/h'),
          ],
        ),
        const SizedBox(height: 24),
        if (w.forecast.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('5-Day Forecast', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: w.forecast.map((f) => ForecastCard(forecast: f)).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSavedCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Tracked Cities', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ..._savedCities.map((city) => SavedCityTile(
              weather: city,
              onTap: () => _searchWeather(city.cityName),
              onRemove: () => _removeSavedCity(city.cityName),
            )),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}