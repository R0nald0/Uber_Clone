import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';
import 'package:uber/app/services/user_service/user_service.dart';

class UserServiceImpl implements UserService {
  final IUserRepository _userRepository;

  UserServiceImpl({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Usuario> getDataUserOn(String idUser) =>
      _userRepository.getDataUserOn(idUser);

  @override
  Future<void> saveUserOnDatabase(String name, String idUsuario, String email,
          String password, String tipoUsuario) =>
      _userRepository.saveUserOnDatabase( name, idUsuario, email, password, tipoUsuario);
}
