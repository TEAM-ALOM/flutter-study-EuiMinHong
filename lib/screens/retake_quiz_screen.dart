import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RetakeQuizScreen extends StatefulWidget {
  final String quiz;
  final String correctAnswer;
  final String docId; // Firestore 문서 ID
  const RetakeQuizScreen({
    super.key,
    required this.quiz,
    required this.correctAnswer,
    required this.docId,
  });

  @override
  State<RetakeQuizScreen> createState() => _RetakeQuizScreenState();
}

class _RetakeQuizScreenState extends State<RetakeQuizScreen> {
  final _controller = TextEditingController();
  bool _showError = false;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; });
    if (_controller.text.trim() == widget.correctAnswer) {
      // Firestore에서 오답 삭제
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wrongAnswers')
            .doc(widget.docId)
            .delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정답! 오답노트에서 삭제되었습니다.')),
        );
        Navigator.of(context).pop(true); // 성공적으로 풀었음을 반환
      }
    } else {
      setState(() { _showError = true; _isSubmitting = false; });
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
            Text(widget.quiz, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: '정답을 입력하세요'),
            ),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('정답이 아닙니다.', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}
