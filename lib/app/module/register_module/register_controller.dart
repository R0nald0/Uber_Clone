
 
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/execptions/user_exception.dart';
part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController ;

abstract class RegisterControllerBase with Store {
  final UserService _userService;

  @readonly
  String? _errorMessange;

  RegisterControllerBase({required UserService userService})
  :_userService =userService;

  Future<void> register(String name,String email,String password) async{
     try {
        _errorMessange =null;
       final user  = await _userService.register(name, email, password,UberCloneConstants.TIPO_USUARIO_PASSAGEIRO);
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