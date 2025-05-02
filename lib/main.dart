import 'package:flutter/material.dart';
import 'package:uber/app/main_widget.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

void main() async {

  await AppConfigInitialization().loadConfig();  
  runApp(const MainWidget());
  }
