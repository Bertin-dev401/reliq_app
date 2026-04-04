import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_provider.dart';

class DailyVerseScreen extends StatelessWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<BibleProvider>(
            builder: (context, bible, _) {
              return Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    foregroundColor: Colors.white,
                    actions: [
                      IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                    ],
                  ),
                  Expanded(
                    child: bible.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : bible.dailyVerse == null
                            ? const Center(
                                child: Text('Could not load verse.',
                                    style: TextStyle(color: Colors.white70)),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Verse of the Day',
                                      style: TextStyle(color: Colors.white70, fontSize: 16),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      '"${bible.dailyVerse!.verse.text}"',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        height: 1.7,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      bible.dailyVerse!.verse.reference,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
