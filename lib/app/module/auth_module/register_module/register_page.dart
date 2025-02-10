import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/auth_module/register_module/register_controller.dart';
import 'package:uber_clone_core/uber_clone_core.dart';
import 'package:validatorless/validatorless.dart';

class RegisterPage extends StatefulWidget{
  final RegisterController registerController;
  const RegisterPage({super.key, required this.registerController});

  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> with DialogLoader{
 final _controllerEmail = TextEditingController();
 final _controllerNome  =  TextEditingController();
 final _controllerSenha =  TextEditingController();
 final _formKey = GlobalKey<FormState>();

 
final reactions = <ReactionDisposer>[];

  @override
  void initState() {
     
     initReaction();
    super.initState();
  }

  initReaction(){
     final errorReactionDispose =
        reaction<String?>((_) => widget.registerController.errorMessange, (erro) {
      if (erro != null && erro.isNotEmpty) {
        callSnackBar(erro);
      }
    });

    final reactionSuccesRegister = reaction((_)=>widget.registerController.hasSuccesRegister, (success){
         if (success! && success) {
           Navigator.of(context).pushNamedAndRemoveUntil(Rotas.ROUTE_VIEWPASSAGEIRO,(_) =>false);
         } 
    });

    reactions.addAll([reactionSuccesRegister,errorReactionDispose]);
  }

  @override
  void dispose() {
     for (var rection in reactions) {
        rection();
     }
    _controllerEmail.dispose();
    _controllerNome.dispose();
    _controllerSenha.dispose();
    super.dispose();
  }

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
                  _camposCadastro(_formKey),

                 const SizedBox(height: 20),

                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue[200],
                     padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                     textStyle: const TextStyle(fontSize: 18,),
                     shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     elevation: 1
                   ),
                     onPressed: () async{
                         FocusNode().unfocus();
                        showLoaderDialog();
                         final isValid = _formKey.currentState?.validate() ?? false; 
                         if (isValid) {
                             final name = _controllerNome.text;
                             final email = _controllerEmail.text;
                             final password = _controllerSenha.text;  
                             await  widget.registerController.register(name, email, password);
                             //_validarCampos();
                         }
                         hideLoader(); 
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
  _camposCadastro(GlobalKey<FormState> formKey){
     return Form(
      key:formKey ,
       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
         children:<Widget> [
           UberTextFieldWidget(
            controller: _controllerNome,
            inputType: TextInputType.name,
            label:"Nome......" ,
            prefixIcon: const Icon(Icons.person),
            validator: Validatorless.multiple([
              Validatorless.required('Nome requerido'),
              Validatorless.min(6, "seu nome precisar ter pelo menos 6 letras")
            ]),
            ),
       
           Padding(
             padding: const EdgeInsets.only(top: 13,bottom: 13),
             child: UberTextFieldWidget(
            controller: _controllerEmail,
            inputType: TextInputType.emailAddress,
            label:"Email......" ,
            hintText: "SeuEmail@.com......",
            prefixIcon: const Icon(Icons.email),
            validator: Validatorless.multiple([
              Validatorless.required("Email requerido"),
              Validatorless.email("Defina um Email válido")
            ]),
            ),
       
           ),
       
            UberTextFieldWidget(
            controller: _controllerSenha,
            inputType: TextInputType.text,
            label:"Senha" ,
            obscureText: true,
            prefixIcon: const Icon(Icons.key),
            validator: Validatorless.multiple([
              Validatorless.required("Email requerido"),
              Validatorless.min(5, "Defina uma senha com mais que 5 caracteres")
            ]),
            ),
           
          //  Padding(
          //      padding:const EdgeInsets.only(top: 10,bottom: 20),
          //      child: Row(
          //        children: <Widget>[
          //          const Text("Passageiro"),
          //          Switch(
          //              value: _tipoUsuario,
          //              onChanged: (bool valor){
          //                setState(() {
          //                  _tipoUsuario = valor;
          //                });
          //              }
          //          ),
          //          const Text("Motorista")
          //        ],
          //      )
          //  ),
       
         
         ],
       ),
     );
  }

}