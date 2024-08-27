

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/app/model/Usuario.dart';
import '../Rotas.dart';

class Banco{
   static var auth = FirebaseAuth.instance;
   static var db   = FirebaseFirestore.instance;

   salvarUserbd(Usuario usuario)async{
     await db.collection("usuario")
         .doc(usuario.idUsuario)
         .set(usuario.toMap());
  }

  logarUsuario(String email,String senha,context)async{

    await auth.signInWithEmailAndPassword(
        email: email,
        password: senha
    ).then((user) async{

         DocumentSnapshot snapshot =  await db.collection("usuario").doc(user.user?.uid).get();
         final tipoUsuario = snapshot.get("tipoUsuario");

        if(tipoUsuario =="passageiro"){
          Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false);
        }else{
          Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWMOTORISTA, (route) => false);
        }

    }).catchError((erro){
        print("erro" + erro.toString());
    });
  }


}