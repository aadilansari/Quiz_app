import 'package:flutter/material.dart';
import 'package:quiz_app/login_page.dart';
import 'package:quiz_app/question.dart';

import 'quiz_page.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:  LoginPage(),
     // QuizPage(questions: questions, savedQuestionIndex: 0, name: '', )
    );
  }
}


