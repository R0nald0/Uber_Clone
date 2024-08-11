import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/register_module/register_page.dart';

class RegisterModule extends Module {
   @override
  void routes(RouteManager r) {
  
    super.routes(r);
    r.child(Modular.initialRoute, child: (_) => const RegisterPage());
   
  }
}