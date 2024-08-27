import 'package:mobx/mobx.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthRepository _authRepository;
  
  HomePassageiroControllerBase({required IAuthRepository authRepository})
   :_authRepository =authRepository;


  Future<void> logout() async{
    _authRepository.logout();
  }
}