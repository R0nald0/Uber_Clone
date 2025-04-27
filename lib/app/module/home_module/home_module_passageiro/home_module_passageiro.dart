import 'package:flutter_getit/flutter_getit.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_page_passageiro.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';

class HomeModulePassageiro extends FlutterGetItModuleRouter {
  HomeModulePassageiro()
      : super(
          name: '/Home',
          bindings: [
            Bind.singleton(
              (i) => AuthenticationController(authService: i()),
            )
          ],
          pages: [
            FlutterGetItPageRouter(
                name: "/PassageiroPage",
                builder: (context) => HomePassageiroPage(
                    homePassageiroController:
                        context.get<HomePassageiroController>()),
                bindings: [
                  Bind.lazySingleton<HomePassageiroController>(
                    (i) => HomePassageiroController(
                        addressService: i(),
                        authService: i(),
                        userService: i(),
                        locattionService: i(),
                        cameraService: i(),
                        tripService: i(), 
                        requestService: i()
                        ),
                  )
                ]),
          ],
        );
}
