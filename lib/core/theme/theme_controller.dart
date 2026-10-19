import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._(this._preferences, this._themeMode);

  static const String _themeModeKey = 'shopsphere_theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeController> create() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(_themeModeKey);

    final mode = switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return ThemeController._(preferences, mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await _preferences.setString(_themeModeKey, value);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();

    assert(scope != null, 'ThemeControllerScope not found in widget tree.');
    return scope!.notifier!;
  }
}
