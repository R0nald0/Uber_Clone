import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/splas_screen_module/SplashScreen.dart';
import 'package:uber/app/module/login_module/login_module.dart';
import 'package:uber/app/module/register_module/register_module.dart';

class SplashModule  extends Module{
  @override
  void routes(RouteManager r) {

    super.routes(r);
    r.child('/', child:(_) => const SplashScreen());
    r.module('/login/', module: LoginModule());
    r.module('/register/', module: RegisterModule());
  }
}