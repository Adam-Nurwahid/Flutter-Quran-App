class AppConstants {
  AppConstants._();

  // Ganti base URL ini kalau di tutorial kamu pakai API berbeda
  // (misal api.quran.sutanlab.id). Field JSON di repository perlu
  // disesuaikan juga kalau struktur response berbeda.
  static const String baseUrl = 'https://equran.id/api/v2';

  // Keys untuk SharedPreferences
  static const String prefBookmarks = 'bookmarks';
  static const String prefLastRead = 'last_read';
  static const String prefThemeMode = 'theme_mode';
  static const String prefFontSize = 'font_size';
  static const String prefSurahCache = 'surah_list_cache';
  static const String prefSurahCacheTime = 'surah_list_cache_time';

  // Tambah Keys Baru untuk Fitur Baru
  static const String prefLanguage = 'translation_language'; // id atau en
  static const String prefSelectedQari = 'selected_qari'; // 01, 02, 03, dll
  static const String prefShowHijri = 'show_hijri'; // boolean
  static const String prefPrayerReminder = 'prayer_reminder'; // boolean

  static const Duration cacheDuration = Duration(hours: 12);
}
