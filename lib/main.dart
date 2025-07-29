import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:uber/app/main_widget.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

void main() async {

  await AppConfigInitialization().loadConfig(); 
  const pubKey = String.fromEnvironment("PUBLISHED_KEY");
  Stripe.publishableKey = pubKey;  
  runApp(const MainWidget());
  }
