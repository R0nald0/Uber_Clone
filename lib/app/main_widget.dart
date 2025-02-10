import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_module_passageiro.dart';
import 'package:uber/app/module/auth_module/login_module/login_module.dart';
import 'package:uber/app/module/splash_screen_module/splash_module.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

  final ThemeData temaPadrao = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff37474f)
    )
  );

final ThemeData temaIos = ThemeData(
      colorScheme:ColorScheme.fromSwatch());    


class MainWidget extends StatefulWidget {
  const MainWidget({ super.key });
  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
   final  observerLifeCycle = UberCloneLifeCycle(); 

   @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(observerLifeCycle);
  }

 @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(observerLifeCycle);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  
    return  UberCloneCoreConfig(
      title: "Uber Passageiro", 
      initialRoute:'/SplashModule/home' ,
      modulesRouter: [
          SplashModule(),
          HomeModulePassageiro(),
          RegisterModule()
      ],
      
      );
  }
}