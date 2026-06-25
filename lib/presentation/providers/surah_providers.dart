import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/surah_model.dart';
import 'repository_provider.dart';

/// Daftar 114 surah. autoDispose biar state dibuang kalau halaman
/// yang pakai sudah tidak ada listener-nya (hemat memory).
final surahListProvider = FutureProvider.autoDispose<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurahList();
});

/// Detail 1 surah berdasarkan nomor. `.family` artinya provider ini
/// menerima parameter (nomor surah) dan Riverpod otomatis cache
/// per-parameter — pindah surah 1 -> 2 -> balik ke 1 tidak fetch ulang.
final surahDetailProvider =
    FutureProvider.family.autoDispose<Surah, int>((ref, nomor) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurahDetail(nomor);
});

/// Helper untuk pull-to-refresh: force fetch ulang dari API (skip cache)
/// lalu invalidate provider supaya UI rebuild dengan data baru.
final refreshSurahListProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repo = ref.read(quranRepositoryProvider);
    await repo.getSurahList(forceRefresh: true);
    ref.invalidate(surahListProvider);
  };
});
