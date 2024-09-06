import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/services/user_service/requisicao_service/I_requisicao_service.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/execptions/requisicao_exception.dart';
import 'package:uber/core/execptions/user_exception.dart';

part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase
    with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthRepository _authRepository;
  final UserService _userService;
  final IRequisicaoService _requisicaoService;
  final Completer<GoogleMapController> controller = Completer();

  HomePassageiroControllerBase(
      {required IAuthRepository authRepository,
      required UserService userService,
      required IRequisicaoService requisicaoService})
      : _authRepository = authRepository,
        _userService = userService,
        _requisicaoService = requisicaoService;

  @readonly
  String? _errorMensager;

  @readonly
  Usuario? _usuario;

  @readonly
  Requisicao? _requisicao;

  @readonly
  LocationPermission? _locationPermission;
  @readonly
  bool _isServiceEnable = false;

  @readonly
  CameraPosition? _cameraPosition;

  Future<void> getCameraPosition() async {
    if (_locationPermission != LocationPermission.denied &&
        _locationPermission != LocationPermission.deniedForever) {
      final camPositon = await Geolocator.getLastKnownPosition();
      if (camPositon != null) {
        _cameraPosition = CameraPosition(
          target: LatLng(camPositon.latitude, camPositon.longitude),
          zoom: 16,
        );
        _moverCamera();
      }
    }
  }

  Future<void> getDataUSerOn() async {
    try {
      _errorMensager = null;
      final idCurrentUser = _authRepository.getIdCurrenteUserUser();
      if (idCurrentUser != null) {
        _usuario = await _userService.getDataUserOn(idCurrentUser);
      } else {
        _errorMensager = "Usuario não encontrado";
        logout();
      }
    } on UserException catch (e) {
      _errorMensager = e.message;
      logout();
    }
  }

  Future<void> verfyActivatedRequisition() async {
    try {
      _errorMensager = null;
      if (_usuario == null || _usuario?.idUsuario == null) {
        _errorMensager = "Usuario inválido";
        logout();
        return;
      }
      final requisicao = await _requisicaoService
          .verfyActivatedRequisition(_usuario!.idUsuario!);
      if (requisicao != null) {
        _requisicao = requisicao;
      } else {
        _requisicao = Requisicao.empty();
      }
    } on RequisicaoException catch (e) {
      _errorMensager = e.message;
      _requisicao = Requisicao.empty();
    }
  }

  Future<void> getPermissionLocation() async {
    _locationPermission = null;

    final isServiceEnable = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnable) {
      _isServiceEnable = isServiceEnable;
      return;
    }

    _isServiceEnable = isServiceEnable;

    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        _locationPermission = await Geolocator.requestPermission();
        return;
      case LocationPermission.deniedForever:
        _locationPermission = LocationPermission.deniedForever;
        return;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        _locationPermission = permission;
        getUserLocation();
    }
  }

  Future<void> logout() async {
    _authRepository.logout();
    _usuario = null;
    Modular.to.pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_) => false);
  }

  Future<void> getUserLocation() async {
    final actualPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _cameraPosition = CameraPosition(
      target: LatLng(actualPosition.latitude, actualPosition.longitude),
      zoom: 16,
    );

    _moverCamera();
  }

  _moverCamera() async {
    if (_cameraPosition != null) {
      GoogleMapController controllerCamera = await controller.future;
      controllerCamera
          .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
    }

    Future<void> _getLastPosition() async {
      LocationSettings locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10);

      StreamSubscription<Position> positions =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        if (position != null) {
          _cameraPosition = CameraPosition(
              target: LatLng(position.latitude, position.longitude), zoom: 19);
          //  _meuLocal(position.latitude, position.longitude);
          // _localPassageiros = position;
          //   _addMarcador(position, "passageiro", "Meu local");

          //   _moverCamera(positionCan);
        } else {
          Geolocator.requestPermission();
        }
      });
    }
  }

  /* _moverCameraBound(LatLngBounds latLngBounds) async {
    GoogleMapController controllerBouds = await controller.future;
    controllerBouds
        .animateCamera(CameraUpdate.newLatLngBounds(_cameraPosition., 100));
  } */
}
