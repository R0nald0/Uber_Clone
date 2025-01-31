import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/main_module.dart';
import 'package:uber/app/main_widget.dart';
import 'package:uber/app/module/core/app_config_initialization.dart';

void main() async{
    await AppConfigInitialization().loadConfig();
  runApp(
    ModularApp(module: MainModule(), child: const MainWidget())
  ); 
}

/* MaterialApp(
    title: "Uber",
    theme: Platform.isIOS == true? temaIos :temaPadrao,
    home: const SplashScreen(),
    initialRoute: Rotas.ROUTE_SPLASHSCREEN,
  onGenerateRoute:Rotas.getRotas,
  ) */