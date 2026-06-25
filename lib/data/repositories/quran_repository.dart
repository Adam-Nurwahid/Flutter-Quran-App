import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/surah_model.dart';

class QuranRepository {
  final ApiClient _apiClient;

  QuranRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Ambil daftar 114 surah.
  /// Optimasi: hasil di-cache ke SharedPreferences selama [AppConstants.cacheDuration]
  /// supaya buka app berikutnya tidak selalu hit API & tetap bisa baca daftar surah
  /// walau lagi offline (selama cache belum expired / belum pernah online sama sekali
  /// akan tetap gagal, itu wajar untuk app non-offline-first).
  Future<List<Surah>> getSurahList({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedTime = prefs.getInt(AppConstants.prefSurahCacheTime);
      final cachedData = prefs.getString(AppConstants.prefSurahCache);

      if (cachedData != null && cachedTime != null) {
        final age = DateTime.now().millisecondsSinceEpoch - cachedTime;
        if (age < AppConstants.cacheDuration.inMilliseconds) {
          final list = json.decode(cachedData) as List;
          return list
              .map((e) => Surah.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    final response = await _apiClient.get('${AppConstants.baseUrl}/surat');
    final data = response['data'] as List;
    final surahList = data
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList();

    // simpan cache
    await prefs.setString(AppConstants.prefSurahCache, json.encode(data));
    await prefs.setInt(
      AppConstants.prefSurahCacheTime,
      DateTime.now().millisecondsSinceEpoch,
    );

    return surahList;
  }

  Future<Surah> getSurahDetail(int nomor) async {
    final response = await _apiClient.get(
      '${AppConstants.baseUrl}/surat/$nomor',
    ); //
    final surahData = response['data'] as Map<String, dynamic>;

    try {
      final enResponse = await _apiClient.get(
        'https://api.alquran.cloud/v1/surah/$nomor/en.sahih',
      );

      if (enResponse['code'] == 200) {
        final List enAyatList = enResponse['data']['ayahs'] as List;
        final List idAyatList = surahData['ayat'] as List;

        for (int i = 0; i < idAyatList.length; i++) {
          if (i < enAyatList.length) {
            idAyatList[i]['teksInggris'] = enAyatList[i]['text'] ?? '';
          }
        }
      }
    } catch (_) {
    }

    return Surah.fromJson(surahData); //
  }
}
