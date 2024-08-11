import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_module.dart';
import 'package:uber/app/module/splas_screen_module/splash_module.dart';

class MainModule extends Module {
    @override
  void binds(Injector i) {
  
    super.binds(i);
  }

  @override
  void routes(RouteManager r) {
   
    super.routes(r);
    r.module(Rotas.ROUTE_SPLASHSCREEN, module: SplashModule());
    r.module(Rotas.ROUTE_VIEWPASSAGEIRO, module: HomeModule());
    r.module(Rotas.ROUTE_VIEWMOTORISTA, module: HomeModule());
  
  }
}