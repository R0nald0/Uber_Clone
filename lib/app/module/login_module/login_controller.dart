
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/execptions/user_exception.dart';

part 'login_controller.g.dart';


class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store{
final UserService _userService;
LoginControllerBase({required UserService serviceUser}) :
_userService  = serviceUser,
super();

@readonly
String? _errorMensage ;

@action
Future<void> login(String email,String password)async{
   try {
       _errorMensage = null;
      await _userService.logar(email,password);
      Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_VIEWPASSAGEIRO, (_) => false);
   } on UserException catch (e) {
      _errorMensage = e.message;
   }
}

}