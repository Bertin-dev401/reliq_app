import 'dart:convert';
import 'package:http/http.dart' as http;

const String _quranApi = 'https://api.alquran.cloud/v1';

Future<Map> getSurah(int surahNumber) async {
  final res = await http.get(Uri.parse('$_quranApi/surah/$surahNumber/en.asad'));
  return jsonDecode(res.body);
}

Future<Map> getAyah(String reference) async {
  final res = await http.get(Uri.parse('$_quranApi/ayah/$reference/en.asad'));
  return jsonDecode(res.body);
}
