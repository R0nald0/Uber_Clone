import 'dart:async';

import 'package:flutter/foundation.dart';
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
import 'package:uber/app/repository/addres_reposiory/address_repository_impl.dart';
import 'package:uber/app/repository/auth_repository/I_auth_repository.dart';
import 'package:uber/app/repository/mapsCameraRepository/maps_camera_repository.dart';
import 'package:uber/app/services/location_service/location_service_impl.dart';
import 'package:uber/app/services/trip_service/trip_service.dart';
import 'package:uber/app/services/user_service/user_service.dart';
import 'package:uber/app/util/Status.dart';
import 'package:uber/core/exceptions/addres_exception.dart';
import 'package:uber/core/exceptions/requisicao_exception.dart';
import 'package:uber/core/exceptions/user_exception.dart';

part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase
    with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthRepository _authRepository;
  final AddressRepositoryImpl _addressRepository;
  final UserService _userService;
  final LocationServiceImpl _locationServiceImpl;
  final MapsCameraService _mapsCameraService;
  final TripService _tripService;
  late StreamSubscription<String> streamSubscription;

  final controller = Completer<GoogleMapController>();

  HomePassageiroControllerBase({
    required IAuthRepository authRepository,
    required AddressRepositoryImpl addressRepository,
    required UserService userService,
    required LocationServiceImpl locattionService,
    required MapsCameraService cameraService,
    required TripService tripService,
  })  : _authRepository = authRepository,
        _addressRepository = addressRepository,
        _userService = userService,
        _locationServiceImpl = locattionService,
        _mapsCameraService = cameraService,
        _tripService = tripService;

  @readonly
  String _statusTrip = '';

  @readonly
  var _addresList = <Address>[];

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
  Address? _myAddres;

  @readonly
  Address? _myDestination;

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
  Future<void> getUserAddress() async {
    _errorMensager = null;
    try {
      final address = await _addressRepository.getAddrss();
      _addresList = [...address];
    } on AddresException catch (e) {
      if (_errorMensager != null) {
        _errorMensager = e.message;
      }
      _errorMensager = null;
      _addresList = <Address>[];
    }
  }

  @action
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

      final address = await _locationServiceImpl.findDataLocationFromLatLong(
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
    _errorMensager = null;
    if (_usuario == null || _usuario?.idUsuario == null) {
      _errorMensager = "Usuario inválido";
      logout();
      return;
    }

    final requisicao =
        await _tripService.verfyActivatedRequisition(_usuario!.idUsuario!);
    if (requisicao != null) {
      _requisicao = requisicao;

      // initListener();
    } else {
      _requisicao = Requisicao.empty();
      _errorMensager = "Nenhuma viagem ativa";
    }
  }

  Future<void> getActiveTripData(Requisicao requisicao) async {
    final latitude = requisicao.passageiro.latitude;
    final longitude = requisicao.passageiro.longitude;

    final addressPassanger = await _locationServiceImpl.findDataLocationFromLatLong(latitude, longitude);
    
    await setNameMyLocal(addressPassanger);
    await setDestinationLocal(requisicao.destino);
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

    final address = await _locationServiceImpl.findDataLocationFromLatLong(
        actualPosition.latitude, actualPosition.longitude);
    await setNameMyLocal(address);
  }

  @action
  Future<void> setNameMyLocal(Address addres) async {
    _myAddres = null;
    _myAddres = addres;

    _cameraPosition = CameraPosition(
      target: LatLng(addres.latitude, addres.longitude),
      zoom: 16,
    );

    if (_usuario != null) {
      final pathImageIcon = await _locationServiceImpl
          .markerPositionIconCostomizer("destination1", 0.0);
      final myMarkerLocal = _locationServiceImpl.createLocationMarker(
          addres.latitude,
          addres.longitude,
          pathImageIcon,
          "my_local",
          'meu local',
          10);
      _markers.add(myMarkerLocal);
      showAllPositionsAndTraceRouter();
    }
  }

  @action
  Future<void> setDestinationLocal(Address addres) async {
    _myDestination = null;
    _myDestination = addres;

    _cameraPosition = CameraPosition(
      target: LatLng(addres.latitude, addres.longitude),
      zoom: 16,
    );

    final pathImageIcon = await _locationServiceImpl
        .markerPositionIconCostomizer("destination2", 200);
    final myMarkerLocal = _locationServiceImpl.createLocationMarker(
        addres.latitude,
        addres.longitude,
        pathImageIcon,
        "my_local_destination",
        'Meu destino',
        90);
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
  Future<List<Address>> findAddresByName(String addresName) async {
    try {
      _errorMensager = null;

      if (addresName.isNotEmpty) {
        final adress = await _locationServiceImpl.findAddresByName(addresName);

        return adress;
      }
      return <Address>[];
    } on AddresException catch (e) {
      _errorMensager = e.message;
      return <Address>[];
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
      _configureTripList(polylinesData);
    }
  }

  void _configureTripList(PolylineData data) {
    if (_polynesRouter.isNotEmpty) {
      final trips = _tripService.configureTripList(data);
      _trips = trips;
    }
  }

  @action
  Future<void> selectedTrip(Trip trip) async {
    _tripSelected = trip;
  }

  @action
  Future<void> createRequisitionToRide() async {
    _errorMensager = null;
    if (_tripSelected == null ||
        _myAddres == null ||
        _myDestination == null ||
        _usuario == null) {
      _errorMensager = "escolha os dados para sua viagem";
      return;
    }

    final myLat = _myAddres!.latitude;
    final myLong = _myAddres!.longitude;

    final lat = _myDestination!.latitude;
    final long = _myDestination!.longitude;

    final userUpadated = _usuario!.copyWith(latitude: myLat, longitude: myLong);

    try {
      final destinationAddress =
          await _locationServiceImpl.findDataLocationFromLatLong(lat, long);

      final requisicao = Requisicao(
          id: null,
          destino: destinationAddress,
          motorista: null,
          passageiro: userUpadated,
          status: Status.AGUARDANDO,
          valorCorrida: _tripSelected!.price);

      final onRequition =
          await _tripService.createRequisitionToRide(requisicao);
      if (onRequition != null) {
        _requisicao = onRequition;
      } else {
        _requisicao = null;
      }
    } on RequisicaoException catch (e, s) {
      _errorMensager = e.message;
      if (kDebugMode) {
        print(s);
        print(e);
      }
    } on AddresException catch (e, s) {
      _errorMensager = e.message;
      if (kDebugMode) {
        print(s);
        print(e);
      }
    }
  }

  @action
  Future<void> cancelarUber() async {
    if (_requisicao == null) {
      return;
    }

    final isCancel = await _tripService.cancelRequisition(_requisicao!);
    if (isCancel) {
      _requisicao = null;
    }

    streamSubscription.cancel();
  }

  // @action
  // Future<void> initListener() async{
  //    if (_requisicao == null) {
  //      streamSubscription.cancel();
  //          return;
  //      }
  //    streamSubscription = _tripService.listenerRequisicao(_requisicao!.id!)
  //      .listen((snapshot) {
  //          print("STATU REQUISIÇAO $snapshot");
  //          _statusTrip = snapshot;
  //      });
  // }

  void updatePositionUser() async {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 5);

    final pathImageIcon = await _locationServiceImpl
        .markerPositionIconCostomizer("destination2", 200);

    Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_requisicao != null) {
        final userUpdated = _usuario!.copyWith(
            latitude: position.latitude, longitude: position.longitude);
        _tripService.updataDataRequisition(
            _requisicao!.id!, 'passageiro', userUpdated);

        final myMarkerLocal = _locationServiceImpl.createLocationMarker(
            position.latitude,
            position.longitude,
            pathImageIcon,
            "my_local",
            'meu local',
            10);
        _markers.add(myMarkerLocal);
      }
    });
  }

  void dispose() {
    streamSubscription.cancel();
  }
}
