import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final showLatin = ref.watch(showLatinProvider);
    final showTranslation = ref.watch(showTranslationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan tampilan dark mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Tampilkan Latin'),
            subtitle: const Text('Menampilkan transliterasi teks latin'),
            value: showLatin,
            onChanged: (_) => ref.read(showLatinProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Tampilkan Arti'),
            subtitle: const Text('Menampilkan terjemahan bahasa Indonesia'),
            value: showTranslation,
            onChanged: (_) => ref.read(showTranslationProvider.notifier).toggle(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ukuran teks Arab: ${fontSize.toStringAsFixed(0)}'),
                Slider(
                  value: fontSize,
                  min: 16,
                  max: 36,
                  divisions: 10,
                  label: fontSize.toStringAsFixed(0),
                  onChanged: (value) =>
                      ref.read(fontSizeProvider.notifier).setSize(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
