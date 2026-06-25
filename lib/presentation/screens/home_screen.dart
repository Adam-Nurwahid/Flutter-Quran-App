import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/surah_providers.dart';
import '../widgets/surah_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;
import 'surah_detail_screen.dart';
import 'search_screen.dart';
import 'bookmark_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  final _pages = const [
    _SurahListTab(),
    BookmarkScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Surah'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}

// Letakkan widget pembantu ini di bagian bawah file home_screen.dart

class _PrayerAndHijriHeader extends ConsumerWidget {
  const _PrayerAndHijriHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHijri = ref.watch(showHijriProvider);

    // Mock Data Waktu Sholat (Bisa kamu integrasikan dengan http fetch dari api.aladhan.com)
    final listWaktuSholat = {
      'Subuh': '04:22',
      'Dzuhur': '11:40',
      'Ashar': '14:58',
      'Maghrib': '17:34',
      'Isya': '18:49'
    };

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (showHijri) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kalender Hijriah',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const Text('5 Muharram 1448 H'), // Mock Hijri date calculation
                ],
              ),
              const Divider(height: 20),
            ],
            Text(
              'Jadwal Waktu Sholat',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: listWaktuSholat.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(e.value, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SurahListTab extends ConsumerWidget {
  const _SurahListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
    final bookmarkState = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Al-Qur'an"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // optimasi: invalidate provider lalu await future baru,
          // bukan reload dari awal/rebuild seluruh widget tree
          ref.invalidate(surahListProvider);
          await ref.read(surahListProvider.future);
        },
        child: surahAsync.when(
          loading: () => const LoadingWidget(),
          error: (err, _) => custom.ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(surahListProvider),
          ),
          data: (surahList) {
            final lastRead = bookmarkState.lastRead;

            return ListView.builder(
              itemCount: surahList.length + (lastRead != null ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _PrayerAndHijriHeader(); // Tampilkan di baris pertama
                }

                if (lastRead != null && index == 1) {
                  return _LastReadCard(lastRead: lastRead); //
                }

                final realIndex = lastRead != null ? index - 2 : index - 1;
                final s = surahList[realIndex]; //

                return SurahListItem(
                  surah: s, //
                  isBookmarked: ref.read(bookmarkProvider.notifier).isBookmarked(s.nomor), //
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(nomorSurah: s.nomor), //
                    ),
                  ),
                  onBookmarkTap: () =>
                      ref.read(bookmarkProvider.notifier).toggleBookmark(s.nomor), //
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  final LastRead lastRead;
  const _LastReadCard({required this.lastRead});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.bookmark_added),
        title: const Text('Terakhir dibaca'),
        subtitle: Text('${lastRead.surahNama} - Ayat ${lastRead.ayatNomor}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahDetailScreen(
              nomorSurah: lastRead.surahNomor,
              initialAyatNomor: lastRead.ayatNomor,
            ),
          ),
        ),
      ),
    );
  }
}
