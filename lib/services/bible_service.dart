import 'dart:convert';
import 'package:http/http.dart' as http;

const String _bibleApi = 'https://bible-api.com';

Future<Map> getVerse(String reference) async {
  final res = await http.get(Uri.parse('$_bibleApi/$reference'));
  return jsonDecode(res.body);
}
