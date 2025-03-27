```markdown
# Flutter 랜덤 퀴즈 앱

## 1. 프로젝트 개요

Flutter를 사용하여 랜덤 퀴즈를 제공하는 앱입니다. Open Trivia API에서 문제를 가져와 사용자가 퀴즈를 풀 수 있도록 구현되었습니다.

**사용 기술**
*   Flutter
*   Dart
*   FutureBuilder
*   API 호출 (HTTP 요청)

<img src="https://github.com/user-attachments/assets/494eff4f-6c67-49de-bb39-a8dbc9d1fde8" width="400">

<img width="537" alt="결과 화면" src="https://github.com/user-attachments/assets/9b6e3903-b9a2-48dc-b6b2-7a8cbfabb2fa" />

## 2. 주요 기능

*   **랜덤 퀴즈 제공:** Open Trivia API에서 문제를 가져와 랜덤 퀴즈 제공
*   **객관식 답변 선택:** 정답과 오답을 무작위로 섞어 버튼으로 제공
*   **새로운 문제 불러오기:** ‘새로운 문제’ 버튼을 누르면 새로운 퀴즈 로드
*   **비동기 API 통신:** FutureBuilder를 활용하여 데이터를 비동기적으로 가져오기

## 3. 실행 방법

### 3-1 Flutter 설치 확인

Flutter가 설치되어 있는지 확인합니다.

```bash
flutter --version
```

### 3-2 저장소 클론

GitHub에서 프로젝트를 클론합니다.

```bash
git clone https://github.com/TEAM-ALOM/flutter-study-EuiMin_Hong.git
cd flutter-study-EuiMin_Hong
```

### 3-3 패키지 설치

필요한 패키지를 설치합니다.

```bash
flutter pub get
```

### 3-4 앱 실행

아래 명령어를 실행하여 앱을 실행합니다.

```bash
flutter run
```

## 4. HomeScreen 설명

### 4-1 home\_screen.dart

랜덤 퀴즈를 가져와 화면에 표시하고, 사용자가 정답을 선택할 수 있도록 구성되어 있습니다.

```dart
FutureBuilder(
  future: fetchQuiz(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final correctAnswer = snapshot.data!['results'][0]['correct_answer'];
      final incorrectAnswers = snapshot.data!['results'][0]['incorrect_answers'];
      final answers = [correctAnswer, ...incorrectAnswers]..shuffle();

      return Column(
        children: [
          Text(
            "${snapshot.data!['results'][0]['question']}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          for (var answer in answers)
            ElevatedButton(
              onPressed: () {
                if (answer == correctAnswer) {
                  print('정답입니다!');
                } else {
                  print('오답입니다!');
                }
              },
              child: Text(answer),
            ),
          ElevatedButton(
            onPressed: loadNewQuiz,
            child: const Text('새로운 문제'),
          ),
        ],
      );
    } else if (snapshot.hasError) {
      return Text('${snapshot.error}');
    } else {
      return const CircularProgressIndicator();
    }
  },
)
```

### 4-2 API 호출 (api\_service.dart)

퀴즈 데이터를 가져오는 API 서비스 파일입니다.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchQuiz() async {
  final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('퀴즈를 불러오지 못했습니다.');
  }
}
```

## 5. 문제점

새로고침을 하거나 핫리로드를 할 때 API 가져오는 속도가 느려서 오류가 발생합니다.
```