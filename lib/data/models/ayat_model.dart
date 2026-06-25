class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final String? audioUrl;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    this.audioUrl,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    String? audio;
    final audioMap = json['audio'];
    if (audioMap is Map && audioMap.isNotEmpty) {
      // ambil qari pertama yang tersedia (default key '01' = Alafasy di equran.id)
      audio = audioMap['01']?.toString() ?? audioMap.values.first?.toString();
    }

    return Ayat(
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      audioUrl: audio,
    );
  }
}
