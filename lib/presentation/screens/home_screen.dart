import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
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
              // +1 item kalau ada lastRead card di paling atas
              itemCount: surahList.length + (lastRead != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (lastRead != null && index == 0) {
                  return _LastReadCard(lastRead: lastRead);
                }
                final realIndex = lastRead != null ? index - 1 : index;
                final s = surahList[realIndex];

                return SurahListItem(
                  surah: s,
                  isBookmarked: ref.read(bookmarkProvider.notifier).isBookmarked(s.nomor),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(nomorSurah: s.nomor),
                    ),
                  ),
                  onBookmarkTap: () =>
                      ref.read(bookmarkProvider.notifier).toggleBookmark(s.nomor),
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
