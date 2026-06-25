import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/surah_model.dart';
import '../providers/bookmark_provider.dart';
import '../providers/surah_providers.dart';
import '../widgets/ayat_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;

class SurahDetailScreen extends ConsumerWidget {
  final int nomorSurah;

  const SurahDetailScreen({super.key, required this.nomorSurah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahDetailProvider(nomorSurah));

    return Scaffold(
      appBar: AppBar(
        title: surahAsync.maybeWhen(
          data: (s) => Text(s.namaLatin),
          orElse: () => const Text('Memuat...'),
        ),
      ),
      body: surahAsync.when(
        loading: () => const LoadingWidget(),
        error: (err, _) => custom.ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(surahDetailProvider(nomorSurah)),
        ),
        data: (surah) {
          return ListView.builder(
            // optimasi: ListView.builder hanya build item yang
            // terlihat di viewport, bukan render 286 ayat sekaligus
            itemCount: surah.ayatList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _SurahHeader(surah: surah);

              final ayat = surah.ayatList[index - 1];
              return GestureDetector(
                onLongPress: () {
                  ref.read(bookmarkProvider.notifier).saveLastRead(
                        surah.nomor,
                        surah.namaLatin,
                        ayat.nomorAyat,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ayat ${ayat.nomorAyat} disimpan sebagai bacaan terakhir',
                      ),
                    ),
                  );
                },
                child: AyatCard(ayat: ayat),
              );
            },
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final Surah surah;
  const _SurahHeader({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(surah.nama, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            '${surah.namaLatin} • ${surah.arti}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text('${surah.tempatTurun} • ${surah.jumlahAyat} ayat'),
          const SizedBox(height: 4),
          Text(
            'Tekan & tahan ayat untuk menyimpan sebagai bacaan terakhir',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
