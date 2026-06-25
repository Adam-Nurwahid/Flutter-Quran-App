import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';


class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(AppConstants.prefThemeMode);
    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeMode, newMode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(22.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(AppConstants.prefFontSize) ?? 22.0;
  }

  Future<void> setSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefFontSize, size);
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class DisplayToggleNotifier extends StateNotifier<bool> {
  final String prefKey;
  DisplayToggleNotifier(this.prefKey) : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(prefKey) ?? true; // default tampil (true)
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, state);
  }
}

final showLatinProvider = StateNotifierProvider<DisplayToggleNotifier, bool>((ref) {
  return DisplayToggleNotifier('show_latin');
});

final showTranslationProvider = StateNotifierProvider<DisplayToggleNotifier, bool>((ref) {
  return DisplayToggleNotifier('show_translation');
});

// 1. Provider Bahasa Terjemahan
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('id') { _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(AppConstants.prefLanguage) ?? 'id';
  }
  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguage, lang);
  }
}
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) => LanguageNotifier());

// 2. Provider Pilihan Qari Audio
class QariNotifier extends StateNotifier<String> {
  QariNotifier() : super('01') { _load(); } // default '01' (Mishary Rashid Al-Alafasy)
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(AppConstants.prefSelectedQari) ?? '01';
  }
  Future<void> setQari(String qariId) async {
    state = qariId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefSelectedQari, qariId);
  }
}
final qariProvider = StateNotifierProvider<QariNotifier, String>((ref) => QariNotifier());

// 3. Provider Tampilan Tanggal Hijriah
class ShowHijriNotifier extends StateNotifier<bool> {
  ShowHijriNotifier() : super(true) { _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.prefShowHijri) ?? true;
  }
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefShowHijri, state);
  }
}
final showHijriProvider = StateNotifierProvider<ShowHijriNotifier, bool>((ref) => ShowHijriNotifier());

// 4. Provider Notifikasi & Reminder Waktu Sholat
class PrayerReminderNotifier extends StateNotifier<bool> {
  PrayerReminderNotifier() : super(false) { _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.prefPrayerReminder) ?? false;
  }
// Modifikasi method toggleReminder pada Notifier yang sudah kita buat sebelumnya:
  Future<void> toggleReminder(Map<String, String> prayerTimes) async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefPrayerReminder, state);

    if (state) {
      int id = 0;
      prayerTimes.forEach((sholatName, timeStr) {
        final splitTime = timeStr.split(':');
        final now = DateTime.now();
        final prayerDateTime = DateTime(
          now.year, now.month, now.day,
          int.parse(splitTime[0]),
          int.parse(splitTime[1]),
        );

        NotificationService.schedulePrayerNotification(
          id: id++,
          sholatName: sholatName,
          time: prayerDateTime,
        );
      });
    } else {
      NotificationService.cancelAllNotifications();
    }
  }
  void _scheduleAllPrayers() { /* Logika local notifications */ }
  void _cancelAllPrayers() { /* Logika pembatalan notifications */ }
}
final prayerReminderProvider = StateNotifierProvider<PrayerReminderNotifier, bool>((ref) => PrayerReminderNotifier());