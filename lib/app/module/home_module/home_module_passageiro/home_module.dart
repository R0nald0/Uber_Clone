import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro.dart';

class HomeModule extends Module {
  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.child('/', child: (_) =>const HomePassageiro());
  }
}