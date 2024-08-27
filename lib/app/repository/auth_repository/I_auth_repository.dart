
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/app/model/Usuario.dart';

abstract interface  class IAuthRepository {
  Future<User?> verifyStateUserLogged();
  Future<Usuario> getDataUserOn(String idUser);
  void logout();
}
