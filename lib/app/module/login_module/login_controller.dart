
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
  String? _usuario;
  

  @action
  Future<void> login(String email, String password) async {
    try {
      _errorMensage = null;
      final user = await _authService.login(email, password);
      if (user) {
        
      }
    } on UserException catch (e) {
      _errorMensage = e.message;
    }
  }
}
