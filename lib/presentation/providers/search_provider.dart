import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/surah_model.dart';
import 'surah_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
String _normalizeString(String text) {
  return text
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll("'", "")
      .replaceAll(' ', '')
      .trim();
}

final filteredSurahProvider = Provider<List<Surah>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final normalizedQuery = _normalizeString(query);
  final surahAsync = ref.watch(surahListProvider);

  return surahAsync.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((s) {
        final normalizedNamaLatin = _normalizeString(s.namaLatin);
        final normalizedArti = _normalizeString(s.arti);
        return normalizedNamaLatin.contains(normalizedQuery) ||
            normalizedArti.contains(normalizedQuery) ||
            s.nama.contains(query) ||
            s.nomor.toString() == query;
      }).toList();
    },
    orElse: () => [],
  );
});
