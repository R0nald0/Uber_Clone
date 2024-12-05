import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';

import 'package:uber/core/execptions/user_exception.dart';
import 'package:uber/core/logger/app_uber_log.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirebaseAuth _auth;
  final IAppUberLog _log;

  UserRepositoryImpl({required FirebaseAuth auth, required IAppUberLog log})
      : _auth = auth,
        _log = log;

  @override
  Future<User?> logar(String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } on FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'user-disabled':
          throwErrorState('Email ja em uso,', e, s);
        case 'wrong-password':
          throwErrorState('Senha inválida,por favor,tente novamente', e, s);
        case 'invalid-email':
          throwErrorState('Email Inválido,por favor,insira um email válido', e, s);
        case 'user-not-found':
          throwErrorState('Usuario não encontrado...', e, s);
        case 'invalid-credential:':
          throwErrorState(
              'email ou senha inválido,verifique susa credenciais', e, s);
        case 'too-many-requests':
          throwErrorState(
              'Muitas tentativas,aguarde um momento e tente novamente', e, s);
        case 'network-request-failed':
          throwErrorState(
              'Falha,ao conectear com o serviço,verifique sua conexão', e, s);
       default: throwErrorState("Erro desconhecido entre em contato com o suporte", e, s);
      }
    } 

  }

  @override
  Future<User?> register(String name, String email, String password) async {
    try {
      final userCredencial = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredencial.user;
    } on FirebaseAuthException catch (e, s) {
      switch (e.code) {
        case 'email-already-in-use':
          throwErrorState('Email ja em uso,', e, s);
        case 'invalid-email':
          throwErrorState('Email Inválido,', e, s);
        case 'weak-password':
          throwErrorState(
              'Senha fraca, a senha deve conter no mínimo 5 caracteres', e, s);
        case 'too-many-requests':
          throwErrorState(
              'Muitas tentativas,aguarde um momento e tente novamente', e, s);
        case 'network-request-failed':
          throwErrorState(
              'Falha,ao conectear com o serviço,verifique sua conexão', e, s);
       default: throwErrorState("Erro desconhecido entre em contato com o suporte", e, s);
      }
    
    }
  }

  void throwErrorState(String message, dynamic e, StackTrace s) {
    _log.erro(message, e, s);
    throw UserException(message: message);
  }
}
