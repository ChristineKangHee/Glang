import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart';  // adminEmails 가져오기
const List<String> adminEmails = [
  'christinekangh522@gmail.com',
  'manager@yourapp.com',
  'staff@yourapp.com',
];

Future<bool> isAdminUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  return adminEmails.contains(user.email);
}
