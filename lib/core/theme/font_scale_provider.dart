import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection.dart';

const String _fontScaleKey = 'app_font_scale';
const double _defaultFontScale = 1.0;
const double minFontScale = 0.8;
const double maxFontScale = 1.5;

/// Provides the current font scale factor.
/// 1.0 = default, 0.8 = smaller, 1.5 = larger.
final fontScaleProvider =
    NotifierProvider<FontScaleNotifier, double>(FontScaleNotifier.new);

class FontScaleNotifier extends Notifier<double> {
  @override
  double build() {
    final prefs = getIt<SharedPreferences>();
    return prefs.getDouble(_fontScaleKey) ?? _defaultFontScale;
  }

  Future<void> setScale(double scale) async {
    final clamped = scale.clamp(minFontScale, maxFontScale);
    state = clamped;
    final prefs = getIt<SharedPreferences>();
    await prefs.setDouble(_fontScaleKey, clamped);
  }

  Future<void> reset() async {
    state = _defaultFontScale;
    final prefs = getIt<SharedPreferences>();
    await prefs.remove(_fontScaleKey);
  }
}
