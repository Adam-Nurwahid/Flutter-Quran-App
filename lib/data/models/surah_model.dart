import 'ayat_model.dart';

class Surah {
  final int nomor;
  final String nama; // teks arab
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final String? audioFullUrl;
  final List<Ayat> ayatList;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    this.audioFullUrl,
    this.ayatList = const [],
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    String? audioFull;
    final audioMap = json['audioFull'];
    if (audioMap is Map && audioMap.isNotEmpty) {
      audioFull = audioMap['01']?.toString() ?? audioMap.values.first?.toString();
    }

    return Surah(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      audioFullUrl: audioFull,
      ayatList: json['ayat'] != null
          ? (json['ayat'] as List)
              .map((e) => Ayat.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Dipakai untuk simpan ke cache lokal (tanpa ayat detail, biar ringan)
  Map<String, dynamic> toJson() => {
        'nomor': nomor,
        'nama': nama,
        'namaLatin': namaLatin,
        'jumlahAyat': jumlahAyat,
        'tempatTurun': tempatTurun,
        'arti': arti,
        'deskripsi': deskripsi,
      };
}
