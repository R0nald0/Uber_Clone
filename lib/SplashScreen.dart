
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/controller/Banco.dart';
import 'package:uber/model/Usuario.dart';
import 'package:uber/util/UsuarioFirebase.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  verificarUsuarioOn() async {

    User? user = await UsuarioFirebase.getFirebaseUser();
    if (user != null) {
       recuperarDadosUsuario(user.uid);
    }else{
      Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_HOME, (route) => false);
    }
  }
  
  recuperarDadosUsuario(String id) async {

    DocumentSnapshot snapshot =  await Banco.db.collection("usuario").doc(id).get();

    if( snapshot.data() != null){
      Usuario usuario = Usuario() ;
      usuario.tipoUsuario = snapshot.get("tipoUsuario");

      usuario.tipoUsuario == "passageiro"
          ?Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false)
          :Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWMOTORISTA, (route) => false);
    }else{
     Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_HOME, (route) => false);

    }

  }

  @override
  void initState() {
  
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
        verificarUsuarioOn();
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(60),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/fundo.png"), fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 50),
                  child: Image.asset("images/logo.png"),
                ),
                const LinearProgressIndicator(
                  color: Colors.blue,
                  minHeight: 2,
                ),
              ],
            ),
          )),
    );
  }
}
