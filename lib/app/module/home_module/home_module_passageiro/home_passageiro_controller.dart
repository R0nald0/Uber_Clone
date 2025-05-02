import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
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
  final INotificationService _notificationService;
  final FirebaseNotfication _firebaseNotificationService;

  late StreamSubscription<String> streamSubscription;
  late StreamSubscription<UberMessanger> notificatioSubscription;
  late StreamSubscription<String> tokenSubscription;

  final controller = Completer<GoogleMapController>();

  HomePassageiroControllerBase({
    required INotificationService notificationService,
    required IAuthService authService,
    required IAddresService addressService,
    required IRequistionService requestService,
    required IUserService userService,
    required ILocationService locattionService,
    required MapsCameraService cameraService,
    required ITripSerivce tripService,
    required FirebaseNotfication firebaseNotificationService,
  })  : _authService = authService,
        _addressService = addressService,
        _requisitionSerivce = requestService,
        _userService = userService,
        _locationService = locattionService,
        _mapsCameraService = cameraService,
        _tripService = tripService,
        _notificationService = notificationService,
        _firebaseNotificationService =firebaseNotificationService;
        

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

  @readonly
  String? _textoBotaoPadrao;

  @readonly
  Function? _functionPadrao;

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

  @readonly
  bool? _exibirCaixasDeRotas;
  @readonly
  String _statusRequisicao = Status.NAO_CHAMADO;

  @action
  Future<void> _getUserAddress() async {
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
  Future<void> _getCameraUserLocationPosition() async {
    //Usado para quando nao tiver permissão de localização
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
      final idCurrentUser = await _authService.verifyStateUserLogged();
      if (idCurrentUser == null) {
        _errorMensager = "Usuario não encontrado";
        logout();
      }
      _usuario = await _userService.getDataUserOn(idCurrentUser!);
      await verfyActivatedRequisition();
      await getPermissionLocation();
    } on UserException catch (e) {
      _errorMensager = e.message;
      logout();
    }
  }

  Future<void> verfyActivatedRequisition() async {
    try {
      _errorMensager = null;
      //Todo verificar metodo
      final requisicao = await _requisitionSerivce
          .verfyActivatedRequisition(_usuario!.idRequisicaoAtiva!);
      _requisicao = requisicao;
      // initListener();
      return;
    } on RequestNotFound {
      _requisicao = Requisicao.empty();
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

  Future<void> logout() async {
    _authService.logout();
    _usuario = null;
  }

  @action
  Future<void> _getUserLocation() async {
    final actualPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    /*  _cameraPosition = CameraPosition(
        target: LatLng(actualPosition.latitude, actualPosition.longitude),
        zoom: 16,
      ); */

    final address = await _locationService.findDataLocationFromLatLong(
        actualPosition.latitude, actualPosition.longitude);
    await setNameMyLocal(address);
  }

  @action
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
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _locationPermission = permission;
          return;
        }
        break;

      case LocationPermission.deniedForever:
        _locationPermission = LocationPermission.deniedForever;
        return;

      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        break;
    }

    // _getUserAddress();
    _getUserLocation();
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
          "${UberCloneConstants.ASSEESTS_IMAGE}/destination1.png", 0.0, const Size(20, 20));

      final myMarkerLocal = _locationService.createLocationMarker(
          addres.latitude,
          addres.longitude,
          pathImageIcon,
          "my_local",
          'meu local',
          10);
      _markers.add(myMarkerLocal);
      _showAllPositionsAndTraceRouter();
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
        "${UberCloneConstants.ASSEESTS_IMAGE}/destination2.png", 0.0, const Size(20, 20));
    final myMarkerLocal = _locationService.createLocationMarker(
        addres.latitude,
        addres.longitude,
        pathImageIcon,
        "my_local_destination",
        'Meu destino',
        90);
    _markers.add(myMarkerLocal);
    _showAllPositionsAndTraceRouter();
  }

  @action
  Future<void> _showAllPositionsAndTraceRouter() async {
    if (!isAddressNotNullOrEmpty) {
      if (_cameraPosition != null) {
        _mapsCameraService.moveCamera(_cameraPosition!, controller);
      }
      return;
    }

    _mapsCameraService.moverCameraBound(
        _myAddres!, _myDestination!, 60, controller);
    await _traceRouter();
  }

  @action
  Future<List<Address>> findAddresByName(String addresName) async {
    try {
      const apiKey = String.fromEnvironment('maps_key', defaultValue: "");
      if (addresName.isNotEmpty && apiKey.isNotEmpty) {
        final adress =
            await _locationService.findAddresByName(addresName, apiKey);

        return adress;
      }
      return <Address>[];
    } on AddresException catch (e) {
      _errorMensager = null;
      _errorMensager = e.message;
      return <Address>[];
    }
  }

  @action
  Future<void> _traceRouter() async {
    _polynesRouter = <Polyline>{};
    if (isAddressNotNullOrEmpty) {
      final polylinesData = await _tripService.getRoute(
          _myAddres!,
          _myDestination!,
          Colors.black,
          5,
          const String.fromEnvironment('maps_key'));
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
        valorCorrida: _tripSelected!.price,
      );

      final requestId = await _requisitionSerivce.createRequisition(requisicao);

      final userUpadated = _usuario!.copyWith(
        idRequisicaoAtiva: requestId,
        latitude: myLat,
        longitude: myLong,
      );

      await _userService.updateUser(userUpadated);
      //TODO QUANDO CANCELAR VIAGEM EXLUIIR ID DA REQUISIÇÂO NO PASSAGEIRO
      final requestUpdated = await _requisitionSerivce.updataDataRequisition(
          //TODO ERRO AO ATUALIZAR REQUISIÇÂO
          requisicao,
          {"idRequisicao": requestId, "passageiro": userUpadated.toMap()});
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
      streamSubscription.cancel();
    }
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
        "${UberCloneConstants.ASSEESTS_IMAGE}/destination2",
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

  Future<void> statusVeifyRequest(Requisicao request) async {
    switch (request.status) {
      case Status.AGUARDANDO:
        statusUberAguardando(request);
      case Status.A_CAMINHO:
        ;
      case Status.EM_VIAGEM:
        ;
      case Status.CONFIRMADA:
        ;
      case Status.FINALIZADO:
        ;
      case Status.CANCELADA:
        statusUberNaoChamdo();
    }
  }

  Future<void> statusUberNaoChamdo() async {
    _textoBotaoPadrao = "Procurar Motorista";
    _statusRequisicao = Status.NAO_CHAMADO;
    _exibirCaixasDeRotas = true;
    _functionPadrao = () {};
    // await _getUserLocation();
    // await _getUserAddress();
  }

  Future<void> statusUberAguardando(Requisicao request) async {
    _textoBotaoPadrao = "Cancelar";
    _statusRequisicao = Status.AGUARDANDO;
    _exibirCaixasDeRotas = false;
    getActiveTripData(request);
    _functionPadrao = cancelarUber;

    _showAllPositionsAndTraceRouter();
  }

  Future<void> deslogar() async {
    try {
      final isLogout = await _authService.logout();
      if (isLogout) {
        _usuario = null;
      }
    } on UserException catch (e) {
      _errorMensager = null;
      _errorMensager = e.message;
    }
  }

  Future<void> listenMessage() async {
    notificatioSubscription = _firebaseNotificationService
        .getNotificationFistPlane()
        .listen((UberMessanger message) {
      final body = message.body;
      final title = message.title;
      final url = message.imgUrl;

      debugPrint("MESSAGE FIREBASE ARGS: ${message.data}");

      if (body != null && title != null) {
        debugPrint("MESSAGE FIREBASE: ${message.title} ");
        _notificationService.showNotification(
          title: title,
          body: body,
          indeterminate: true,
          showProgress: true,
        );
      }
    });
  }
  
    Future<void> getMessgeBAckGround() async {
      _firebaseNotificationService.getNotificationFinishedApp();
    }

  Future<void> getTokenDevice() async {
    final token = await _firebaseNotificationService.getTokenDevice();
    _firebaseNotificationService.requestPermission();
    if (token == null) return debugPrint("TOKEN FIREBASE: TOKEN nulo ");
    debugPrint("TOKEN FIREBASE: $token");
  }

  Future<void> listenToken() async {
    tokenSubscription = _firebaseNotificationService.onTokenRefresh().listen(
      (data) {
        debugPrint("TOKEN LISTEm FIREBASE: $data ");
      },
    );
  }

  Future<void> showNotification() async {
    _notificationService.showNotification(
        title: "Teste Notification", body: "Enviando notificação de teste");
  }

  void dispose() {
    tokenSubscription.cancel();
    notificatioSubscription.cancel();
    streamSubscription.cancel();
  }
}
