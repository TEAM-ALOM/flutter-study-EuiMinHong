import 'package:flutter/material.dart';
import 'package:arom_study1_quiz/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> futureQuiz;

  //초기화
  @override
  void initState() {
    super.initState();
    futureQuiz = fetchQuiz();
  }

  //새로운 문제
  void loadNewQuiz() {
    //setState()를 호출하면 화면이 다시 그려짐
    setState(() {
      futureQuiz = fetchQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //앱바
      appBar: AppBar(title: Text('랜덤 퀴즈')),

      //바디
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //퀴즈 출력
            FutureBuilder(
              future: fetchQuiz(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // 변수 선언
                  final correctAnswer =
                      snapshot.data!['results'][0]['correct_answer'];
                  final incorrectAnswers =
                      snapshot.data!['results'][0]['incorrect_answers'];
                  //정답이랑 오답이랑 합친 List
                  final answers = [
                    correctAnswer, //얘는 정답이어서 리스트가 아닌 문자열
                    ...incorrectAnswers, //Spread Operator
                  ];
                  answers.shuffle(); //섞기

                  return Column(
                    children: [
                      //질문 출력
                      Text(
                        "${snapshot.data!['results'][0]['question']}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),

                      //답안 출력
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

                      //새로운 문제 버튼
                      ElevatedButton(
                        onPressed: loadNewQuiz,
                        child: const Text('새로운 문제'),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('$snapshot.error');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// {
//   "response_code": 0,
//   "results": [
//     {
//       "type": "multiple",
//       "difficulty": "easy",
//       "category": "Science &amp; Nature",
//       "question": "How many planets make up our Solar System?",
//       "correct_answer": "8",
//       "incorrect_answers": [
//         "7",
//         "9",
//         "6"
//       ]
//     }
//   ]
// }
