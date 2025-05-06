import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'retake_quiz_screen.dart';

class WrongNoteScreen extends StatelessWidget {
  const WrongNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다'));
    }
    final wrongAnswersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wrongAnswers')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('오답 노트')),
      body: StreamBuilder<QuerySnapshot>(
        stream: wrongAnswersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('오답이 없습니다!'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(data['quiz'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('정답: ${data['correctAnswer'] ?? ''}'),
                      Text('내 답: ${data['selectedAnswer'] ?? ''}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    child: const Text('다시 풀기'),
                    onPressed: () async {
                      // Firestore에서 문제의 오답 리스트도 함께 전달
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RetakeQuizScreen(
                                quiz: data['quiz'] ?? '',
                                correctAnswer: data['correctAnswer'] ?? '',
                                docId: docId,
                                incorrectAnswers: List<String>.from(
                                  data['incorrectAnswers'] ?? [],
                                ),
                              ),
                        ),
                      );
                      // 맞으면 오답에서 삭제 안내
                      if (!context.mounted) return;
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('오답에서 삭제되었습니다!')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
