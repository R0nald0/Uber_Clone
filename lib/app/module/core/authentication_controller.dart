import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/core/execptions/auth_exception.dart';
import 'package:uber/core/execptions/user_exception.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';

part 'authentication_controller.g.dart';

class AuthenticationController = AuthenticationControllerBase
    with _$AuthenticationController;

abstract class AuthenticationControllerBase with Store {
  final IAuthRepository _authRepository;

  
  AuthenticationControllerBase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @readonly
  Usuario? _usuario;

  @readonly
  String? _errorMessage;

  @action
  Future<void> verifyStateUserLogged() async {
    try {
      final user = await _authRepository.verifyStateUserLogged();
      if (user != null) {
       _usuario = await _authRepository.getDataUserOn(user.uid);
      }else{
         logout();
      }
    } on AuthException catch (e, s) {
       if (kDebugMode) {
         print(s);
       }
     _errorMessage = "erro ao logar";
       
    } on UserException catch (e,s) {
       if (kDebugMode) {
         print(s);
       }
      _errorMessage ="Erro ao buscar dados do ususario";
    }
  }

  Future<void> logout() async{
     _usuario = Usuario.emptyUser();
     Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN,(_) => false,);
     _authRepository.logout();
     
  }
  
}
