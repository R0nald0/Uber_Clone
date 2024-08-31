import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/core/mixins/dialog_loader/dialog_loader.dart';

class SplashScreen extends StatefulWidget {
  final AuthenticationController _auth;

  const SplashScreen(
      {super.key, required AuthenticationController authController})
      : _auth = authController;

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with DialogLoader {
  late ReactionDisposer reactionDisposerAuth;
  late ReactionDisposer reactionDisposerUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initReactions(); 
    });

  }

  void initReactions() async {
      widget._auth.verifyStateUserLogged();
   reactionDisposerUser  =  reaction<Usuario?>((_) => widget._auth.usuario, (us) {
      if (us != null && us.idUsuario!.isNotEmpty) {
         Navigator.pushNamedAndRemoveUntil(
                context, Rotas.ROUTE_VIEWPASSAGEIRO, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, Rotas.ROUTE_LOGIN, (route) => false);
      }
    });
    
    
  reactionDisposerAuth  =reaction<String?>((_)=>widget._auth.errorMessage, (erro){
         if (erro !=null) {
            callSnackBar(erro);
         }
    }); 
  }

  @override
  void dispose() {
    reactionDisposerAuth();
    reactionDisposerUser();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(60),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/fundo.png"), fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 50),
                  child: Image.asset("images/logo.png"),
                ),
                const LinearProgressIndicator(
                  color: Colors.blue,
                  minHeight: 2,
                ),
              ],
            ),
          )),
    );
  }


}
