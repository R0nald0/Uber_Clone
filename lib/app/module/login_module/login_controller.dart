
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/exceptions/user_exception.dart';

part 'login_controller.g.dart';


class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store{
final UserService _userService;
final IAuthRepository _authRepository;
LoginControllerBase({required UserService serviceUser,required IAuthRepository authRepository}) :
_userService  = serviceUser,
_authRepository =authRepository,
super();

@readonly
String? _errorMensage ;

@action
Future<void> login(String email,String password)async{
   try {
       _errorMensage = null;
      final user =await _authRepository.logar(email,password);
       if (user != null) {
         Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_VIEWPASSAGEIRO, (_) => false);
       }
      
   } on UserException catch (e) {
      _errorMensage = e.message;
   }
}

}