import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/login_module/login_controller.dart';
import 'package:uber/app/module/login_module/login_page.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';
import 'package:uber/app/repository/user_repository/impl/user_repository_impl.dart';
import 'package:uber/app/services/user_service/impl/user_service_Impl.dart';
import 'package:uber/app/services/user_service/user_service.dart';

class LoginModule extends Module {
  @override
  void binds(Injector i) {
    super.binds(i);
    i.addLazySingleton<IUserRepository>(() => UserRepositoryImpl(
        auth: Modular.get<FirebaseAuth>(),
        log: Modular.get(),
        database: Modular.get()));
    i.addLazySingleton<UserService>(
        () => UserServiceImpl(userRepository: Modular.get<IUserRepository>()));
    i.addLazySingleton(() => LoginController(serviceUser: Modular.get()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.child(Modular.initialRoute,
        child: (_) => LoginPage(
              loginController: Modular.get<LoginController>(),
            ));
  }
}
