import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/repository/auth_repository/repository_impl/auth_repository_impl.dart';
import 'package:uber/core/logger/app_uber_log.dart';
import 'package:uber/core/logger/impl/app_uber_log_impl.dart';

class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    i.addLazySingleton(() => FirebaseAuth.instance);
    i.addLazySingleton(() => FirebaseFirestore.instance);
    i.addLazySingleton<IAppUberLog>(AppUberLogImpl.new);

    i.addLazySingleton<IAuthRepository>(AuthRepositoryImpl.new);

    i.addLazySingleton(AuthenticationController.new);
  }
}
