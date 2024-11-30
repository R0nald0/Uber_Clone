import 'package:uber/app/model/Usuario.dart';

abstract class DatabaseOffLine {

  Future<int> save(Usuario usuario);
  Future<Usuario> update(Usuario usuario);
  Future<Usuario> getUserData();
  Future<void> delete(Usuario usuario);

}