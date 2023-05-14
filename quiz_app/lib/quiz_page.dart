// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiz_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, Object>> questions;
  final int savedQuestionIndex;
  final String name;

  const QuizPage(
      {super.key,
      required this.name,
      required this.questions,
      required this.savedQuestionIndex});
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0;
  int correctAnswers = 0;
  int countdown = 20;
  String feedback = '';
  bool isResultPrinted = false;
  Timer? timer;
  AudioCache audioCache = AudioCache();

  Future<void> _loadSoundEffects() async {
    await audioCache.load('correct_answer.mp3');
    await audioCache.load('incorrect_answer.mp3');
  }

  @override
  void initState() {
    _loadSoundEffects();
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          if (questionIndex < widget.questions.length - 1) {
            nextQuestion();
          }
        }
      });
    });
  }

  void _signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
       timer?.cancel();
      await googleSignIn.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
// ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  void nextQuestion() {
    if (questionIndex < widget.questions.length - 1) {
      questionIndex++;
      //feedback = '';
      countdown = 20;
      startTimer();
    } else {
      timer?.cancel();
      if (!isResultPrinted) {
        setState(() {
          isResultPrinted = true;
        });
        showResultDialog();
      }
    }
  }

  void checkAnswer(String selectedChoice) {
    String correctAnswer =
        widget.questions[questionIndex]['correctAnswer'] as String;
    String? explanation =
        widget.questions[questionIndex]['explanation'] as String?;

    setState(() {
      if (selectedChoice == correctAnswer) {
        correctAnswers++;
        feedback = 'Correct! $explanation';
        audioCache.play('correct_answer.mp3');
      } else {
        feedback =
            'Incorrect! The correct answer is $correctAnswer. $explanation';
        audioCache.play('incorrect_answer.mp3');
      }
    });

    nextQuestion();
  }

  void showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Result'),
          content: Text(
              'You answered $correctAnswers correct out of ${widget.questions.length} questions.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalQuestions = widget.questions.length;
    int answeredQuestions = questionIndex + 1;
    int remainingQuestions = totalQuestions - answeredQuestions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Quiz'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.logout_outlined),
          backgroundColor: Colors.black,
          onPressed: () => _signOut()),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome ${widget.name}",
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 11, 65, 12)),
              ),
              Text(
                'Question ${questionIndex + 1}',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.questions[questionIndex]['question'] as String,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              const SizedBox(height: 20.0),
              ...((widget.questions[questionIndex]['choices'] as List<String>)
                  .map((choice) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => checkAnswer(choice),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Color.fromARGB(255, 3, 3, 67),
                        ),
                      ),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(choice),
                      ),
                    ),
                  ),
                );
              })).toList(),
              const SizedBox(height: 20.0),
              Text(feedback),
              const SizedBox(height: 20.0),
              LinearProgressIndicator(
                value: answeredQuestions / totalQuestions,
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Progress: $answeredQuestions/$totalQuestions',
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 11, 65, 12)),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Score: $correctAnswers/${widget.questions.length}',
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 11, 65, 12)),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Center(
                child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: Text(
                      countdown.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: const Text('Next Question'),
                onPressed: () {
                  setState(() {
                    nextQuestion();
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Start New Quiz'),
                onPressed: () {
                  setState(() {
                    questionIndex = 0;
                    correctAnswers = 0;
                    feedback = '';
                    countdown = 20;
                    startTimer();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
