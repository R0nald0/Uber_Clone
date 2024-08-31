import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/core/logger/app_uber_log.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/execptions/user_exception.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final IAppUberLog _log;

  AuthRepositoryImpl(
      {
        required FirebaseAuth firebaseAuth,
        required FirebaseFirestore firestore,
        required IAppUberLog logger})
      : _auth = firebaseAuth,
        _db = firestore,
        _log = logger;

  @override
  Future<User?> verifyStateUserLogged() async { 
    final userCompleter = Completer<User?>();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        userCompleter.complete(user);
      } else {
        userCompleter.complete(null);
      }
    });

    return userCompleter.future;
  }

  @override
  Future<Usuario> getDataUserOn(String idUser) async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection(UberCloneConstants.USUARiO_DATABASE_NAME)
          .doc(idUser)
          .get();
          return  Usuario.fromFirestore(snapshot); 
    } on Exception catch (e, s) {
      _log.erro("erro ao buscas daddos do usuario", e, s);
       throw UserException(message: "erro ao buscas daddos do usuario");
    }
  }

  @override
  Future<void> logout() => _auth.signOut();
}
