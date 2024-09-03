import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/execptions/user_exception.dart';
part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthRepository _authRepository;
  final UserService _userService;
  
  HomePassageiroControllerBase({required IAuthRepository authRepository,required UserService userService})
   :_authRepository =authRepository,
     _userService = userService
   ;
  
  @readonly
  String? _errorMensager;
  
  @readonly
  Usuario? _usuario;

  Future<void> getDataUSerOn()async{
      try {
        _errorMensager = null;
       final  idCurrentUser = _authRepository. getIdCurrenteUserUser();
        if (idCurrentUser != null) {
          _usuario  = await _userService.getDataUserOn(idCurrentUser);
        }else{
           _errorMensager = "Usuario não encontrado";
           logout();
        }
      } on UserException catch (e) {
          _errorMensager = e.message;
          logout();
      }
  }

  Future<void> logout() async{
    _authRepository.logout();
    _usuario = null;
    Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_)=> false);
  }
}