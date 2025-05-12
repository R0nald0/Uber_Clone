
 
import 'package:mobx/mobx.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController ;

abstract class RegisterControllerBase with Store {
  final IUserService _userService;
  final IAuthService _authService;

  @readonly
  String? _errorMessange;

  @readonly
  bool? _hasSuccesRegister;

  RegisterControllerBase({required IUserService userService,required IAuthService authRepository})
  :_userService =userService,
   _authService =authRepository;

  Future<void> register(String name,String email,String password) async{
     try {
        _errorMessange =null;
        _hasSuccesRegister = null;
       final isSuccess  = await _authService.register(name, email, password,UberCloneConstants.TIPO_USUARIO_PASSAGEIRO);
       if (isSuccess) {
        _hasSuccesRegister = isSuccess;
        _authService.logout();
         return;
       }
      _hasSuccesRegister = false;
     } on UserException catch (e) {
       _errorMessange = e.message;
       _hasSuccesRegister = false;
     }
  }
  
}