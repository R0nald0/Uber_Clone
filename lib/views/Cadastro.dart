import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/controller/Banco.dart';
import 'package:uber/model/Usuario.dart';

class Cadastro extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CadastroState();

}

class CadastroState extends State<Cadastro>{
 TextEditingController _controllerNome  =  TextEditingController();
 TextEditingController _controllerEmail = TextEditingController();
 TextEditingController _controllerSenha =  TextEditingController();
 bool _tipoUsuario = false;
 String erroMensagem = "";

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Cadastro"),
     ),
      body: Container(
        padding: EdgeInsets.all(16),
        child:Center(
           child: SingleChildScrollView(
             child: Column( crossAxisAlignment: CrossAxisAlignment.stretch,
               children: <Widget>[
                  _camposCadastro(),

                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       primary: Colors.blue[200],
                     padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                     textStyle: TextStyle(fontSize: 18,),
                     shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     elevation: 1
                   ),
                     onPressed: (){
                          _validarCampos();
                     },
                     child: Text("Cadastrar")
                 )
               ],
             ),
           ),
        ) ,
      ),

   );
  }
  _camposCadastro(){
     return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children:<Widget> [
            TextField(
              controller: _controllerNome,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(32, 18, 32, 18),
                filled: true,
                fillColor: Colors.white,
                hintText: "Nome......",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                label:Text("Nome.....",style:TextStyle(fontSize: 20),),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 13,bottom: 13),
              child: TextField(
                controller: _controllerEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 18, 32, 18),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "SeuEmail@.com......",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  label:Text("Email....",style:TextStyle(fontSize: 20),),
                ),
              ),

            ),

            TextField(
              controller: _controllerSenha,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(32, 18, 32, 18),
                filled: true,
                fillColor: Colors.white,
                hintText: "Senha......",
                focusColor: Colors.black,
                hoverColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                label:Text("Senha....",style:TextStyle(fontSize: 20),),
              ),
            ),
            Padding(
                padding:EdgeInsets.only(top: 10,bottom: 20),
                child: Row(
                  children: <Widget>[
                    Text("Passageiro"),
                    Switch(
                        value: _tipoUsuario,
                        onChanged: (bool valor){
                          setState(() {
                            _tipoUsuario = valor;
                          });
                        }
                    ),
                    Text("Motorista")
                  ],
                )
            ),


          ],
        ),
     );
  }

  _validarCampos(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){
       if(email.contains("@") && email.isNotEmpty){
          if(senha.length > 5  && senha.isNotEmpty){

             Usuario user = Usuario();
             user.senha = senha;
             user.nome=nome;
             user.email=email;
             user.tipoUsuario = user.verificaTipoUsuario(_tipoUsuario);

             cadastrarUsuario(user);


          }else{
            erroMensagem = "Erro ao Cadastrar Usuario! Defina uma senha com mais que 4 caracteres";
            _snackBar(erroMensagem);
          }
       }else{
         erroMensagem = "Erro ao Cadastrar Usuario! Defina um Email válido";
         _snackBar(erroMensagem);
       }

    }else{
        erroMensagem = "Erro ao Cadastrar Usuario! Defina um Nome";
       _snackBar(erroMensagem);
    }

  }

  cadastrarUsuario(Usuario user) async{
     await user.cadastrarUsuario( context);
  }

  _snackBar(String erro){

    final snackBar= SnackBar(
        content: Text(erro),
       );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}