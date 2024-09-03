
 
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/execptions/user_exception.dart';

part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController ;

abstract class RegisterControllerBase with Store {
  final UserService _userService;
  final IAuthRepository _authRepository;

  @readonly
  String? _errorMessange;

  RegisterControllerBase({required UserService userService,required IAuthRepository authRepository})
  :_userService =userService,
   _authRepository =authRepository
  ;

  Future<void> register(String name,String email,String password) async{
     try {
        _errorMessange =null;
       final user  = await _authRepository.register(name, email, password,UberCloneConstants.TIPO_USUARIO_PASSAGEIRO);
       if (user != null) {
         Modular.to.navigate(Rotas.ROUTE_VIEWPASSAGEIRO);
         return;
       }
       throw UserException(message: "Erro ao criar usuario");

     } on UserException catch (e) {
       _errorMessange = e.message;
     }
  }
  
}