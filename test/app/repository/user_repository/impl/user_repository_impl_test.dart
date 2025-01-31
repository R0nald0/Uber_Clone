
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uber/app/repository/user_repository/i_user_repository.dart';
import 'package:uber/app/repository/user_repository/impl/user_repository_impl.dart';
import 'package:uber/core/local_storage/local_storage.dart';
import 'package:uber/core/logger/app_uber_log.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppUberLog extends Mock implements IAppUberLog {}


void main() {
  late IUserRepository userRepositoryImpl;
  late MockLocalStorage localStorageMock ;
  late MockAppUberLog logMock ;
  //final fireStoreMock = MockLocalfireStore();
 // final flutterGetItBindingMock = MockLocalFlutterGetItBinding();
   
 setUp(() async => {
   WidgetsFlutterBinding.ensureInitialized(),
       localStorageMock = MockLocalStorage(),
       logMock = MockAppUberLog(),
      await Firebase.initializeApp(),
      userRepositoryImpl =
        UserRepositoryImpl(
          localStoreage: localStorageMock, 
          log: logMock
          )
  });

  test('getDataUserOn', () async {                        

    when(() => localStorageMock.containsKey('a')).thenAnswer((_) async => true);

    final resposnse = await userRepositoryImpl.getDataUserOn('a');

    verify(() => localStorageMock.containsKey('a')).called(1);
  });
}