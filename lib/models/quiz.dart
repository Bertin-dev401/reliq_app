/// Quiz and knowledge testing data models
/// 
/// This file contains all models related to Bible quizzes,
/// questions, and user quiz history

/// Model representing a quiz
class Quiz {
  final String id;
  final String title;
  final String description;
  final String difficulty; // Easy, Medium, Hard
  final int questionsCount;
  final int duration; // Duration in minutes
  final String category;
  final String? coverImage;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questionsCount,
    required this.duration,
    required this.category,
    this.coverImage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create Quiz from JSON
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      questionsCount: json['questions_count'] ?? 0,
      duration: json['duration'] ?? 10,
      category: json['category'] ?? '',
      coverImage: json['cover_image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert Quiz to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'questions_count': questionsCount,
      'duration': duration,
      'category': category,
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get difficulty color
  /// Returns color code based on difficulty level
  int getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 0xFF4CAF50; // Green
      case 'medium':
        return 0xFFFF9800; // Orange
      case 'hard':
        return 0xFFE53E3E; // Red
      default:
        return 0xFF6C63FF; // Purple
    }
  }
}

/// Model representing a quiz question
class QuizQuestion {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct answer in options
  final String explanation;
  final String? verseReference; // Reference to Bible verse

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.verseReference,
  });

  /// Create QuizQuestion from JSON
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      question: json['question'] ?? '',
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : [],
      correctAnswer: json['correct_answer'] ?? 0,
      explanation: json['explanation'] ?? '',
      verseReference: json['verse_reference'],
    );
  }

  /// Convert QuizQuestion to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'verse_reference': verseReference,
    };
  }

  /// Check if given answer is correct
  bool isCorrect(int answerIndex) {
    return answerIndex == correctAnswer;
  }

  /// Get the correct answer text
  String get correctAnswerText {
    if (correctAnswer >= 0 && correctAnswer < options.length) {
      return options[correctAnswer];
    }
    return '';
  }
}

/// Model representing a completed quiz attempt
class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int timeSpentSeconds;
  final List<QuizAnswer> answers;
  final DateTime completedAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.answers,
    required this.completedAt,
  });

  /// Create QuizAttempt from JSON
  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      userId: json['user_id'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      timeSpentSeconds: json['time_spent_seconds'] ?? 0,
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((answer) => QuizAnswer.fromJson(answer))
              .toList()
          : [],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
    );
  }

  /// Convert QuizAttempt to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
      'time_spent_seconds': timeSpentSeconds,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// Calculate percentage score
  double get percentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  /// Get grade based on percentage
  String get grade {
    final percent = percentage;
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  /// Check if passed (60% or higher)
  bool get passed => percentage >= 60;
}

/// Model representing a single answer in a quiz attempt
class QuizAnswer {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpentSeconds;

  QuizAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpentSeconds,
  });

  /// Create QuizAnswer from JSON
  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      questionId: json['question_id'] ?? '',
      selectedAnswer: json['selected_answer'] ?? 0,
      isCorrect: json['is_correct'] ?? false,
      timeSpentSeconds: json['time_spent_seconds'] ?? 0,
    );
  }

  /// Convert QuizAnswer to JSON
  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'is_correct': isCorrect,
      'time_spent_seconds': timeSpentSeconds,
    };
  }
}
