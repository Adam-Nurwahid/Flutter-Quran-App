import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerState {
  final int? playingAyatNomor;
  final bool isLoading;
  final bool isPlaying;

  AudioPlayerState({
    this.playingAyatNomor,
    this.isLoading = false,
    this.isPlaying = false,
  });

  AudioPlayerState copyWith({
    int? playingAyatNomor,
    bool? isLoading,
    bool? isPlaying,
    bool clearPlaying = false,
  }) {
    return AudioPlayerState(
      playingAyatNomor: clearPlaying ? null : (playingAyatNomor ?? this.playingAyatNomor),
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerNotifier() : super(AudioPlayerState()) {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        state = state.copyWith(isPlaying: false, clearPlaying: true);
      } else {
        state = state.copyWith(isPlaying: playerState.playing);
      }
    });
  }

  /// Play audio ayat tertentu. Kalau ayat yang sama lagi playing,
  /// tap kedua akan pause (toggle behaviour).
  Future<void> playAyat(int ayatNomor, String url) async {
    try {
      if (state.playingAyatNomor == ayatNomor && state.isPlaying) {
        await _player.pause();
        return;
      }
      state = state.copyWith(playingAyatNomor: ayatNomor, isLoading: true);
      await _player.setUrl(url);
      await _player.play();
      state = state.copyWith(isLoading: false, isPlaying: true);
    } catch (_) {
      state = AudioPlayerState();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = AudioPlayerState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});
