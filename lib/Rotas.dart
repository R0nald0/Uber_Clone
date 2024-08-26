import 'package:flutter/material.dart';
import 'package:uber/app/module/splash_screen_module/SplashScreen.dart';
import 'package:uber/app/module/register_module/register_page.dart';
import 'package:uber/app/module/login_module/login_page.dart';
import 'package:uber/app/module/home_module/home_module_motorista/ViewMotorista.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_page_passageiro.dart';
import 'package:uber/app/module/corrida_module/view_corrida.dart';

class Rotas{

  static const ROUTE_LOGIN ="/splash/login";
  static const ROUTE_REGISTER ="/splash/register";
  static const ROUTE_SPLASHSCREEN = "/splash/";
  static const ROUTE_VIEWPASSAGEIRO = "/home-passagerio";
  static const ROUTE_VIEWMOTORISTA = "/home-motorista";
  static const ROUTE_VIEWCORRIDA  = "/view-corrida";
  static var args;

  static Route<dynamic>? getRotas(RouteSettings settings){
     args = settings.arguments;

    switch(settings.name){

  

      case ROUTE_REGISTER:
        return MaterialPageRoute(builder: (_)=>RegisterPage());
      case ROUTE_VIEWPASSAGEIRO:
        return MaterialPageRoute(builder: (_)=>HomePassageiroPage());
      case ROUTE_VIEWMOTORISTA:
        return MaterialPageRoute(builder: (_)=>ViewMotorista());

        case ROUTE_VIEWCORRIDA:
        return MaterialPageRoute(builder: (_)=>ViewCorrida(args));
      default :_erroRota;
    }
  }

  static Route<dynamic> _erroRota(){
     return MaterialPageRoute(
         builder: (_){
            return Scaffold(
               appBar: AppBar(title: const Text("Erro de Rota"),),
                body: const Center(
                  child: Text("Erro ao direcionar rota"),
                ),
            );
         }
     );
  }

}