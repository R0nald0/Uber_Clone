

import 'package:sqflite/sqflite.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/core/exceptions/addres_exception.dart';
import 'package:uber/core/logger/app_uber_log.dart';
import 'package:uber/core/offline_database/database_off_line.dart';

class AddressRepositoryImpl {
  final DatabaseOffLine _database;
  final IAppUberLog _log;


  AddressRepositoryImpl(
      {required DatabaseOffLine database, required IAppUberLog log})
      : _database = database,
        _log = log;

  Future<List<Address>> getAddrss()async{
      try {
        final result  = await _database.getUserData('address');
        final addres =result.map((element) => Address.fromMap(element)).toList(); 
        return  addres;
      }on DatabaseException catch (e,s) {
        const message =' erro ao buscar dados no banco';
          
        _log.erro(message,e,s);
        throw AddresException(message: message);
      }
  }
  
  Future<int> saveAddres(Address address) async {
    try {
      const query = 'INSERT INTO Address VALUES(?,?,?,?,?,?,?,?,?,?)';
      final arguments = <Object?>[
          address.id,
          address.nomeDestino,
          address.cep,
          address.favorite,
          address.cidade,
          address.rua,
          address.numero,
          address.bairro,
          address.latitude,
          address.longitude,
      ];
      return await _database.save(query, arguments);
    } on DatabaseException catch (e, s) {
       const message = 'erro ao salvar dados do Endereço';
      _log.erro(message, e, s);
       throw AddresException(message: message);
    }
  }
}
