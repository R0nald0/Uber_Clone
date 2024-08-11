import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/login_module/login_page.dart';

class LoginModule extends Module {
  
  @override
  void routes(RouteManager r) {

    super.routes(r);
    r.child(Modular.initialRoute, child: (_) => const LoginPage());
  }
}