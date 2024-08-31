
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';
import 'package:uber/app/services/user_service/user_service.dart';

class UserServiceImpl implements UserService{
   final IUserRepository _userRepository;

   UserServiceImpl({required IUserRepository userRepository})
   :_userRepository = userRepository;   
 
  @override
  Future<User?> logar(String email, String password) => _userRepository.logar(email, password);
  
  @override
  Future<User?> register(String name, String email, String password ,String tipoUsuario) 
  => _userRepository.register(name, email, password,tipoUsuario);
  
}