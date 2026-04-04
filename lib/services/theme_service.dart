import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _themeKey = 'selected_theme';

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'gold';
  }

  static Future<void> saveTheme(String themeKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeKey);
  }
}
