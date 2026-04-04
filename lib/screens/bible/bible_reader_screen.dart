import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_provider.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});
  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  late String _book;
  int _chapter = 1;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _book = args?['book'] ?? 'Genesis';
    _loadChapter();
  }

  void _loadChapter() {
    // Formats the reference for bible-api.com: "Genesis+1", "John+3" etc.
    final ref = '${_book.replaceAll(' ', '+')}+$_chapter';
    Provider.of<BibleProvider>(context, listen: false).loadChapter(ref);
  }

  void _changeChapter(int delta) {
    final next = _chapter + delta;
    if (next < 1) return;
    setState(() => _chapter = next);
    _loadChapter();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_book $_chapter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bible, _) {
          if (bible.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bible.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(bible.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadChapter, child: const Text('Retry')),
                ],
              ),
            );
          }
          if (bible.currentChapter.isEmpty) {
            return const Center(child: Text('No verses found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: bible.currentChapter.length,
            itemBuilder: (context, i) {
              final v = bible.currentChapter[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: '${v.verse} ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13),
                      ),
                      TextSpan(text: v.text),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Chapter navigation bar at the bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _chapter > 1 ? () => _changeChapter(-1) : null,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            Text(
              'Chapter $_chapter',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            IconButton(
              onPressed: () => _changeChapter(1),
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
