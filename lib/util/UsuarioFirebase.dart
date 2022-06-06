
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/controller/Banco.dart';
import 'package:uber/model/Usuario.dart';

class UsuarioFirebase{
  static Future<User?> getFirebaseUser() async {
    return await Banco.auth.currentUser;
  }

  static Future<Usuario> recuperarDadosPassageiro() async{
    User? user = Banco.auth.currentUser;

      DocumentSnapshot snapshot = await Banco.db.collection("usuario").doc(user?.uid).get();
       User? firebaseUse = await getFirebaseUser();
      String? idUsuarioLogado =  firebaseUse?.uid;

      Usuario usuario =Usuario();
      usuario.idUsuario =idUsuarioLogado!;
      usuario.tipoUsuario= snapshot.get("tipoUsuario");
      usuario.nome=snapshot.get("nome");
      usuario.email=snapshot.get("email");

      return usuario;
  }
  static atualizarPosicaoUsuario(String idRequisicao,String campoAtulizar,double lat ,double long) async{

    Usuario usuarioMot = await UsuarioFirebase.recuperarDadosPassageiro();
     usuarioMot.latitude = lat;
     usuarioMot.longitude = long;

     Banco.db.collection('requisicao')
        .doc(idRequisicao)
        .update({
          campoAtulizar : usuarioMot.toMapUp()
    });

  }

 static Future<DocumentSnapshot> getDadosRequisicao(id) async {
    DocumentSnapshot snapshot = await Banco.db.collection("requisicao").doc(id).get();
    return snapshot;
  }

}