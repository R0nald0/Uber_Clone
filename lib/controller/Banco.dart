

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber/model/Usuario.dart';
import '../Rotas.dart';

class Banco{
   static var auth = FirebaseAuth.instance;
  static var db   = FirebaseFirestore.instance;

   salvarUserbd(Usuario usuario)async{
     await db.collection("usuario")
         .doc(usuario.idUsuario)
         .set(usuario.toMap());
  }

  LogarUsuario(Usuario usuario,context)async{

    await auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((user) async{

         Usuario usuario = Usuario();
         DocumentSnapshot snapshot =  await db.collection("usuario").doc(user.user?.uid).get();
         usuario.tipoUsuario = snapshot.get("tipoUsuario");

        if(usuario.tipoUsuario =="passageiro"){
          Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false);
        }else{
          Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWMOTORISTA, (route) => false);
        }

    }).catchError((erro){
        print("erro" + erro.toString());
    });
  }


}