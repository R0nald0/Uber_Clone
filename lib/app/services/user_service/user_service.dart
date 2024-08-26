import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/app/model/Usuario.dart';

abstract class UserService {
    Future<User?> logar(String email,String password); 
     Future<User?> register(String name,String email,String password);
}