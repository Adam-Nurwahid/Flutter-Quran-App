class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final String teksInggris;
  final Map<String, String> audioMap;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.teksInggris,
    required this.audioMap,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    final rawAudio = json['audio'];
    Map<String, String> audios = {};
    if (rawAudio is Map) {
      rawAudio.forEach((key, value) {
        audios[key.toString()] = value.toString();
      });
    }

    return Ayat(
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      teksInggris: json['teksInggris'] ?? '[English Translation Placeholder]',
      audioMap: audios,
    );
  }
}