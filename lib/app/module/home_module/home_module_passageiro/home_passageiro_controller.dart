import 'dart:async';
import 'dart:developer';

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

  final FirebaseNotfication _firebaseNotificationService;
  final IPaymentService _paymentService;

  StreamSubscription<Requisicao>? requestSubscription;
  StreamSubscription<UberMessanger>? notificatioSubscription;

  final controller = Completer<GoogleMapController>();

  HomePassageiroControllerBase({
    required IAuthService authService,
    required IAddresService addressService,
    required IRequistionService requestService,
    required IUserService userService,
    required ILocationService locattionService,
    required MapsCameraService cameraService,
    required ITripSerivce tripService,
    required IPaymentService paymentService,
    required FirebaseNotfication firebaseNotificationService,
  })  : _authService = authService,
        _addressService = addressService,
        _requisitionSerivce = requestService,
        _userService = userService,
        _locationService = locattionService,
        _mapsCameraService = cameraService,
        _tripService = tripService,

        _firebaseNotificationService = firebaseNotificationService,
        _paymentService = paymentService;

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
  var _payments = <PaymentType>[];

  @readonly
  bool? _exibirCaixasDeRotas;
  @readonly
  RequestState _statusRequisicao = RequestState.nao_chamado;

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
      await setNameMyLocal(address, 'destination1.png');
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

      if (_usuario!.idRequisicaoAtiva == null ||
          _usuario!.idRequisicaoAtiva!.isEmpty) {
        _requisicao = Requisicao.empty();
        _errorMensager = "Escolha um destino para iniciar uma corrida";
        return;
      }

      await verfyActivatedRequisition(_usuario!.idRequisicaoAtiva!);
    } on UserException catch (e) {
      _errorMensager = e.message;
      logout();
    }
  }

  Future<void> verfyActivatedRequisition(String idRequisicao) async {
    try {
      final requisicao =
          await _requisitionSerivce.verfyActivatedRequisition(idRequisicao);
      _requisicao = requisicao;
      // initListener();
      return;
    } on RequestNotFound {
      _requisicao = Requisicao.empty();
      _showErrorMessage("Escolha seu destino para iniciar a viagem");
    }
  }

  Future<void> getActiveTripData(Requisicao requisicao) async {
    final Usuario(:latitude, :longitude) = requisicao.passageiro;

    final addressPassanger =
        await _locationService.findDataLocationFromLatLong(latitude, longitude);

    await setNameMyLocal(addressPassanger, 'destination1.png');
    await setDestinationLocal(requisicao.destino, 'destination2.png');
  }

  Future<void> logout() async {
    _authService.logout();
    _usuario = null;
  }

  @action
  Future<void> _getUserLocation() async {
    final actualPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final address = await _locationService.findDataLocationFromLatLong(
        actualPosition.latitude, actualPosition.longitude);
    await setNameMyLocal(address, 'destination1.png');
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
  Future<void> setNameMyLocal(Address addres, String imagePath) async {
    _myAddres = null;
    _myAddres = addres;

    if (_usuario != null) {
      final pathImageIcon = await _locationService.markerPositionIconCostomizer(
          "${UberCloneConstants.ASSEESTS_IMAGE}/$imagePath",
          0.0,
          const Size(20, 20));

      final myMarkerLocal = _locationService.createLocationMarker(
          addres.latitude,
          addres.longitude,
          pathImageIcon,
          "my_local",
          'meu local',
          10);
      _markers.add(myMarkerLocal);
      final position = (latitude: addres.latitude, longitude: addres.longitude);
      await _showAllPositionsAndTraceRouter(position);
    }
  }

  @action
  Future<void> setDestinationLocal(Address addres, String imagePath) async {
    _myDestination = null;
    _myDestination = addres;

    final pathImageIcon = await _locationService.markerPositionIconCostomizer(
        "${UberCloneConstants.ASSEESTS_IMAGE}/$imagePath",
        0.0,
        const Size(20, 20));
    final myMarkerLocal = _locationService.createLocationMarker(
        addres.latitude,
        addres.longitude,
        pathImageIcon,
        "my_local_destination",
        'Meu destino',
        90);
    _markers.add(myMarkerLocal);
    final position = (latitude: addres.latitude, longitude: addres.longitude);
    await _showAllPositionsAndTraceRouter(position);
  }

  @action
  Future<void> _showAllPositionsAndTraceRouter(
      ({double latitude, double longitude}) position) async {
    if (!isAddressNotNullOrEmpty) {
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17,
      );

      if (_cameraPosition != null) {
        await _mapsCameraService.moveCamera(_cameraPosition!, controller);
      }
      return;
    }
    _mapsCameraService.moverCameraBound(
        _myAddres!, _myDestination!, 80, controller);
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

      if (_requisicao?.status != RequestState.aguardando) {
        _configureTripList(polylinesData);
      }
    }
  }

  void _configureTripList(PolylineData polylineData) async {
    if (_polynesRouter.isNotEmpty) {
      try {
        final payments = await _paymentService.getTypesPayment();
        _payments = payments;
        final trips = _tripService.configureTripList(polylineData);
        _trips = trips;
      } on RepositoryException catch (e) {
        _showErrorMessage(e.message);
      }
    }
  }

  void _showErrorMessage(String message,
      {dynamic error, StackTrace? stackTrace}) {
    _errorMensager = null;
    _errorMensager = message;
    log(error, stackTrace: stackTrace);
  }

  @action
  Future<void> selectedTrip(Trip trip) async => _tripSelected = trip;

  @action
  Future<void> createRequisitionToRide(int idPaymentType) async {
    if (_tripSelected == null ||
        _myAddres == null ||
        _myDestination == null ||
        _usuario == null) {
      _showErrorMessage(
        "escolha os dados para sua viagem",
      );
      return;
    }

    final Address(latitude: myLatitude, longitude: myLongitude) = _myAddres!;
    final Address(
      latitude: destinationLatitude,
      longitude: destinationLongitude
    ) = _myDestination!;

    try {
      final destinationAddress =
          await _locationService.findDataLocationFromLatLong(
              destinationLatitude, destinationLongitude);

      final requisicao = Requisicao(
        paymentType: _payments.firstWhere((p) => p.id == idPaymentType),
        id: null,
        destino: destinationAddress,
        motorista: null,
        passageiro: _usuario!,
        status: RequestState.aguardando,
        valorCorrida: _tripSelected!.price,
      );
      requisicao;
      final requestId = await _requisitionSerivce.createRequisition(requisicao);

      final userUpadated = _usuario!.copyWith(
        idRequisicaoAtiva: requestId,
        latitude: myLatitude,
        longitude: myLongitude,
      );

      final completedUpdate =
          requisicao.copyWith(id: () => requestId, passageiro: userUpadated);

      await _userService.updateUser(userUpadated);
      _usuario = userUpadated;

      final requestUpdated =
          await _requisitionSerivce.updataDataRequisition(completedUpdate);
     await verfyActivatedRequisition(requestId);
      
    } on RequestException catch (e, s) {
      _showErrorMessage(e.message, error: e, stackTrace: s);
    } on AddresException catch (e, s) {
      _showErrorMessage(e.message, error: e, stackTrace: s);
    }
  }

  @action
  Future<void> cancelarUber() async {
    if (_requisicao == null) {
      return;
    }

    final isCancel = await _requisitionSerivce.cancelRequisition(_requisicao!);
    if (isCancel) {
      _addresList = List.empty();
      _markers = {};
      _tripSelected = null;
      _myDestination = null;
      _polynesRouter.clear();
    
      requestSubscription?.cancel();
      _requisicao = null;
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

        _requisicao = _requisicao!.copyWith(passageiro: userUpdated);

        _requisitionSerivce.updataDataRequisition(
          _requisicao!,
        );

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
    return switch (request.status) {
      RequestState.aguardando => statusUberAguardando(request),
      RequestState.a_caminho => _stateUberOnWay(request),
      RequestState.em_viagem => inTravel(request),
      RequestState.finalizado => finishRequest(request),
      RequestState.pagamento_confirmado => paymentConfirmed(request),
      RequestState.cancelado => statusUberNaoChamdo(),
      _ => statusUberNaoChamdo()
    };
  }

  Future<void> paymentConfirmed(Requisicao request) async {
     _myAddres = null;
    _addresList = List.empty();
    _exibirCaixasDeRotas = true;
    _functionPadrao = null;
    _markers = {};
    _myDestination = null;
    _polynesRouter = {};
    _tripSelected = null;
    _addresList = List.empty();
    _requisicao = null;
     print("STATUS  ${request.status}");
    _statusRequisicao = RequestState.pagamento_confirmado;
    ServiceNotificationImpl().showNotification(
      title: "Pagamento Confirmado", 
      body: "Obrigado pela viagem com ${request.motorista?.nome},avalie o motorista"
      );
      _requisitionSerivce.deleteAcvitedRequest(request);
    
  }

  Future<void> finishRequest(Requisicao request) async {
    _textoBotaoPadrao = "";
    _statusRequisicao = RequestState.finalizado;
    print("STATUS finishRequest ${request.status}");
   
    _exibirCaixasDeRotas = false;
  }

  Future<void> inTravel(Requisicao request) async {
    _textoBotaoPadrao = "";
    _statusRequisicao = RequestState.em_viagem;
    print("STATUS inTravel ${request.status}");
    _exibirCaixasDeRotas = false;

    final Usuario(latitude: myLatitude, longitude: myLongitude, :nome) =
        request.motorista!;
    final destinationAddress = request.destino;

    final myAdrees = Address.emptyAddres().copyWith(
        nomeDestino: nome, latitude: myLatitude, longitude: myLongitude);

    setNameMyLocal(myAdrees, 'map_car.png');
    setDestinationLocal(destinationAddress, 'destination2.png');
  }

  Future<void> statusUberNaoChamdo() async {
    _polynesRouter = {};
    _requisicao = null;
    _textoBotaoPadrao = "Procurar Motorista";
    _statusRequisicao = RequestState.nao_chamado;
    
    _exibirCaixasDeRotas = true;
    await _getUserLocation();
  }

  Future<void> statusUberAguardando(Requisicao request) async {
    _textoBotaoPadrao = "Cancelar";
    _statusRequisicao = RequestState.aguardando;
    _exibirCaixasDeRotas = false;
    print("STATUS  ${request.status}");
    getActiveTripData(request);
  }
  Future<void> deslogar() async {
    try {
      final isLogout = await _authService.logout();
      if (isLogout) {
        _usuario = null;
      }
    } on UserException catch (e) {
      _showErrorMessage(e.message ?? 'Usuário não deslogado,tente novamente!!');
    }
  }

 

  Future<void> getMessgeBackGround() async {
    _firebaseNotificationService.getNotificationFinishedApp();
  }

  Future<void> observerRequestState() async {
    if (_requisicao == null || _requisicao?.id == null) {
        statusUberNaoChamdo();
      return;
    }
    requestSubscription?.cancel();
    requestSubscription = _requisitionSerivce
        .findAndObserverById(_requisicao!)
        .listen((dataActualRequest) async {
      await statusVeifyRequest(dataActualRequest);
      if (dataActualRequest.status != _requisicao?.status) {
        await _requisitionSerivce.updataDataRequisition(dataActualRequest);
      }
    });
  }
 
 Future<void>  reportError() async{
     _requisicao = null;
     _addresList.clear();
     _myAddres = null;
    _addresList = List.empty();
    _exibirCaixasDeRotas = true;
    _functionPadrao = null;
    _markers = {};
    _myDestination = null;
    _polynesRouter = {};
    _tripSelected = null;
    _statusRequisicao = RequestState.pagamento_confirmado;
   _requisitionSerivce.deleteAcvitedRequest(_requisicao!);

 }   
  void dispose() {
    notificatioSubscription?.cancel();
    requestSubscription?.cancel();
  }

  Future<void> _stateUberOnWay(Requisicao request) async {
    _statusRequisicao = RequestState.a_caminho;
      _exibirCaixasDeRotas = false;
      _textoBotaoPadrao = "Cancelar";

    final Usuario(:latitude, :longitude, :nome) = request.motorista!;
    final Usuario(
      latitude: passageiroLatitude,
      longitude: passageirolongitude
    ) = request.passageiro;

    final otherLocation = Address.emptyAddres()
        .copyWith(latitude: latitude, longitude: longitude, nomeDestino: nome);
    final passageiroLocation = _myAddres?.copyWith(
        latitude: passageiroLatitude, longitude: passageirolongitude);

    await setDestinationLocal(otherLocation, 'map_car.png');
    await setNameMyLocal(passageiroLocation!, 'destination1.png');
  }
}
