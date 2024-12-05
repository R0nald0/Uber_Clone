import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/Rotas.dart';
    


  final ThemeData temaPadrao = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff37474f)
    )
  );


  final ThemeData temaIos = ThemeData(
      colorScheme:ColorScheme.fromSwatch());    
class MainWidget extends StatelessWidget {

  const MainWidget({ super.key });
  
  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute(Rotas.ROUTE_SPLASHSCREEN);
    return MaterialApp.router(
      title: 'Uber',
      theme: Platform.isIOS == true? temaIos :temaPadrao,
      routerConfig: Modular.routerConfig,
    );
  }
}