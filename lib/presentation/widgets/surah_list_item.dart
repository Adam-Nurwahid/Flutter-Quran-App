import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';

class SurahListItem extends StatelessWidget {
  final Surah surah;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text('${surah.nomor}'),
      ),
      title: Text(surah.namaLatin, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${surah.tempatTurun} • ${surah.jumlahAyat} ayat'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(surah.nama, style: const TextStyle(fontSize: 18)),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            onPressed: onBookmarkTap,
          ),
        ],
      ),
    );
  }
}
