
import 'package:mobx/mobx.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
 
  final IAuthService _authService;
  
  LoginControllerBase({required IAuthService authService}):
        _authService = authService,
        super();

  @readonly
  String? _errorMensage;

  @readonly
  bool? _hasSuccessLogin ;
  

  @action
  Future<void> login(String email, String password) async {
      _errorMensage = null;
      _hasSuccessLogin = null;
    try {    

      final isSuccess = await _authService.login(email, password);
      if (isSuccess) {
        _hasSuccessLogin  = true;
        return;
      }
     _hasSuccessLogin =false;
     
    } on UserException catch (e) {
       
      _hasSuccessLogin = false;
     _errorMensage = 'Email ou senha incorreta,por favor tente novamente';
    }
  }
}
