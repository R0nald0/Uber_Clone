// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_passageiro_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomePassageiroController on HomePassageiroControllerBase, Store {
  Computed<bool>? _$isAddressNotNullOrEmptyComputed;

  @override
  bool get isAddressNotNullOrEmpty => (_$isAddressNotNullOrEmptyComputed ??=
          Computed<bool>(() => super.isAddressNotNullOrEmpty,
              name: 'HomePassageiroControllerBase.isAddressNotNullOrEmpty'))
      .value;

  late final _$_tripsAtom =
      Atom(name: 'HomePassageiroControllerBase._trips', context: context);

  List<Trip> get trips {
    _$_tripsAtom.reportRead();
    return super._trips;
  }

  @override
  List<Trip> get _trips => trips;

  @override
  set _trips(List<Trip> value) {
    _$_tripsAtom.reportWrite(value, super._trips, () {
      super._trips = value;
    });
  }

  late final _$_tripSelectedAtom = Atom(
      name: 'HomePassageiroControllerBase._tripSelected', context: context);

  Trip? get tripSelected {
    _$_tripSelectedAtom.reportRead();
    return super._tripSelected;
  }

  @override
  Trip? get _tripSelected => tripSelected;

  @override
  set _tripSelected(Trip? value) {
    _$_tripSelectedAtom.reportWrite(value, super._tripSelected, () {
      super._tripSelected = value;
    });
  }

  late final _$_errorMensagerAtom = Atom(
      name: 'HomePassageiroControllerBase._errorMensager', context: context);

  String? get errorMensager {
    _$_errorMensagerAtom.reportRead();
    return super._errorMensager;
  }

  @override
  String? get _errorMensager => errorMensager;

  @override
  set _errorMensager(String? value) {
    _$_errorMensagerAtom.reportWrite(value, super._errorMensager, () {
      super._errorMensager = value;
    });
  }

  late final _$_usuarioAtom =
      Atom(name: 'HomePassageiroControllerBase._usuario', context: context);

  Usuario? get usuario {
    _$_usuarioAtom.reportRead();
    return super._usuario;
  }

  @override
  Usuario? get _usuario => usuario;

  @override
  set _usuario(Usuario? value) {
    _$_usuarioAtom.reportWrite(value, super._usuario, () {
      super._usuario = value;
    });
  }

  late final _$_requisicaoAtom =
      Atom(name: 'HomePassageiroControllerBase._requisicao', context: context);

  Requisicao? get requisicao {
    _$_requisicaoAtom.reportRead();
    return super._requisicao;
  }

  @override
  Requisicao? get _requisicao => requisicao;

  @override
  set _requisicao(Requisicao? value) {
    _$_requisicaoAtom.reportWrite(value, super._requisicao, () {
      super._requisicao = value;
    });
  }

  late final _$_locationPermissionAtom = Atom(
      name: 'HomePassageiroControllerBase._locationPermission',
      context: context);

  LocationPermission? get locationPermission {
    _$_locationPermissionAtom.reportRead();
    return super._locationPermission;
  }

  @override
  LocationPermission? get _locationPermission => locationPermission;

  @override
  set _locationPermission(LocationPermission? value) {
    _$_locationPermissionAtom.reportWrite(value, super._locationPermission, () {
      super._locationPermission = value;
    });
  }

  late final _$_isServiceEnableAtom = Atom(
      name: 'HomePassageiroControllerBase._isServiceEnable', context: context);

  bool get isServiceEnable {
    _$_isServiceEnableAtom.reportRead();
    return super._isServiceEnable;
  }

  @override
  bool get _isServiceEnable => isServiceEnable;

  @override
  set _isServiceEnable(bool value) {
    _$_isServiceEnableAtom.reportWrite(value, super._isServiceEnable, () {
      super._isServiceEnable = value;
    });
  }

  late final _$_cameraPositionAtom = Atom(
      name: 'HomePassageiroControllerBase._cameraPosition', context: context);

  CameraPosition? get cameraPosition {
    _$_cameraPositionAtom.reportRead();
    return super._cameraPosition;
  }

  @override
  CameraPosition? get _cameraPosition => cameraPosition;

  @override
  set _cameraPosition(CameraPosition? value) {
    _$_cameraPositionAtom.reportWrite(value, super._cameraPosition, () {
      super._cameraPosition = value;
    });
  }

  late final _$_myAddresAtom =
      Atom(name: 'HomePassageiroControllerBase._myAddres', context: context);

  Addres? get myAddres {
    _$_myAddresAtom.reportRead();
    return super._myAddres;
  }

  @override
  Addres? get _myAddres => myAddres;

  @override
  set _myAddres(Addres? value) {
    _$_myAddresAtom.reportWrite(value, super._myAddres, () {
      super._myAddres = value;
    });
  }

  late final _$_myDestinationAtom = Atom(
      name: 'HomePassageiroControllerBase._myDestination', context: context);

  Addres? get myDestination {
    _$_myDestinationAtom.reportRead();
    return super._myDestination;
  }

  @override
  Addres? get _myDestination => myDestination;

  @override
  set _myDestination(Addres? value) {
    _$_myDestinationAtom.reportWrite(value, super._myDestination, () {
      super._myDestination = value;
    });
  }

  late final _$_markersAtom =
      Atom(name: 'HomePassageiroControllerBase._markers', context: context);

  Set<Marker> get markers {
    _$_markersAtom.reportRead();
    return super._markers;
  }

  @override
  Set<Marker> get _markers => markers;

  @override
  set _markers(Set<Marker> value) {
    _$_markersAtom.reportWrite(value, super._markers, () {
      super._markers = value;
    });
  }

  late final _$_polynesRouterAtom = Atom(
      name: 'HomePassageiroControllerBase._polynesRouter', context: context);

  Set<Polyline> get polynesRouter {
    _$_polynesRouterAtom.reportRead();
    return super._polynesRouter;
  }

  @override
  Set<Polyline> get _polynesRouter => polynesRouter;

  @override
  set _polynesRouter(Set<Polyline> value) {
    _$_polynesRouterAtom.reportWrite(value, super._polynesRouter, () {
      super._polynesRouter = value;
    });
  }

  late final _$getUserLocationAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.getUserLocation',
      context: context);

  @override
  Future<void> getUserLocation() {
    return _$getUserLocationAsyncAction.run(() => super.getUserLocation());
  }

  late final _$setNameMyLocalAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.setNameMyLocal',
      context: context);

  @override
  Future<void> setNameMyLocal(Addres addres) {
    return _$setNameMyLocalAsyncAction.run(() => super.setNameMyLocal(addres));
  }

  late final _$setDestinationLocalAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.setDestinationLocal',
      context: context);

  @override
  Future<void> setDestinationLocal(Addres addres) {
    return _$setDestinationLocalAsyncAction
        .run(() => super.setDestinationLocal(addres));
  }

  late final _$showAllPositionsAndTraceRouterAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.showAllPositionsAndTraceRouter',
      context: context);

  @override
  Future<void> showAllPositionsAndTraceRouter() {
    return _$showAllPositionsAndTraceRouterAsyncAction
        .run(() => super.showAllPositionsAndTraceRouter());
  }

  late final _$findAddresByNameAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.findAddresByName',
      context: context);

  @override
  Future<List<Addres>> findAddresByName(String addresName) {
    return _$findAddresByNameAsyncAction
        .run(() => super.findAddresByName(addresName));
  }

  late final _$traceRouterAsyncAction =
      AsyncAction('HomePassageiroControllerBase.traceRouter', context: context);

  @override
  Future<void> traceRouter() {
    return _$traceRouterAsyncAction.run(() => super.traceRouter());
  }

  late final _$selectedTripAsyncAction = AsyncAction(
      'HomePassageiroControllerBase.selectedTrip',
      context: context);

  @override
  Future<void> selectedTrip(Trip trip) {
    return _$selectedTripAsyncAction.run(() => super.selectedTrip(trip));
  }

  @override
  String toString() {
    return '''
isAddressNotNullOrEmpty: ${isAddressNotNullOrEmpty}
    ''';
  }
}
