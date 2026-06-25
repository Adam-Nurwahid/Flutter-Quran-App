import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Custom exception biar pesan error yang ditampilkan ke user rapi,
/// bukan stacktrace mentah dari http/dart:io.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw ApiException('Server merespon dengan error ${response.statusCode}');
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Cek koneksi kamu.');
    } on FormatException {
      throw ApiException('Format data dari server tidak valid.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan tak terduga: $e');
    }
  }

  void close() => _client.close();
}
