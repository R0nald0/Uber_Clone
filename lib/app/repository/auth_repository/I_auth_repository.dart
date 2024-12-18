
import 'package:firebase_auth/firebase_auth.dart';

abstract interface  class IAuthRepository {
  Future<User?> verifyStateUserLogged();
  Future<User?> logar(String email, String password);
  Future<User?> register(String name, String email, String password,String tipoUsuario);      
  String? getIdCurrenteUserUser();
  void logout();
}
