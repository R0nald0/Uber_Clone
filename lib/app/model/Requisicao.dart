import 'package:uber/app/model/addres.dart';

import 'Usuario.dart';


class Requisicao {
  final String? id;
  final Addres destino;
  final Usuario passageiro;
  final String status;
  final Usuario? motorista;
  final String valorCorrida;
  
  Requisicao({required this.id, required this.destino,required this.motorista,required this.passageiro,required this.status,required this.valorCorrida});

 /*  Requisicao.consulta(){
      //OBTENDO ID REQUISICAO DA COLLECION
      DocumentReference ref = Banco.db.collection("requisicao").doc();
      this.id = ref.id;
  } */
  
  Requisicao.empty() :
    id =null,
    destino =Addres.emptyAddres(),
    motorista =Usuario.emptyUser(),
    passageiro =Usuario.emptyUser(),
    status ='',
    valorCorrida ='',
    super();


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
}
