

import 'package:flutter/material.dart';

import 'package:uber/Rotas.dart';
import 'package:uber/controller/Banco.dart';

import '../../../model/Usuario.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() =>LoginPageState();
  
}

class LoginPageState extends State<LoginPage>{

  final TextEditingController _controllerEmail =TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  String erroMensagem= "";

  _validarCampos(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.contains("@") && email.isNotEmpty){
      if(senha.length > 5  && senha.isNotEmpty){

        Usuario user = Usuario();
        user.senha = senha;
        user.email=email;

        logarUsuario(user);


      }else{
        erroMensagem = "Erro ao Cadastrar Usuario! Defina uma senha com mais que 4 caracteres";
        _snackBar(erroMensagem);
      }
    }else{
      erroMensagem = "Erro ao Cadastrar Usuario! Defina um Email válido";
      _snackBar(erroMensagem);
    }
  }
  logarUsuario( Usuario usuario) async{
    Banco bd = Banco();
    bd.logarUsuario(usuario, context);

  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(

        body:  Container(
              padding: const EdgeInsets.all(16),
              decoration:const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/fundo.png")
                    ,fit: BoxFit.cover
                ),
              ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(padding: const EdgeInsets.only(top:50),
                          child:Image.asset("images/logo.png",height:200,width:200,),
                        ),
                        camposLoginTxtV(),
                        campoBtns(),
                      ],
                    ),
                  ),
                )

          ),

      );
  }

  camposLoginTxtV(){
   return Column(
     children: <Widget>[
       Padding(
         padding:const EdgeInsets.only(top: 20,bottom: 10),
         child:
         TextField(
           keyboardType: TextInputType.emailAddress,
          controller: _controllerEmail,
           decoration: InputDecoration(
               hintText: "Email....",
               filled: true,
               fillColor: Colors.white,
               prefixIcon: const Icon(Icons.email_outlined),
               border:OutlineInputBorder(
                   borderRadius: BorderRadius.circular(16)
               ),
               contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16)
           ),
           style: const TextStyle(fontSize: 18),
         ),
       ),
       TextField(
         controller: _controllerSenha,
         keyboardType: TextInputType.text,
         obscureText: true,
         decoration: InputDecoration(
             hintText: "Senha....",
             filled: true,
             fillColor: Colors.white,
             prefixIcon: const Icon(Icons.password_rounded),
             border:OutlineInputBorder(
                 borderRadius: BorderRadius.circular(16)
             ),
             contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16)
         ),
         style: const TextStyle(fontSize: 18),
       ),
     ],
   );
  }

  campoBtns(){
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20,bottom: 8),
          child: ElevatedButton(
            style:ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[200],
              padding: const EdgeInsets.fromLTRB(32,16, 32, 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: (){
              _validarCampos();
            },
            child: const Text("Login"),
          ),
        ),
        TextButton(
            onPressed: (){
              Navigator.pushNamed(context, Rotas.ROUTE_REGISTER);
            },
            child: const Text("Nao tem conta, Cadastre-se!! ",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white
              ),
            )
        )
      ],
    );
  }


  _snackBar(String erro){

    final snackBar= SnackBar(
      content: Text(erro)
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
}