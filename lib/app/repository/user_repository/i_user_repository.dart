import 'package:uber/app/model/Usuario.dart';

abstract interface class IUserRepository {
  Future<Usuario> getDataUserOn(String idUser);
  Future<void> saveUserOnDatabase(String name, String idUsuario, String email,
      String password, String tipoUsuario);
}