import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/app/util/Status.dart';
import 'package:uber/app/util/UsuarioFirebase.dart';
import '../../../../Rotas.dart';
import '../../../../controller/Banco.dart';

class ViewMotorista extends StatefulWidget{
  const ViewMotorista({super.key});

  @override
  State<StatefulWidget> createState() =>ViewMotoristaState();
}

class ViewMotoristaState extends State<ViewMotorista>{
  List<String> listItens =[
    "Configurações",
    "Deslogar"
  ];
  
  final _controller = StreamController<QuerySnapshot>.broadcast();

  _escolhaItem(String escolha) {
     switch(escolha){
       case "Configurações":
         break;
       case"Deslogar":
         return deslogarUsuario();
         break;
     }
  }
  deslogarUsuario(){
    Banco.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_LOGIN, (route) => false);
  }

  StreamController<QuerySnapshot<Object?>> getRequisicoes(){
    Stream stream = Banco.db.collection("requisicao")
        .where("status" ,isEqualTo: Status.AGUARDANDO)
        .snapshots();

    stream.listen((dados) {
       _controller.add(dados);
    });

    return _controller;
  }
  
  
  _recuperarRequisicaoAtivaMotorista() async{
    User? user = await UsuarioFirebase.getFirebaseUser();
    if(user != null){
       String idMotorista = user.uid.toString();

        DocumentSnapshot snapshot = await Banco.db.collection("requisicao-ativa-motorista")
            .doc(idMotorista)
            .get()
            .then((user) async{

              if(mounted){
                if(user.data() != null ){
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      Rotas.ROUTE_VIEWCORRIDA, (route) => false,arguments: user.get("id_requisicao"));
                }else{
                  getRequisicoes();
                }
              }
              return user;
        }).catchError((onError){
            print("dados $onError" );
        });

    }
  }
  
  @override
  void initState() {
    super.initState();
    _recuperarRequisicaoAtivaMotorista();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motorista"),
        actions: [
          PopupMenuButton<String>(
              onSelected: _escolhaItem,
              itemBuilder: (context)=>
                  listItens.map((String item){
                return PopupMenuItem(
                    value: item,
                    child:Text(item),
                );
              }).toList()
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context,AsyncSnapshot snapshot){
           switch(snapshot.connectionState){
             case ConnectionState.none:
             case ConnectionState.waiting:
               return const Center(
                 child: CircularProgressIndicator(color: Colors.black),
               );

             case ConnectionState.active:
             case ConnectionState.done:
                if(snapshot.hasError){
                    return const Text("Erro ao carregar a Lista de Requisiçoes");
                }else{
                    if(snapshot.hasData){
                       QuerySnapshot querySnapshot = snapshot.data;
                       if(querySnapshot.docs.isEmpty ){
                         return  const Center(child: Text("Nenhuma Viagem disponível"));
                       }else{
                           return _listarRequisicoes(querySnapshot);
                       }
                    }
                }
           }
          return const Center();
        },
      ),
    );
  }

  _listarRequisicoes(QuerySnapshot querySnapshot){
      return Container(
        padding: const EdgeInsets.all(2),
         child: Expanded(
           child: ListView.builder(
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context,index){
                  List<DocumentSnapshot> requisicoes = querySnapshot.docs.toList();
                   DocumentSnapshot requisicao = requisicoes[index];

                   return Card(
                   shadowColor: Colors.black,
                   child: ListTile(
                     title: Row(children:<Widget>[
                       const Text("Passageiro :",style: TextStyle(fontSize: 18,fontWeight:FontWeight.bold)),
                       Text(requisicao['passageiro']['nome'])
                     ],),

                     subtitle: Row(children:<Widget>[
                       const Text("Destino :",style: TextStyle(fontSize: 15,fontWeight:FontWeight.bold)),
                       Text("${requisicao['destino']['rua']},${requisicao["destino"]['bairro']}",style: const TextStyle(fontSize: 15))
                     ],),
                     onTap: (){
                        Navigator.pushNamed(context, Rotas.ROUTE_VIEWCORRIDA,arguments: requisicao.id);
                      },
                   ),
                 );
               }

           ),
         ),
      );
  }

}