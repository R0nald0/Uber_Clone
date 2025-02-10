// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginController on LoginControllerBase, Store {
  late final _$_errorMensageAtom =
      Atom(name: 'LoginControllerBase._errorMensage', context: context);

  String? get errorMensage {
    _$_errorMensageAtom.reportRead();
    return super._errorMensage;
  }

  @override
  String? get _errorMensage => errorMensage;

  @override
  set _errorMensage(String? value) {
    _$_errorMensageAtom.reportWrite(value, super._errorMensage, () {
      super._errorMensage = value;
    });
  }

  late final _$_hasSuccessLoginAtom =
      Atom(name: 'LoginControllerBase._hasSuccessLogin', context: context);

  bool? get hasSuccessLogin {
    _$_hasSuccessLoginAtom.reportRead();
    return super._hasSuccessLogin;
  }

  @override
  bool? get _hasSuccessLogin => hasSuccessLogin;

  @override
  set _hasSuccessLogin(bool? value) {
    _$_hasSuccessLoginAtom.reportWrite(value, super._hasSuccessLogin, () {
      super._hasSuccessLogin = value;
    });
  }

  late final _$loginAsyncAction =
      AsyncAction('LoginControllerBase.login', context: context);

  @override
  Future<void> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
