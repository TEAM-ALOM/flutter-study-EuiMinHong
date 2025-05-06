import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RetakeQuizScreen extends StatefulWidget {
  final String quiz;
  final String correctAnswer;
  final String docId; // Firestore 문서 ID
  final List<String> incorrectAnswers; // 오답 리스트
  const RetakeQuizScreen({
    super.key,
    required this.quiz,
    required this.correctAnswer,
    required this.docId,
    required this.incorrectAnswers,
  });

  @override
  State<RetakeQuizScreen> createState() => _RetakeQuizScreenState();
}

class _RetakeQuizScreenState extends State<RetakeQuizScreen> {
  String? _selectedAnswer;
  bool _showError = false;
  bool _isSubmitting = false;
  late List<String> _shuffledAnswers;

  @override
  void initState() {
    super.initState();
    // 정답과 오답을 합쳐서 섞기
    _shuffledAnswers = [widget.correctAnswer, ...widget.incorrectAnswers];
    _shuffledAnswers.shuffle();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
    });
    // 선택한 답이 정답이면 Firestore에서 오답 삭제
    if (_selectedAnswer == widget.correctAnswer) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wrongAnswers')
            .doc(widget.docId)
            .delete();
      }
      if (!mounted) return; // dispose된 context 방지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정답! 오답노트에서 삭제되었습니다.')),
      );
      Navigator.of(context).pop(true); // 성공적으로 풀었음을 반환
    } else {
      setState(() {
        _showError = true;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오답 다시 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.quiz,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // 정답 + 오답을 섞어서 객관식 버튼으로 표시
            for (final answer in _shuffledAnswers)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedAnswer == answer ? Colors.blueAccent : null,
                  ),
                  onPressed:
                      _isSubmitting
                          ? null
                          : () {
                            setState(() {
                              _selectedAnswer = answer;
                              _showError = false;
                            });
                          },
                  child: Text(answer),
                ),
              ),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('정답이 아닙니다.', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  _isSubmitting || _selectedAnswer == null ? null : _submit,
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}

// 사용 예시 및 전달 방법:
// RetakeQuizScreen(
//   quiz: data['quiz'],
//   correctAnswer: data['correctAnswer'],
//   docId: docId,
//   incorrectAnswers: List<String>.from(data['incorrectAnswers'] ?? []),
// )
