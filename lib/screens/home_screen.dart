import 'package:arom_study_quiz/services/api_service.dart';
import 'package:arom_study_quiz/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바
      appBar: AppBar(title: Text('랜덤 퀴즈ccc')),

      // 바디
      body: Padding(
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
                                onPressed: () {
                                  if (answer == correctAnswer) {
                                    print('정답입니다!');
                                  } else {
                                    print('오답입니다!');
                                  }
                                },
                                child: Text(answer),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),

                      // 새로운 문제 버튼
                      IgnorePointer(
                        ignoring:
                            snapshot.connectionState == ConnectionState.waiting,
                        child: ElevatedButton(
                          onPressed: loadNewQuiz,
                          child: const Text('새로운 문제'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Firebase에 저장 버튼
                      IconButton(
                        icon: const Icon(Icons.save),
                        iconSize: 40,
                        onPressed: () async {
                          print("Firebase에 저장합니다.");
                          FirebaseService().saveQuizData(
                            quiz: unescape.convert(resultData['question']),
                            answer: correctAnswer,
                            isCorrect: true,
                          );
                        },
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
    );
  }
}
