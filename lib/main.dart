
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/SplashScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await   Firebase.initializeApp();


  final ThemeData temaPadrao = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Color(0xff37474f)
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