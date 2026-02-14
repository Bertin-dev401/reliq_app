import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  const QuizDetailScreen({super.key});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;

  final questions = [
    {'question': 'Who built the ark?', 'answers': ['Noah', 'Moses', 'Abraham', 'David'], 'correct': 0},
    {'question': 'How many days did it rain?', 'answers': ['7', '14', '40', '100'], 'correct': 2},
  ];

  void nextQuestion() {
    if (selectedAnswer == questions[currentQuestion]['correct']) {
      score++;
    }
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Your score: $score/${questions.length}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestion + 1}/${questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (currentQuestion + 1) / questions.length),
            const SizedBox(height: 32),
            Text(q['question'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ...List.generate(
              (q['answers'] as List).length,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => selectedAnswer = index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAnswer == index ? const Color(0xFF6C63FF) : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedAnswer == index ? const Color(0xFF6C63FF).withOpacity(0.1) : null,
                    ),
                    child: Text((q['answers'] as List)[index], style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? nextQuestion : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}