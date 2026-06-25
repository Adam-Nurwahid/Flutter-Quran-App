import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); //
    final fontSize = ref.watch(fontSizeProvider); //

    final currentLang = ref.watch(languageProvider);
    final activeQari = ref.watch(qariProvider);
    final showHijri = ref.watch(showHijriProvider);
    final prayerReminder = ref.watch(prayerReminderProvider);
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


          ListTile(
            title: const Text('Bahasa Terjemahan'),
            subtitle: Text(currentLang == 'id' ? 'Indonesia' : 'English'),
            trailing: DropdownButton<String>(
              value: currentLang,
              items: const [
                DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) ref.read(languageProvider.notifier).setLanguage(val);
              },
            ),
          ),
          const Divider(),

          ListTile(
            title: const Text('Suara Qari Audio'),
            subtitle: const Text('Pilih suara untuk pemutaran ayat'),
            trailing: DropdownButton<String>(
              value: activeQari,
              items: const [
                DropdownMenuItem(value: '01', child: Text('Mishary Rashid')),
                DropdownMenuItem(value: '02', child: Text('Al-Ghamidi')),
                DropdownMenuItem(value: '03', child: Text('Abdurrahman As-Sudais')),
              ],
              onChanged: (val) {
                if (val != null) ref.read(qariProvider.notifier).setQari(val);
              },
            ),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Tampilkan Tanggal Hijriah'),
            subtitle: const Text('Munculkan info kalender Islam di Beranda'),
            value: showHijri,
            onChanged: (_) => ref.read(showHijriProvider.notifier).toggle(),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Tampilkan Latin'),
            subtitle: const Text('Munculkan teks transliterasi latin untuk setiap ayat'),
            value: showLatin,
            onChanged: (_) => ref.read(showLatinProvider.notifier).toggle(),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Tampilkan Terjemahan'),
            subtitle: const Text('Munculkan teks terjemahan untuk setiap ayat'),
            value: showTranslation,
            onChanged: (_) => ref.read(showTranslationProvider.notifier).toggle(),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Reminder Waktu Sholat'),
            subtitle: const Text('Aktifkan notifikasi HP saat masuk waktu sholat'),
            value: prayerReminder,
            onChanged: (val) {
              const listWaktuSholat = {
                'Subuh': '04:22',
                'Dzuhur': '11:40',
                'Ashar': '14:58',
                'Maghrib': '17:34',
                'Isya': '18:49'
              };
              ref.read(prayerReminderProvider.notifier).toggleReminder(listWaktuSholat);
            },
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
