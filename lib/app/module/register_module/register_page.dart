import 'package:flutter/material.dart';
import 'package:uber/app/model/Usuario.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => RegisterPageState();

}

class RegisterPageState extends State<RegisterPage>{
 final TextEditingController _controllerNome  =  TextEditingController();
 final TextEditingController _controllerEmail = TextEditingController();
 final TextEditingController _controllerSenha =  TextEditingController();
 bool _tipoUsuario = false;
 String erroMensagem = "";

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Cadastro"),
     ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child:Center(
           child: SingleChildScrollView(
             child: Column( crossAxisAlignment: CrossAxisAlignment.stretch,
               children: <Widget>[
                  _camposCadastro(),

                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue[200],
                     padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                     textStyle: const TextStyle(fontSize: 18,),
                     shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     elevation: 1
                   ),
                     onPressed: (){
                          _validarCampos();
                     },
                     child: const Text("Cadastrar")
                 )
               ],
             ),
           ),
        ) ,
      ),

   );
  }
  _camposCadastro(){
     return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
       children:<Widget> [
         TextField(
           controller: _controllerNome,
           keyboardType: TextInputType.name,
           decoration: InputDecoration(
             contentPadding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
             filled: true,
             fillColor: Colors.white,
             hintText: "Nome......",
     
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(2),
             ),
             label:const Text("Nome.....",style:TextStyle(fontSize: 20),),
           ),
         ),
         Padding(
           padding: const EdgeInsets.only(top: 13,bottom: 13),
           child: TextField(
             controller: _controllerEmail,
             keyboardType: TextInputType.emailAddress,
             decoration: InputDecoration(
               contentPadding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
               filled: true,
               fillColor: Colors.white,
               hintText: "SeuEmail@.com......",
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(2),
               ),
               label:const Text("Email....",style:TextStyle(fontSize: 20),),
             ),
           ),
     
         ),
     
         TextField(
           controller: _controllerSenha,
           keyboardType: TextInputType.text,
           obscureText: true,
           decoration: InputDecoration(
             contentPadding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
             filled: true,
             fillColor: Colors.white,
             hintText: "Senha......",
             focusColor: Colors.black,
             hoverColor: Colors.black,
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(2),
             ),
             label:const Text("Senha....",style:TextStyle(fontSize: 20),),
           ),
         ),
         Padding(
             padding:const EdgeInsets.only(top: 10,bottom: 20),
             child: Row(
               children: <Widget>[
                 const Text("Passageiro"),
                 Switch(
                     value: _tipoUsuario,
                     onChanged: (bool valor){
                       setState(() {
                         _tipoUsuario = valor;
                       });
                     }
                 ),
                 const Text("Motorista")
               ],
             )
         ),
     
     
       ],
     );
  }

  _validarCampos(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){
       if(email.contains("@") && email.isNotEmpty){
          if(senha.length > 5  && senha.isNotEmpty){

             Usuario user = Usuario(
              email: email,
               nome: nome, 
               tipoUsuario: verificaTipoUsuario(_tipoUsuario), 
               senha: senha, 
               latitude: 0, 
               longitude: 0,

             );
          

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
  String verificaTipoUsuario(bool usuarioTipo){
     return usuarioTipo? "motorista" : "passageiro";
  }

  cadastrarUsuario(Usuario user) async{
     await user.cadastrarUsuario( context,user);
  }

  _snackBar(String erro){

    final snackBar= SnackBar(
        content: Text(erro),
       );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}