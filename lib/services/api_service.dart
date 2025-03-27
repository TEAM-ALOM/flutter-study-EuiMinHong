import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchQuiz() async {
  final response = await http.get(
    Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load quiz');
  }
}
