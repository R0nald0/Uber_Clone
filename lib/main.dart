
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/SplashScreen.dart';
import 'package:uber/app/core/app_config_initialization.dart';

void main() async{
     await AppConfigInitialization().loadConfig();


  final ThemeData temaPadrao = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff37474f)
    )
  );


  final ThemeData temaIos = ThemeData(
      colorScheme:ColorScheme.fromSwatch());


  runApp(MaterialApp(
    title: "Uber",
    theme: Platform.isIOS == true? temaIos :temaPadrao,
    home: const SplashScreen(),

    initialRoute: Rotas.ROUTE_SPLASHSCREEN,
    onGenerateRoute:Rotas.getRotas,

  ));
}