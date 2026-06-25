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
    final fontSize = ref.watch(fontSizeProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final isThisPlaying = audioState.playingAyatNomor == ayat.nomorAyat;
    final showLatin = ref.watch(showLatinProvider);
    final showTranslation = ref.watch(showTranslationProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text('${ayat.nomorAyat}', style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                if (ayat.audioUrl != null)
                  IconButton(
                    icon: Icon(
                      isThisPlaying && audioState.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                    onPressed: () => ref
                        .read(audioPlayerProvider.notifier)
                        .playAyat(ayat.nomorAyat, ayat.audioUrl!),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  ayat.teksArab,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.8,
                    fontFamily: 'Amiri',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (showLatin) ...[
              Text(
                ayat.teksLatin,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (showTranslation)
              Text(ayat.teksIndonesia),
          ],
        ),
      ),
    );
  }
}
