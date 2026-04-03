import 'dart:convert';
import 'package:http/http.dart' as http;

const String _wikiApi = 'https://en.wikipedia.org/api/rest_v1/page/summary';

const Map<String, String> _religionWikiKeys = {
  'catholic': 'Catholic_Church',
  'protestant': 'Protestantism',
  'anglican': 'Anglicanism',
  'mormon': 'The_Church_of_Jesus_Christ_of_Latter-day_Saints',
  'muslim': 'Islam',
  'orthodox': 'Eastern_Orthodox_Church',
  'adventist': 'Seventh-day_Adventist_Church',
};

Future<Map> getReligionInfo(String denomination) async {
  final key = _religionWikiKeys[denomination.toLowerCase()];
  if (key == null) return {};
  final res = await http.get(Uri.parse('$_wikiApi/$key'));
  return jsonDecode(res.body);
}
