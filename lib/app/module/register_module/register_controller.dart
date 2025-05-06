
 
import 'package:mobx/mobx.dart';
import 'package:uber/app/services/user_service/user_service.dart';
part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController ;

abstract class RegisterControllerBase with Store {
  final UserService _userService;

  RegisterControllerBase({required UserService userService})
  :_userService =userService;
  
}