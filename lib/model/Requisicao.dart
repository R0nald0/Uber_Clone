import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/controller/Banco.dart';
import 'package:uber/model/Destino.dart';

import 'Usuario.dart';


class Requisicao {

  late String _id;
  late Destino _destino;
  late Usuario _passageiro;
  late String status;
  late Usuario _motorista;
  late String valorCorrida;

  Requisicao(){
      //OBTENDO ID REQUISICAO DA COLLECION
      DocumentReference ref = Banco.db.collection("requisicao").doc();
      this.id = ref.id;
  }



  Map<String,dynamic> toMap(){

    Map<String,dynamic> dadosPassageiro={
      "idUsuario" :  this.passageiro.idUsuario,
      "nome":        this.passageiro.nome,
      "email":       this.passageiro.email,
      "tipoUsuario": this.passageiro.tipoUsuario,
      "latitude" :   this.passageiro.latitude,
      "longitude" :  this.passageiro.longitude
    };

    Map<String,dynamic> dadosDestino={
      "rua":this.destino.rua,
      "nomeDestino":this.destino.nomeDestino,
      "bairro" : this.destino.bairo,
      "cep" : this.destino.cep,
      "cidade" :this.destino.cidade,
      "numero" :this.destino.numero,
      "latitude":this.destino.latitude,
      "longitude" :this.destino.longitude
    };


    Map<String,dynamic> dadosRequisicao ={
      "idRequisicao" :this.id,
      "status" :this.status,
      "valorCorrida" :this.valorCorrida,
      "motorista" : null,
      "passageiro": dadosPassageiro,
      "destino" :dadosDestino
    };

    return dadosRequisicao;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}
