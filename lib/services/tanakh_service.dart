import 'dart:convert';
import 'package:http/http.dart' as http;

const String _sefariaApi = 'https://www.sefaria.org/api';

Future<Map> getText(String reference) async {
  final res = await http.get(Uri.parse('$_sefariaApi/texts/$reference'));
  return jsonDecode(res.body);
}
