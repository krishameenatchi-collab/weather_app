import 'package:flutter/material.dart';

class BackgroundHelper {
  static List<Color> getGradient(int weatherCode, bool isDarkMode) {
    if (isDarkMode) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }

    if (weatherCode == 0) {
      return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]; // clear
    } else if (weatherCode <= 3) {
      return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)]; // cloudy
    } else if (weatherCode <= 48) {
      return [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)]; // fog
    } else if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
      return [const Color(0xFF37474F), const Color(0xFF546E7A)]; // rain
    } else if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
      return [const Color(0xFF8e9eab), const Color(0xFFeef2f3)]; // snow
    } else if (weatherCode <= 99) {
      return [const Color(0xFF232526), const Color(0xFF414345)]; // storm
    }
    return [const Color(0xFF4A90E2), const Color(0xFF9013FE)];
  }
}