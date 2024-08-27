import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/register_module/register_controller.dart';
import 'package:uber/app/module/register_module/register_page.dart';
import 'package:uber/app/repository/user_repository/impl/user_repository_impl.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';
import 'package:uber/app/services/user_service/impl/user_service_Impl.dart';
import 'package:uber/app/services/user_service/user_service.dart';

class RegisterModule extends Module {

   @override
  void binds(Injector i) {
    super.binds(i);
    i.addLazySingleton<IUserRepository>(()=>
      UserRepositoryImpl(auth: Modular.get(),log: Modular.get())
    );
    i.addLazySingleton<UserService>(()=>
      UserServiceImpl(userRepository: Modular.get())
    );
    i.addLazySingleton(()=>
      RegisterController(userService: Modular.get())
    );
    
  }

   @override
  void routes(RouteManager r) {
  
    super.routes(r);
    r.child(Modular.initialRoute, child: (_) => const RegisterPage(),transition: TransitionType.rightToLeft);
   
  }
}