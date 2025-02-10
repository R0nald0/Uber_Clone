import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

class SplashScreen extends StatefulWidget {
  final AuthenticationController _auth;

  const SplashScreen({super.key, required AuthenticationController auth})
      : _auth = auth;
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with DialogLoader {
  final reactionDisposer = <ReactionDisposer>[];

  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_)  {
       initReactions();
    });

  }

  Future<void> initReactions() async {
    final reactionDisposerAuth = reaction<String?>((_) => widget._auth.errorMessage, (erro) {
      if (erro != null) {
        callSnackBar(erro);
        Navigator.pushNamedAndRemoveUntil(
            context, Rotas.ROUTE_LOGIN, (_) => false);
      }
    });
    final reactionUserId = reaction<String?>((_) => widget._auth.idUser, (id){
        if (  id !=null && id.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(Rotas.ROUTE_VIEWPASSAGEIRO, (_) => false,);
      }else{
         Navigator.of(context).pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_) => false);
      }
    });

    widget._auth.verifyStateUserLogged();

    reactionDisposer.addAll([reactionUserId, reactionDisposerAuth]);
  }

  @override
  void dispose() {
    for (var reactioon in reactionDisposer) {
      reactioon();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(60),
        decoration: const BoxDecoration(
          color: Colors.black87,
        ),
        child:  const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 70,
            children: <Widget>[
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("images/logo.png"),
              ),
              LinearProgressIndicator(
                color: Colors.blue,
                minHeight: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
