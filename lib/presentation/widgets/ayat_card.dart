import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ayat_model.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';


class AyatCard extends ConsumerWidget {
  final Ayat ayat;
  const AyatCard({super.key, required this.ayat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider); //
    final audioState = ref.watch(audioPlayerProvider); //
    final currentLang = ref.watch(languageProvider);
    final activeQari = ref.watch(qariProvider);
    final showLatin = ref.watch(showLatinProvider);
    final showTranslation = ref.watch(showTranslationProvider);
    final isThisPlaying = audioState.playingAyatNomor == ayat.nomorAyat; //
    final selectedAudioUrl = ayat.audioMap[activeQari] ?? ayat.audioMap.values.first;
    final translationText = currentLang == 'en' ? ayat.teksInggris : ayat.teksIndonesia;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), //
      child: Padding(
        padding: const EdgeInsets.all(16), //
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14, //
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer, //
                  child: Text('${ayat.nomorAyat}', style: const TextStyle(fontSize: 12)), //
                ),
                const Spacer(), //
                IconButton(
                  icon: Icon(
                    isThisPlaying && audioState.isPlaying //
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill, //
                  ),
                  onPressed: () => ref
                      .read(audioPlayerProvider.notifier)
                      .playAyat(ayat.nomorAyat, selectedAudioUrl), // Menerapkan Qari dinamis
                ),
              ],
            ),
            const SizedBox(height: 8), //
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  ayat.teksArab, //
                  textAlign: TextAlign.right, //
                  style: TextStyle(fontSize: fontSize, height: 1.8), //
                ),
              ),
            ),
            if (showLatin) ...[
              const SizedBox(height: 8), //
              Text(
                ayat.teksLatin, //
                style: TextStyle(
                  fontStyle: FontStyle.italic, //
                  color: Theme.of(context).colorScheme.secondary, //
                ),
              ),
            ],
            if (showTranslation) ...[
              const SizedBox(height: 8), //
              Text(translationText), // Menampilkan terjemahan dinamis
            ],
          ],
        ),
      ),
    );
  }
}
