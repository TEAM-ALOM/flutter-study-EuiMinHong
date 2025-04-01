import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future<void> saveCorrectAnswerToFirestore({
    required String question,
    required String answer,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('quiz_info').add({
        'question': question,
        'correct_answer': answer,
      });
      print('✅ 정답 저장 완료!');
    } catch (e) {
      print('❌ 정답 저장 실패: $e');
    }
  }

  Future<void> checkDocument({required String address}) async {
    try {
      final doc = await FirebaseFirestore.instance.doc(address).get();

      if (doc.exists) {
        print("✅ testDoc 데이터: ${doc.data()}");
      } else {
        print("⚠️ testDoc 문서가 존재하지 않습니다.");
      }
    } catch (e) {
      print("❌ 문서 확인 중 오류 발생: $e");
    }
  }
}
