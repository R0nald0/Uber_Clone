import 'package:flutter_getit/flutter_getit.dart';

import 'package:uber/app/module/auth_module/login_controller.dart';
import 'package:uber/app/module/auth_module/login_module/login_page.dart';
import 'package:uber/app/module/auth_module/register_module/register_controller.dart';
import 'package:uber/app/module/auth_module/register_module/register_page.dart';
import 'package:uber_clone_core/uber_clone_core.dart';


class RegisterModule extends FlutterGetItModuleRouter {
  RegisterModule():super(
    name: "/Auth",
    bindings: [
      Bind.lazySingleton<IAuthService>((i) => i()),
      Bind.lazySingleton<IUserService>((i) => i())
    ],
    pages: [
      FlutterGetItPageRouter(
        name: "/LoginPage",
        bindings: [
         Bind.lazySingleton((i) =>LoginController(
            serviceUser: i(), 
            authService: i()
            ))
        ],
        builder: (context) =>LoginPage(loginController: context.get<LoginController>()),
      ),
      FlutterGetItPageRouter(
        name: "/RegisterPage",
        bindings: [
          Bind.lazySingleton((i) => RegisterController(
            userService: i(), 
            authRepository: i()
            ),)
        ],
        builder: (context) =>RegisterPage(registerController: context.get<RegisterController>()),
      
      )
    ],
  );
  
}
