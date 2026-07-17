import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _seedColor = 0xFF1DB954; // 波点绿
  double _fontScale = 1.0;
  bool _carMode = false;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  int get seedColor => _seedColor;
  double get fontScale => _fontScale;
  bool get carMode => _carMode;
  bool get isDarkMode => _isDarkMode;

  // 预设主题色
  static const List<Map<String, dynamic>> presetColors = [
    {'name': '波点绿', 'color': 0xFF1DB954},
    {'name': '酷狗蓝', 'color': 0xFF2D8CF2},
    {'name': '樱花粉', 'color': 0xFFFF6B9D},
    {'name': '暖阳橙', 'color': 0xFFFF9500},
    {'name': '优雅紫', 'color': 0xFF9C27B0},
    {'name': '清新青', 'color': 0xFF00BCD4},
    {'name': '石墨灰', 'color': 0xFF607D8B},
    {'name': '中国红', 'color': 0xFFE53935},
  ];

  ThemeController() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _seedColor = prefs.getInt('seedColor') ?? 0xFF1DB954;
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;
    _carMode = prefs.getBool('carMode') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setSeedColor(int color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', scale);
    notifyListeners();
  }

  Future<void> toggleCarMode() async {
    _carMode = !_carMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('carMode', _carMode);
    notifyListeners();
  }

  void updateBrightness(bool isDark) {
    _isDarkMode = isDark;
  }

  ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(_seedColor),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24 * _fontScale,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 20 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 18 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 16 * _fontScale,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(fontSize: 16 * _fontScale),
        bodyMedium: TextStyle(fontSize: 14 * _fontScale),
        bodySmall: TextStyle(fontSize: 12 * _fontScale),
      ),
    );
  }

  ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(_seedColor),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24 * _fontScale,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 20 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 18 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 16 * _fontScale,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(fontSize: 16 * _fontScale),
        bodyMedium: TextStyle(fontSize: 14 * _fontScale),
        bodySmall: TextStyle(fontSize: 12 * _fontScale),
      ),
    );
  }
}
