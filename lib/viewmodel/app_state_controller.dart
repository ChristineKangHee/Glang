import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppStateController extends GetxController {
  Rxn<User> _user = Rxn<User>();

  User? get user => _user.value;

  void setUser(User? user) {
    _user.value = user;
  }

  void clearUser() {
    _user.value = null;
  }
}
