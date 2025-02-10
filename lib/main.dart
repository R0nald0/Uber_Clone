import 'package:flutter/material.dart';
import 'package:uber/app/main_widget.dart';
import 'package:uber/app/module/core/app_config_initialization.dart';

void main() async {
  await AppConfigInitialization().loadConfig();
  runApp(const MainWidget());}
