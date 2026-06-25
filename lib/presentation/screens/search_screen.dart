import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/debouncer.dart';
import '../providers/bookmark_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/surah_list_item.dart';
import 'surah_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _debouncer = Debouncer();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredSurahProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari nama surah atau arti...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // optimasi: tunggu user berhenti ngetik 400ms sebelum filter
            _debouncer.run(() {
              ref.read(searchQueryProvider.notifier).state = value;
            });
          },
        ),
      ),
      body: results.isEmpty
          ? const Center(child: Text('Surah tidak ditemukan'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final s = results[index];
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
            ),
    );
  }
}
