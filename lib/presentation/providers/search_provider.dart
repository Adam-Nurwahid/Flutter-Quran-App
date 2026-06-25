import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/surah_model.dart';
import 'surah_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Derived provider: filter surahListProvider berdasarkan searchQueryProvider.
/// Tidak melakukan request API baru — murni filter di memory, jadi instan.
final filteredSurahProvider = Provider<List<Surah>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final surahAsync = ref.watch(surahListProvider);

  return surahAsync.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((s) {
        return s.namaLatin.toLowerCase().contains(query) ||
            s.arti.toLowerCase().contains(query) ||
            s.nama.contains(query) ||
            s.nomor.toString() == query;
      }).toList();
    },
    orElse: () => [],
  );
});
