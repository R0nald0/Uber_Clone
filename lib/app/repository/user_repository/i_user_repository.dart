import 'package:firebase_auth/firebase_auth.dart';

abstract interface class IUserRepository {
  Future<User?> logar(String email, String password);
  Future<User?> register(String name, String email, String password);
}