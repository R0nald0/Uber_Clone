import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Rotas.dart';
import '../controller/Banco.dart';

class Usuario{
  late String? _idUsuario;
  late String _email;
  late String _nome;
  late String _tipoUsuario;
  late String _senha;
  late double _latitude;
  late double _longitude;

  Usuario();

  verificaTipoUsuario(bool usuarioTipo){
     return usuarioTipo?"motorista" : "passageiro";
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map={
      'idUsuario' : idUsuario,
      "nome" : nome,
      "email":email,
      "tipoUsuario":_tipoUsuario,
    };
    return map;
  }

  Map<String,dynamic> toMapUp(){
    Map<String,dynamic> map={
      'idUsuario' : idUsuario,
      "nome" : nome,
      "email":email,
      "tipoUsuario":_tipoUsuario,
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
     
        _idUsuario = userCredencia.user?.uid;
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

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get idUsuario => _idUsuario ??'';

  set idUsuario(String? value) {
    _idUsuario = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }
}