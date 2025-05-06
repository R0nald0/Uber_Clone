import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_page_passageiro.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';

class HomeModulePassageiro extends Module {
  
  @override
  void binds(Injector i) {
      i.addLazySingleton( () => HomePassageiroController(
        authRepository: Modular.get()
      ));
    super.binds(i);
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.child('/', child: (_) =>const HomePassageiroPage());
  }
}