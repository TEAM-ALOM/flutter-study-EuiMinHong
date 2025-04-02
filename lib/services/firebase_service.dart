import 'package:cloud_firestore/cloud_firestore.dart';

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
}
