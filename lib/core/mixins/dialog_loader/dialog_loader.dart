import 'package:flutter/material.dart';

mixin DialogLoader <e extends StatefulWidget> on State<e> {
  

  void showLoaderDialog(){
     showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (contextDialog){
          return const Center(
             child: CircularProgressIndicator(),
          );
      }
      );
  }

  void hideLoader(){
    Navigator.pop(context);
  }


 void callSnackBar(String erro) {
    final snackBar = SnackBar(content: Text(erro));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}