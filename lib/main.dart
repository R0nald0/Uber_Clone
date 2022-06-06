
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/SplashScreen.dart';
import 'package:uber/views/Home.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

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
    home: SplashScreen(),

    initialRoute: Rotas.ROUTE_SPLASHSCREEN,
    onGenerateRoute:Rotas.getRotas,

  ));
}