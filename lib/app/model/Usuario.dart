import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../Rotas.dart';
import '../../controller/Banco.dart';

class Usuario {
  final String? idUsuario;
  final String email;
  final String nome;
  final String tipoUsuario;
  final String senha;
  final double latitude;
  final double longitude;

  Usuario({
    this.idUsuario,
    required this.email,
    required this.nome,
    required this.tipoUsuario,
    required this.senha,
    required this.latitude,
    required this.longitude,
  });

  
  

 

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map={
      'idUsuario' : idUsuario,
      "nome" : nome,
      "email":email,
      "tipoUsuario":tipoUsuario,
    };
    return map;
  } 
  
  factory Usuario.fromFirestore( DocumentSnapshot snapshot ){
     return  Usuario(
        idUsuario: snapshot['idUsuario'] ?? '',
        email: snapshot["email"] ?? '', 
        nome:  snapshot["nome"] ?? '', 
        tipoUsuario: snapshot["tipoUsuario"] ?? '', 
        senha: '', 
        latitude: 0, 
        longitude: 0
        );
  }
  
  Usuario.emptyUser() :
  email = '',
  idUsuario ='',
  latitude =0,
  longitude= 0,
  nome = '',
  senha = '',
  tipoUsuario = '',
  super();




  Map<String,dynamic> toMapUp(){
    Map<String,dynamic> map={
      'idUsuario' : idUsuario,
      "nome" : nome,
      "email":email,
      "tipoUsuario":tipoUsuario,
      "latitude"   : latitude,
      "longitude" : longitude
    };
    return map;
  }

  cadastrarUsuario(context,user) async{
  try {
  final userCredencia =   await Banco.auth.createUserWithEmailAndPassword(
        email: email,
        password: senha
    );
    
     if (userCredencia.user != null) {
     
        // idUsuario = userCredencia.user?.uid;
         await Banco.db.collection("usuario").doc(userCredencia.user!.uid).set(toMap());
         tipoUsuario == "passageiro"
          ?Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false)
          :Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWMOTORISTA, (route) => false);
      }   
} on Exception catch (e,s) {
     print('errr  $e');
     print('stack  $s');
}
  }



  Usuario copyWith({
    ValueGetter<String?>? idUsuario,
    String? email,
    String? nome,
    String? tipoUsuario,
    String? senha,
    double? latitude,
    double? longitude,
  }) {
    return Usuario(
      idUsuario: idUsuario != null ? idUsuario() : this.idUsuario,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      senha: senha ?? this.senha,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
