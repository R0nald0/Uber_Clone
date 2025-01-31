import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/core/offline_database/uber_clone_life_cycle.dart';

  final ThemeData temaPadrao = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff37474f)
    )
  );

final ThemeData temaIos = ThemeData(
      colorScheme:ColorScheme.fromSwatch());    


class MainWidget extends StatefulWidget {
  const MainWidget({ super.key });
  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
   final  observerLifeCycle = UberCloneLifeCycle(); 

   @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(observerLifeCycle);
  }

 @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(observerLifeCycle);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute(Rotas.ROUTE_SPLASHSCREEN);

    return MaterialApp.router(
      title: 'Uber',
      theme: Platform.isIOS == true? temaIos :temaPadrao,
      routerConfig: Modular.routerConfig,
    );
  }
}