import 'dart:async';

import 'package:uber/app/model/Usuario.dart';
import 'package:uber/core/offline_database/database_off_line.dart';
import 'package:uber/core/offline_database/sql_connection.dart';

class DatabaseImpl implements DatabaseOffLine {

    final _sqlConnection = SqlConnection();

  @override
  Future<void> delete(Usuario usuario) {
    // TODO: implement delete
    throw UnimplementedError();
  }




  @override
  Future<Usuario> getUserData() {
    // TODO: implement getUserData
    throw UnimplementedError();
  }

  @override
  Future<int> save(Usuario usuario) async {
    final data = await _sqlConnection.openConnection();

    return await data.rawInsert('INSERT INTO usuario VALUES(?,?,?,?,?)', [
      usuario.idUsuario,
      usuario.email,
      usuario.nome,
      usuario.latitude.toString(),
      usuario.longitude.toString()
    ]);
  }

  @override
  Future<Usuario> update(Usuario usuario) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
