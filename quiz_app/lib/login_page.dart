import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiz_app/question.dart';
import 'package:quiz_app/quiz_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
   String userName='';
   String profilePicture='';

  Future<void> _login(BuildContext context) async {
    try {
      await _googleSignIn.signIn().then((value) {
        setState(() {
          userName = value!.displayName!;
         profilePicture = value.photoUrl!;
        });
         
      });
      await _cacheUserLoginStatus(true);
      int progress = await _getSavedQuizProgress();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => QuizPage(
                  questions: questions,
                  savedQuestionIndex: progress, name: userName,

                )),
      );
    } catch (error) {
      print('Error occurred during Google login: $error');
    }
  }

  Future<void> _cacheUserLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  

  Future<bool> _getUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<List<String>> _getLeaderboard() async {
    // Retrieve leaderboard data from an API or local storage
    // Return a list of names or scores
    return Future.delayed(const Duration(seconds: 2), () {
      return ['John', 'Jane', 'Mark', 'Emily'];
    });
  }

  Future<void> _saveQuizProgress(int questionIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('questionIndex', questionIndex);
  }

  Future<int> _getSavedQuizProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('questionIndex') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  void _checkUserLoginStatus() async {
    bool isLoggedIn = await _getUserLoginStatus();
    int progress = await _getSavedQuizProgress();
    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                QuizPage(questions: questions, savedQuestionIndex: progress, name: userName,)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Play Quiz", style: TextStyle(
                fontSize: 35,fontWeight: FontWeight.w500
              ),),
            ),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () => _login(context),
              child: Container(
                color: Colors.green,
                width: 200,
                height: 40,
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      
                      'assets/glogo.png', height: 20, width: 20,),
                      SizedBox(width: 8,),
                    const Text(' SignIn with Google', style: TextStyle( color: Colors.white,
                      fontWeight: FontWeight.normal, fontSize: 15
                    ),),
                  ],
                ),
              ),
            ),
           
            const SizedBox(height: 20),
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: _getLeaderboard(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading leaderboard');
                } else {
                  List<String>? leaderboard = snapshot.data;
                  if (leaderboard != null) {
                    return Column(
                      children: leaderboard.map((name) => Text(name, style: TextStyle(fontSize: 18),)).toList(),
                    );
                  } else {
                    return const Text('No leaderboard data');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
