import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore에 데이터 저장
  Future<void> saveQuizData({
    required String quiz,
    required String answer,
    required bool isCorrect,
  }) async {
    try {
      await _firestore.collection('quiz').add({
        'quiz': quiz,
        'answer': answer,
        'isCorrect': isCorrect,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("데이터 저장 성공");
    } catch (e) {
      print("데이터 저장 실패: $e");
    }
  }

  // Firestore에 오답 저장
  Future<void> saveWrongAnswer({
    required String quiz,
    required String correctAnswer,
    required String selectedAnswer,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 필요');
      await _firestore.collection('users')
        .doc(user.uid)
        .collection('wrongAnswers')
        .add({
          'quiz': quiz,
          'correctAnswer': correctAnswer,
          'selectedAnswer': selectedAnswer,
          'createdAt': FieldValue.serverTimestamp(),
        });
      print("오답 저장 성공");
    } catch (e) {
      print("오답 저장 실패: $e");
    }
  }
}
