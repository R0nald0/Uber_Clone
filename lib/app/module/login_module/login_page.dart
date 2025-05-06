import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/login_module/login_controller.dart';
import 'package:uber/core/mixins/dialog_loader/dialog_loader.dart';
import 'package:uber/core/widgets/uber_text_fields/uber_text_field_widget.dart';
import 'package:validatorless/validatorless.dart';

class LoginPage extends StatefulWidget {
  final LoginController loginController;
  const LoginPage({required this.loginController, super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with DialogLoader<LoginPage> {
  final _controllerEmail = TextEditingController();
  final _controllerSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late ReactionDisposer errorReactionDispose;

  String erroMensagem = "";

  initReaction() {
    errorReactionDispose =
        reaction<String?>((_) => widget.loginController.errorMensage, (erro) {
      if (erro != null && erro.isNotEmpty) {
        callSnackBar(erro);
      }
    });
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
                   const CircleAvatar(
                    radius: 120,
                    backgroundColor: null,
                    backgroundImage: AssetImage('images/logo.png'),
                  ),
                 
                  camposLoginTxtV(_formKey),
                  campoBtns(widget.loginController, _formKey),
                ],
              ),
            ),
          )),
    );
  }

  camposLoginTxtV(GlobalKey<FormState> formState) {
    return Form(
      key: formState,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: UberTextFieldWidget(
              controller: _controllerEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              hintText: 'Email...',
              validator: Validatorless.multiple([
                Validatorless.required("Campo requerido"),
                Validatorless.email('E-mail inválido')
                ,
              ]),
            ),
          ),
          UberTextFieldWidget(
            controller: _controllerSenha,
            obscureText: true,
            prefixIcon: const Icon(Icons.key),
            hintText: 'Senha...',
            validator: Validatorless.multiple([
              Validatorless.required("Campo requerido"),
              Validatorless.min(5, 'Senha deve conter no mínimo 5 caracteres'),
            ]),
          ),
        ],
      ),
    );
  }

  campoBtns(LoginController loginController, GlobalKey<FormState> formState) {
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
              final isValid = formState.currentState?.validate() ?? false;
              if (isValid) {
                 final email = _controllerEmail.text;
                 final ssenha = _controllerSenha.text;
                 await loginController.login(email,ssenha );
              }
              hideLoader();
            },
            child: const Text("Login"),
          ),
        ),
        TextButton(
            onPressed: () {
              Modular.to.pushNamed(Rotas.ROUTE_REGISTER,);
            },
            child: const Text(
              "Nao tem conta, Cadastre-se!! ",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))
      ],
    );
  }
}
