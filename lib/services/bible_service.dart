import 'dart:convert';
import 'package:http/http.dart' as http;

const String _bibleApi = 'https://bible-api.com';

// Fix: added 8 second timeout for slow 3G connections common in Rwanda.
// Without a timeout, this call can hang for 30+ seconds on poor networks,
// making the app appear frozen. 8s is long enough for slow connections
// but short enough to fail fast and show an error state.
Future<Map> getVerse(String reference) async {
  final res = await http
      .get(Uri.parse('$_bibleApi/$reference'))
      .timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Request timed out. Check your connection.'),
      );

  if (res.statusCode != 200) {
    throw Exception('Failed to load verse (${res.statusCode})');
  }

  return jsonDecode(res.body);
}
