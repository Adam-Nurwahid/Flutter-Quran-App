import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/quran_repository.dart';


final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});
