import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
 static Future<void> signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Logged in");
  } catch (e) {
    print("Error: $e");
  }
}
}