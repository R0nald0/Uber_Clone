import 'package:animated_text_kit/animated_text_kit.dart';
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
   String routeTo ='';
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
        Navigator.of(context).pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_) => false);
           routeTo = Rotas.ROUTE_LOGIN;
      }
    });
    final reactionUserId = reaction<String?>((_) => widget._auth.idUser, (id){
        if (  id !=null && id.isNotEmpty) {
        routeTo = Rotas.ROUTE_VIEWPASSAGEIRO;
      }else{
         routeTo = Rotas.ROUTE_LOGIN;
      }
    });

    await widget._auth.verifyStateUserLogged();

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
        child: Stack(
          alignment: Alignment.center,
          children: [
               Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: <Widget>[
            const CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage(UberCloneConstants.ASSEESTS_IMAGE_LOGO),
            ),
            SizedBox(
              height: 20,
              child: DefaultTextStyle(
                style:const TextStyle(
                  fontSize: 20,
                  color:Colors.white,
                  fontFamily:'Courgette',
                ) , 
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                   animatedTexts:  [
                    TypewriterAnimatedText('Clone..',
                    cursor: ".",
                    speed: const Duration(milliseconds: 300 ),
                    ),
                   ], 
                  onFinished: (){
                    if (routeTo.isNotEmpty) {
                       Navigator.of(context).pushNamedAndRemoveUntil(routeTo, (_) => false,);
                    }
                  },
                  )
                ),
            ),
            
          ],
        ),
        const Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
                minHeight: 2,
              ),
            ),
          ],
        )
      ),
    );
  }
}
