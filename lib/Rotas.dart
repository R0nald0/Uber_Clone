import 'package:flutter/material.dart';
import 'package:uber/SplashScreen.dart';
import 'package:uber/views/Cadastro.dart';
import 'package:uber/views/Home.dart';
import 'package:uber/views/ViewMotorista.dart';
import 'package:uber/views/ViewPassageiro.dart';
import 'package:uber/views/ViewCorrida.dart';

class Rotas{

  static const ROUTE_HOME ="/Home";
  static const ROUTE_CADASTRO ="/Cadstro";
  static const ROUTE_SPLASHSCREEN = "/SplashScreen";
  static const ROUTE_VIEWPASSAGEIRO = "/ViewPassageiro";
  static const ROUTE_VIEWMOTORISTA = "/ViewMotorista";
  static const ROUTE_VIEWCORRIDA  = "/ViewCorrida";
  static var args;

  static Route<dynamic>? getRotas(RouteSettings settings){
     args = settings.arguments;

    switch(settings.name){

      case ROUTE_SPLASHSCREEN:
        return MaterialPageRoute(builder: (_)=> SplashScreen());

      case ROUTE_HOME:
        return MaterialPageRoute(builder: (_)=>Home());
        break;

      case ROUTE_CADASTRO:
        return MaterialPageRoute(builder: (_)=>Cadastro());
        break;
      case ROUTE_VIEWPASSAGEIRO:
        return MaterialPageRoute(builder: (_)=>ViewPassageiro());
        break;
      case ROUTE_VIEWMOTORISTA:
        return MaterialPageRoute(builder: (_)=>ViewMotorista());
        break;

        case ROUTE_VIEWCORRIDA:
        return MaterialPageRoute(builder: (_)=>ViewCorrida(args));
        break;
      default :_erroRota;
    }
  }

  static Route<dynamic> _erroRota(){
     return MaterialPageRoute(
         builder: (_){
            return Scaffold(
               appBar: AppBar(title: Text("Erro de Rota"),),
                body: Center(
                  child: Text("Erro ao direcionar rota"),
                ),
            );
         }
     );
  }

}