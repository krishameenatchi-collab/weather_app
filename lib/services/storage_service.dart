import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _historyKey = 'search_history';
  static const String _savedCitiesKey = 'saved_cities';
  static const String _darkModeKey = 'dark_mode';

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addToSearchHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    history.remove(city); // avoid duplicates
    history.insert(0, city);
    if (history.length > 10) history = history.sublist(0, 10);
    await prefs.setStringList(_historyKey, history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<List<String>> getSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedCitiesKey) ?? [];
  }

  Future<void> addSavedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cities = prefs.getStringList(_savedCitiesKey) ?? [];
    if (!cities.contains(city)) {
      cities.add(city);
      await prefs.setStringList(_savedCitiesKey, cities);
    }
  }

  Future<void> removeSavedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cities = prefs.getStringList(_savedCitiesKey) ?? [];
    cities.remove(city);
    await prefs.setStringList(_savedCitiesKey, cities);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}