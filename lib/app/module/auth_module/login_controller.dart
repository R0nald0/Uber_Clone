
import 'package:mobx/mobx.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final IUserService _userService;
  final IAuthService _authService;
  
  LoginControllerBase({required IUserService serviceUser,required IAuthService authService}):
        _userService = serviceUser,
        _authService = authService,
        super();

  @readonly
  String? _errorMensage;

  @readonly
  bool? _hasSuccessLogin;
  

  @action
  Future<void> login(String email, String password) async {
    try {
      _errorMensage = null;
      final isSuccess = await _authService.login(email, password);
      if (isSuccess) {
        _hasSuccessLogin  = isSuccess;
        return;
      }
     _hasSuccessLogin =false;
    } on UserException catch (e) {
      _errorMensage = e.message;
    }
  }
}
