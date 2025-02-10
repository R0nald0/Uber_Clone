import 'package:flutter_getit/flutter_getit.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/app/module/splash_screen_module/SplashScreen.dart';


class SplashModule extends FlutterGetItModuleRouter {
  SplashModule():super(
    name: '/SplashModule',
    bindings: [],
    pages: [
      FlutterGetItPageRouter(
        name:"/home",
        bindings: [
          Bind.singleton((i)=>AuthenticationController(authService: i()))
        ],
        builder: (context) => SplashScreen(auth: context.get<AuthenticationController>()),
        ),
    ],
    
    
    );
  
}
