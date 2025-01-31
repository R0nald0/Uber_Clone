import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/core/core_module.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_module_passageiro.dart';
import 'package:uber/app/module/splash_screen_module/splash_module.dart';

class MainModule extends Module {

  @override
  List<Module> get imports => [
     CoreModule()
  ];

  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.module(Rotas.ROUTE_SPLASHSCREEN, module: SplashModule());
    r.module(Rotas.ROUTE_VIEWPASSAGEIRO, module: HomeModulePassageiro());
    r.module(Rotas.ROUTE_VIEWMOTORISTA, module: HomeModulePassageiro()); 
  }
}