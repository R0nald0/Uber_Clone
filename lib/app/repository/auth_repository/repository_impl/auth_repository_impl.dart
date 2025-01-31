import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/core/exceptions/user_exception.dart';
import 'package:uber/core/local_storage/local_storage.dart';
import 'package:uber/core/logger/app_uber_log.dart';
import 'package:uber/core/offline_database/database_off_line.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final IAppUberLog _log;
  final LocalStorage _localStoreage;
  final DatabaseOffLine _database;

  AuthRepositoryImpl(
      {required DatabaseOffLine database,
      required LocalStorage localStoreage,
      required IAppUberLog logger})
      : _database = database,
        _localStoreage = localStoreage,
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

    return  await userCompleter.future;
  }

  @override
  Future<User?> logar(String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } on FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'user-disabled':
          _throwErrorState('Email ja em uso,', e, s);
        case 'wrong-password':
          _throwErrorState('Senha inválida,por favor,tente novamente', e, s);
        case 'invalid-email':
          _throwErrorState(
              'Email Inválido,por favor,insira um email válido', e, s);
        case 'user-not-found':
          _throwErrorState('Usuario não encontrado...', e, s);
        case 'invalid-credential:':
          _throwErrorState(
              'email ou senha inválido,verifique susa credenciais', e, s);
        case 'too-many-requests':
          _throwErrorState(
              'Muitas tentativas,aguarde um momento e tente novamente', e, s);
        case 'network-request-failed':
          _throwErrorState(
              'Falha,ao conectear com o serviço,verifique sua conexão', e, s);
        default:
          _throwErrorState(
              "Erro desconhecido entre em contato com o suporte", e, s);
      }
    }
    return null;
  }

  @override
  Future<User?> register(
      String name, String email, String password, String tipoUsuario) async {
    try {
      final userCredencial = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredencial.user != null) {
        //  Usuario(email: email,nome: name,tipoUsuario: tipoUsuario,idUsuario: )
        return userCredencial.user;
      }
      throw UserException(message: "Erro ao salvar dados do usuario");
    } on FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'email-already-in-use':
          _throwErrorState('Email ja em uso,', e, s);
        case 'invalid-email':
          _throwErrorState('Email Inválido,', e, s);
        case 'weak-password':
          _throwErrorState(
              'Senha fraca, a senha deve conter no mínimo 5 caracteres', e, s);
        case 'too-many-requests':
          _throwErrorState(
              'Muitas tentativas,aguarde um momento e tente novamente', e, s);
        case 'network-request-failed':
          _throwErrorState(
              'Falha,ao conectear com o serviço,verifique sua conexão', e, s);
        default:
          _throwErrorState(
              "Erro desconhecido entre em contato com o suporte", e, s);
      }
    }
    return null;
  }

  @override
  String? getIdCurrenteUserUser() => _auth.currentUser!.uid;

  @override
  Future<void> logout() => _auth.signOut();
  
  void _throwErrorState(String message, dynamic e, StackTrace s) {
    _log.erro(message, e, s);
    _localStoreage.clear();
    throw UserException(message: message);
  }
}
