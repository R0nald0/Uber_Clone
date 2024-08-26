import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/login_module/login_controller.dart';
import 'package:uber/core/mixins/dialog_loader/dialog_loader.dart';
import 'package:uber/controller/Banco.dart';

class LoginPage extends StatefulWidget {
  final LoginController loginController;
  const LoginPage({required this.loginController, super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with DialogLoader<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();

  late ReactionDisposer errorReactionDispose;

  String erroMensagem = "";

  _validarCampos(LoginController loginController) async {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.contains("@") && email.isNotEmpty) {
      if (senha.length > 5 && senha.isNotEmpty) {
         
        await loginController.login(email, senha);
    
       
      } else {
        erroMensagem =
            "Erro ao Cadastrar Usuario! Defina uma senha com mais que 4 caracteres";
          callSnackBar(erroMensagem);
      }
    } else {
      erroMensagem = "Defina um Email válido";
      callSnackBar(erroMensagem);
    }
  }

  initReaction() {
    
    errorReactionDispose = reaction<String?>(
        (_) =>widget.loginController.errorMensage , (erro) {
              if (erro != null && erro.isNotEmpty) {
                 callSnackBar(erro);
              }
        });
  }

  logarUsuario(String email, String senha) async {
    Banco bd = Banco();
    bd.logarUsuario(email, senha, context);
  }
  @override
  void initState() {
    initReaction();
   
    super.initState();
  }

  @override
  void dispose() {
    errorReactionDispose();
     _controllerEmail.dispose();
    _controllerSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/fundo.png"), fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset(
                      "images/logo.png",
                      height: 200,
                      width: 200,
                    ),
                  ),
                  camposLoginTxtV(),
                  campoBtns(widget.loginController),
                ],
              ),
            ),
          )),
    );
  }

  camposLoginTxtV() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _controllerEmail,
            decoration: InputDecoration(
                hintText: "Email....",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16)),
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16)),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  campoBtns(LoginController loginController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[200],
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () async {
              FocusNode().requestFocus();
              showLoaderDialog();
              await _validarCampos(loginController);
              hideLoader();
            },
            child: const Text("Login"),
          ),
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Rotas.ROUTE_REGISTER);
            },
            child: const Text(
              "Nao tem conta, Cadastre-se!! ",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))
      ],
    );
  }
}
