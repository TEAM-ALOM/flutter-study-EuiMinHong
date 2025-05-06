import 'package:arom_study_quiz/services/api_service.dart';
import 'package:arom_study_quiz/services/firebase_service.dart';
import 'package:arom_study_quiz/screens/login_screen.dart';
import 'package:arom_study_quiz/screens/wrong_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> futureQuiz;

  // 초기화
  @override
  void initState() {
    super.initState();
    futureQuiz = fetchQuiz();
  }

  // 새로운 문제
  void loadNewQuiz() {
    setState(() {
      futureQuiz = fetchQuiz();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // 기존 홈 퀴즈 화면
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 퀴즈 출력
            FutureBuilder(
              future: futureQuiz,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // 변수 선언
                  final resultData =
                      snapshot.data!['results'][0]; //사용하기 쉽게 변수에 저장

                  HtmlUnescape unescape = HtmlUnescape();
                  final correctAnswer = unescape.convert(
                    resultData['correct_answer'],
                  );
                  final incorrectAnswers =
                      (resultData['incorrect_answers'] as List)
                          .map((answer) => unescape.convert(answer))
                          .toList();
                  // 정답이랑 오답이랑 합친 List
                  final answers = [
                    correctAnswer, // 얘는 정답이어서 리스트가 아닌 문자열
                    ...incorrectAnswers, // Spread Operator
                  ];
                  answers.shuffle(); // 섞기

                  return Column(
                    children: [
                      // 질문 출력
                      Text(
                        unescape.convert(resultData['question']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 답안 출력
                      for (var answer in answers)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (answer == correctAnswer) {
                                    print('정답입니다!');
                                    FirebaseService().saveQuizData(
                                      quiz: unescape.convert(
                                        resultData['question'],
                                      ),
                                      answer: correctAnswer,
                                      isCorrect: true,
                                    );
                                  } else {
                                    print('오답입니다!');
                                    FirebaseService().saveQuizData(
                                      quiz: unescape.convert(
                                        resultData['question'],
                                      ),
                                      answer: answer,
                                      isCorrect: false,
                                    );
                                    // 오답만 Firestore에 저장
                                    await FirebaseService().saveWrongAnswer(
                                      quiz: unescape.convert(
                                        resultData['question'],
                                      ),
                                      correctAnswer: correctAnswer,
                                      selectedAnswer: answer,
                                      incorrectAnswers:
                                          (resultData['incorrect_answers']
                                                  as List)
                                              .map((a) => unescape.convert(a))
                                              .toList(),
                                      category: resultData['category'] ?? '',
                                      difficulty:
                                          resultData['difficulty'] ?? '',
                                      type: resultData['type'],
                                    );
                                  }
                                  loadNewQuiz();
                                },
                                child: Text(answer),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // 새로운 문제 버튼
                      ElevatedButton(
                        onPressed: loadNewQuiz,
                        child: const Text('다음 문제'),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
      // 오답노트 화면
      const WrongNoteScreen(),
    ];
    return Scaffold(
      // 앱바
      appBar: AppBar(
        title: Text('랜덤 퀴즈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // 바디
      body: screens[_selectedIndex],

      // 바텀 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '퀴즈'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: '오답노트'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
