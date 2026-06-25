import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
import '../providers/surah_providers.dart';
import '../widgets/surah_list_item.dart';
import '../widgets/loading_widget.dart';
import 'surah_detail_screen.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final surahAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: surahAsync.when(
        loading: () => const LoadingWidget(),
        error: (err, _) => Center(child: Text('$err')),
        data: (allSurah) {
          final bookmarked = allSurah
              .where((s) => bookmarkState.bookmarkedSurah.contains(s.nomor))
              .toList();

          if (bookmarked.isEmpty) {
            return const Center(child: Text('Belum ada surah yang dibookmark'));
          }

          return ListView.builder(
            itemCount: bookmarked.length,
            itemBuilder: (context, index) {
              final s = bookmarked[index];
              return SurahListItem(
                surah: s,
                isBookmarked: true,
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
    );
  }
}
