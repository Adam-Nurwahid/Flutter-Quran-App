import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';


class LastRead {
  final int surahNomor;
  final String surahNama;
  final int ayatNomor;
  final DateTime timestamp;

  LastRead({
    required this.surahNomor,
    required this.surahNama,
    required this.ayatNomor,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'surahNomor': surahNomor,
        'surahNama': surahNama,
        'ayatNomor': ayatNomor,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LastRead.fromJson(Map<String, dynamic> json) => LastRead(
        surahNomor: json['surahNomor'],
        surahNama: json['surahNama'],
        ayatNomor: json['ayatNomor'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class BookmarkState {
  final Set<int> bookmarkedSurah;
  final LastRead? lastRead;

  BookmarkState({required this.bookmarkedSurah, this.lastRead});

  BookmarkState copyWith({Set<int>? bookmarkedSurah, LastRead? lastRead}) {
    return BookmarkState(
      bookmarkedSurah: bookmarkedSurah ?? this.bookmarkedSurah,
      lastRead: lastRead ?? this.lastRead,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier() : super(BookmarkState(bookmarkedSurah: {})) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkList = prefs.getStringList(AppConstants.prefBookmarks) ?? [];
    final lastReadJson = prefs.getString(AppConstants.prefLastRead);

    state = BookmarkState(
      bookmarkedSurah: bookmarkList.map(int.parse).toSet(),
      lastRead: lastReadJson != null
          ? LastRead.fromJson(json.decode(lastReadJson))
          : null,
    );
  }

  Future<void> toggleBookmark(int nomorSurah) async {
    final newSet = Set<int>.from(state.bookmarkedSurah);
    if (newSet.contains(nomorSurah)) {
      newSet.remove(nomorSurah);
    } else {
      newSet.add(nomorSurah);
    }
    state = state.copyWith(bookmarkedSurah: newSet);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      AppConstants.prefBookmarks,
      newSet.map((e) => e.toString()).toList(),
    );
  }

  bool isBookmarked(int nomorSurah) => state.bookmarkedSurah.contains(nomorSurah);

  Future<void> saveLastRead(int surahNomor, String surahNama, int ayatNomor) async {
    final lastRead = LastRead(
      surahNomor: surahNomor,
      surahNama: surahNama,
      ayatNomor: ayatNomor,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(lastRead: lastRead);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLastRead, json.encode(lastRead.toJson()));
  }
}

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier();
});
