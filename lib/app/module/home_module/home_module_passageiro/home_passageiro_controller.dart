import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/model/polyline_data.dart';
import 'package:uber/app/model/trip.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/repository/mapsCameraRepository/maps_camera_repository.dart';
import 'package:uber/app/services/location_service/location_service_impl.dart';
import 'package:uber/app/services/trip_service/trip_service.dart';
import 'package:uber/app/services/user_service/requisicao_service/I_requisicao_service.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/core/exceptions/addres_exception.dart';
import 'package:uber/core/exceptions/requisicao_exception.dart';
import 'package:uber/core/exceptions/user_exception.dart';

part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase
    with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthRepository _authRepository;
  final UserService _userService;
  final IRequisicaoService _requisicaoService;
  final LocationServiceImpl _locationServiceImpl;
  final MapsCameraService _mapsCameraService;
  final TripService _tripService;

  final controller = Completer<GoogleMapController>();

  HomePassageiroControllerBase({
    required IAuthRepository authRepository,
    required UserService userService,
    required IRequisicaoService requisicaoService,
    required LocationServiceImpl locattionService,
    required MapsCameraService cameraService,
    required TripService tripService,
  })  : _authRepository = authRepository,
        _userService = userService,
        _requisicaoService = requisicaoService,
        _locationServiceImpl = locattionService,
        _mapsCameraService = cameraService,
        _tripService = tripService;

  @readonly
  var _trips = <Trip>[];

  @readonly
  Trip? _tripSelected;

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

  @readonly
  Addres? _myAddres;

  @readonly
  Addres? _myDestination;

  @computed
  bool get isAddressNotNullOrEmpty {
       if (_myAddres != null && _myDestination != null) {
       if (_myAddres!.nomeDestino.isNotEmpty &&
          _myDestination!.nomeDestino.isNotEmpty) {
        return true; 
      }
    }
     return false;
  }

  @readonly
  var _markers = <Marker>{};

  @readonly
  var _polynesRouter = <Polyline>{};

  Future<void> getCameraUserLocationPosition() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _locationPermission = permission;

    final camPositon = await Geolocator.getLastKnownPosition();
    if (camPositon != null) {
      _cameraPosition = CameraPosition(
        target: LatLng(camPositon.latitude, camPositon.longitude),
        zoom: 16,
      );

      final address = await _locationServiceImpl.setNameMyLocal(
          camPositon.latitude, camPositon.longitude);
      await setNameMyLocal(address);
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

  @action
  Future<void> getUserLocation() async {
    final actualPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final address = await _locationServiceImpl.setNameMyLocal(
        actualPosition.latitude, actualPosition.longitude);
    await setNameMyLocal(address);
  }

  @action
  Future<void> setNameMyLocal(Addres addres) async {
    _myAddres = null;
    _myAddres = addres;

    _cameraPosition = CameraPosition(
      target: LatLng(addres.latitude, addres.longitude),
      zoom: 16,
    );

    if (_usuario != null) {
      final pathImageIcon = await _locationServiceImpl.markerPositionIconCostomizer("destination1", 0.0);
      final myMarkerLocal =
         _locationServiceImpl.createLocationMarker(addres, pathImageIcon, "my_local", 'meu local', 10);
      _markers.add(myMarkerLocal);
      showAllPositionsAndTraceRouter();
    }
  }

  @action
  Future<void> setDestinationLocal(Addres addres) async {
    _myDestination = null;
    _myDestination = addres;

    _cameraPosition = CameraPosition(
      target: LatLng(addres.latitude, addres.longitude),
      zoom: 16,
    );

    final pathImageIcon = await _locationServiceImpl.markerPositionIconCostomizer("destination2", 200);
    final myMarkerLocal = _locationServiceImpl.createLocationMarker(
        addres, pathImageIcon, "my_local_destination", 'Meu destino', 90);
    _markers.add(myMarkerLocal);
    showAllPositionsAndTraceRouter();
  }

  @action
  Future<void> showAllPositionsAndTraceRouter() async {
    if (isAddressNotNullOrEmpty) {
          _mapsCameraService.moverCameraBound(
            _myAddres!, _myDestination!, 60, controller);
          await traceRouter();
      
    } else {
      if (_cameraPosition != null) {
        _mapsCameraService.moveCamera(_cameraPosition!, controller);
      }
    }
  }

  @action
  Future<List<Addres>> findAddresByName(String addresName) async {
    try {
      if (addresName.isNotEmpty) {
        return await _locationServiceImpl.findAddresByName(addresName);
      }
      return <Addres>[];
    } on AddresException catch (e) {
      _errorMensager = e.message;
      return <Addres>[];
    }
  }
  

  @action
  Future<void> traceRouter() async {
    _polynesRouter = <Polyline>{};
    if (isAddressNotNullOrEmpty) {
        final polylinesData = await _tripService.getRoute(
            _myAddres!, _myDestination!, Colors.black, 5);
        final linesCordenates = Set<Polyline>.of(polylinesData.router.values);
        _polynesRouter = linesCordenates;
        _configireTripList(polylinesData);
    }
  }
  


  void _configireTripList(PolylineData data) {
    if (_polynesRouter.isNotEmpty) {
      final trips = _tripService.configireTripList(data);
      _trips = trips;
    }
  }

  @action
  Future<void> selectedTrip(Trip trip) async {
    _tripSelected = trip;
  }
}
