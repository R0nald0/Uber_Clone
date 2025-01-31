import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/app/module/login_module/login_module.dart';
import 'package:uber/app/module/register_module/register_module.dart';
import 'package:uber/app/module/splash_screen_module/SplashScreen.dart';

class SplashModule extends Module {
  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.child(Modular.initialRoute,child: (_) => SplashScreen(auth: Modular.get<AuthenticationController>(),));
     r.module('/login/', module: LoginModule());
    r.module('/register/', module: RegisterModule());
  }
}
