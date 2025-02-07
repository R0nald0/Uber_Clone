import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:uber_clone_core/uber_clone_core.dart';
part 'home_passageiro_controller.g.dart';

class HomePassageiroController = HomePassageiroControllerBase
    with _$HomePassageiroController;

abstract class HomePassageiroControllerBase with Store {
  final IAuthService _authService;
  final IAddresService _addressService;
  final IRequistionService _requisitionSerivce;
  final IUserService _userService;
  final ILocationService _locationService;
  final MapsCameraService _mapsCameraService;
  final ITripSerivce _tripService;
  late StreamSubscription<String> streamSubscription;

  final controller = Completer<GoogleMapController>();

  HomePassageiroControllerBase({
    required IAuthService authRepository,
    required IAddresService addressRepository,
    required IRequistionService requestService,
    required IUserService userService,
    required ILocationService locattionService,
    required MapsCameraService cameraService,
    required ITripSerivce tripService,
  })  : _authService = authRepository,
        _addressService = addressRepository,
        _requisitionSerivce = requestService,
        _userService = userService,
        _locationService = locattionService,
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
      final address = await _addressService.getAddrss();
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

      final address = await _locationService.findDataLocationFromLatLong(
          camPositon.latitude, camPositon.longitude);
      await setNameMyLocal(address);
    }
  }

  Future<void> getDataUSerOn() async {
    _errorMensager = null;
    _usuario = null;

    try {
      _errorMensager = null;
      final idCurrentUser = await _authService.verifyStateUserLogged();
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
      //Todo verificar metodo
      final requisicao = await _requisitionSerivce
          .verfyActivatedRequisition(_usuario!.idUsuario!);
      //TODO melhor trazer retorno nulo quando id não encontrado
      _requisicao = requisicao;
      // initListener();
      return;
    } on RequestException catch (e) {
      _requisicao = Requisicao.empty();
      _errorMensager = e.message;
    }
  }

  Future<void> getActiveTripData(Requisicao requisicao) async {
    final latitude = requisicao.passageiro.latitude;
    final longitude = requisicao.passageiro.longitude;

    final addressPassanger =
        await _locationService.findDataLocationFromLatLong(latitude, longitude);

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
    _authService.logout();
    _usuario = null;
  }

  @action
  Future<void> getUserLocation() async {
    final actualPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final address = await _locationService.findDataLocationFromLatLong(
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
      final pathImageIcon = await _locationService.markerPositionIconCostomizer(
          "destination1", 0.0, const Size(80, 80));
      final myMarkerLocal = _locationService.createLocationMarker(
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

    final pathImageIcon = await _locationService.markerPositionIconCostomizer(
        "destination2", 200, const Size(80, 80));
    final myMarkerLocal = _locationService.createLocationMarker(
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
        final adress = await _locationService.findAddresByName(
            addresName, const String.fromEnvironment('GOOGLE_KEY'));

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
          _myAddres!, _myDestination!, Colors.black, 5, 'GOOGLE_KEY');
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

    try {
      final destinationAddress =
          await _locationService.findDataLocationFromLatLong(lat, long);

      final requisicao = Requisicao(
          id: null,
          destino: destinationAddress,
          motorista: null,
          passageiro: _usuario!,
          status: Status.AGUARDANDO,
          valorCorrida: _tripSelected!.price);

      final requestId = await _requisitionSerivce.createRequisition(requisicao);

      final userUpadated = _usuario!.copyWith(
          idRequisicaoAtiva: requestId, latitude: myLat, longitude: myLong);
      await _userService.updateUser(userUpadated);

      final requestUpdated = await _requisitionSerivce.updataDataRequisition(
          requisicao, {"idRequisicao": requestId, "passageiro": userUpadated});
      _requisicao = requestUpdated;
      _usuario = userUpadated;
    } on RequestException catch (e, s) {
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

    final isCancel = await _requisitionSerivce.cancelRequisition(_requisicao!);
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

    final pathImageIcon = await _locationService.markerPositionIconCostomizer(
        "destination2",
        200,
        const Size(
          80,
          80,
        ));

    Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_requisicao != null) {
        final userUpdated = _usuario!.copyWith(
            latitude: position.latitude, longitude: position.longitude);
        _requisitionSerivce.updataDataRequisition(
            _requisicao!, userUpdated.toMap());

        final myMarkerLocal = _locationService.createLocationMarker(
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
