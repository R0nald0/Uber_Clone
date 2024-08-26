import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/login_module/login_module.dart';
import 'package:uber/app/module/register_module/register_module.dart';
import 'package:uber/app/module/splash_screen_module/SplashScreen.dart';

class SplashModule extends Module {
  @override
  void binds(Injector i) {
    super.binds(i);

     
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.child(Modular.initialRoute, child: (_) => SplashScreen(authController: Modular.get()));
    r.module('/login/', module: LoginModule());
    r.module('/register/', module: RegisterModule());
  }
}
