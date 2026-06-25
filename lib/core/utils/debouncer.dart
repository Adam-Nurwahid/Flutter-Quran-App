import 'dart:async';

/// Optimasi: tunda eksekusi action sampai user berhenti mengetik
/// selama [delay]. Mencegah filter/list rebuild di setiap keystroke
/// saat search surah.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
