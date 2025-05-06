import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  // 구글 로그인 실행
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // 인증 정보 획득
  final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

  // Firebase 자격 증명 생성
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Firebase에 로그인
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
