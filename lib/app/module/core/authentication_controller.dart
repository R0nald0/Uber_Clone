import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/exceptions/auth_exception.dart';
import 'package:uber/core/exceptions/user_exception.dart';
import 'package:uber/core/local_storage/local_storage.dart';

part 'authentication_controller.g.dart';

class AuthenticationController = AuthenticationControllerBase
    with _$AuthenticationController;

abstract class AuthenticationControllerBase with Store {
  final IAuthRepository _authRepository;
  final LocalStorage _local ;

  
  AuthenticationControllerBase({required IAuthRepository authRepository, required LocalStorage storage})
      : _authRepository = authRepository,_local=storage;

  @readonly
  String? _errorMessage;

  @action
  Future<void> verifyStateUserLogged() async {
    try {
      final user = await _authRepository.verifyStateUserLogged();
      if (user != null) {
         Modular.to.pushNamedAndRemoveUntil(
             Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false);
         final userLocal = await _local.read<String>(UberCloneConstants.KEY_PREFERENCE_USER);
         print('$userLocal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
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
      _errorMessage ="Erro ao buscar dados do usuario";
    }
  }

  Future<void> logout() async{
     Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN,(_) => false,);
     _authRepository.logout();
     
  }
  
}
