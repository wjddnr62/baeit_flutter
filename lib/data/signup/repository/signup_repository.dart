import 'package:baeit/data/signup/login.dart';
import 'package:baeit/data/signup/service/login_service.dart';
import 'package:baeit/data/signup/service/logout_service.dart';
import 'package:baeit/data/signup/service/signup_service.dart';
import 'package:baeit/data/signup/signup.dart';

class SignUpRepository {
  static Future<dynamic> signUp(SignUp signUp) =>
      SignupService(signUp: signUp).start();

  static Future<dynamic> login(Login login) =>
      LoginService(login: login).start();

  static Future<dynamic> logout() => LogoutService().start();
}
