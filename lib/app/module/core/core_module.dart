import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/core/authentication_controller.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/repository/auth_repository/repository_impl/auth_repository_impl.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';

import 'package:uber/app/repository/user_repository/impl/user_repository_impl.dart';
import 'package:uber/app/services/user_service/impl/user_service_Impl.dart';
import 'package:uber/app/services/user_service/user_service.dart';

import 'package:uber/core/local_storage/impl/local_storage_impl.dart';
import 'package:uber/core/local_storage/local_storage.dart';
import 'package:uber/core/logger/app_uber_log.dart';


import 'package:uber/core/logger/impl/app_uber_log_impl.dart';
import 'package:uber/core/offline_database/database_off_line.dart';
import 'package:uber/core/offline_database/impl/database_impl.dart';
import 'package:uber/core/offline_database/sql_connection.dart';


class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
      
    i.addLazySingleton<LocalStorage>(LocalStorageImpl.new);
    i.addLazySingleton(SqlConnection.new);
    i.addLazySingleton<DatabaseOffLine>(DatabaseImpl.new);
    i.addLazySingleton<IAppUberLog>(AppUberLogImpl.new);

    i.addLazySingleton<IAuthRepository>(AuthRepositoryImpl.new);
    i.addLazySingleton<IUserRepository>(UserRepositoryImpl.new);
    i.addLazySingleton<UserService>(UserServiceImpl.new);
   
    i.addLazySingleton(AuthenticationController.new);
      
  }
}
