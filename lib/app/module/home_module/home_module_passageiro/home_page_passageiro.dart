import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lotiie;
import 'package:mobx/mobx.dart';
import 'package:uber/app/model/Marcador.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/module/core/widgets/uber_list_trip.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';
import 'package:uber/app/util/Status.dart';
import 'package:uber/app/util/UsuarioFirebase.dart';
import 'package:uber/controller/Banco.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/mixins/dialog_loader/dialog_loader.dart';
import 'package:uber/core/widgets/uber_text_fields/uber_auto_completer_text_field.dart';
import 'package:validatorless/validatorless.dart';

part 'widgets/uber_button_elevated.dart';

class HomePassageiroPage extends StatefulWidget {
  final HomePassageiroController homePassageiroController;

  const HomePassageiroPage({super.key, required this.homePassageiroController});

  @override
  State<StatefulWidget> createState() => HomePassageiroPageState() ;
}

class HomePassageiroPageState extends State<HomePassageiroPage>
    with DialogLoader {
  final disposerReactions = <ReactionDisposer>[];
  var address = <Address>[];

  CameraPosition positionCan =
      const CameraPosition(target: LatLng(-13.008864, -38.528722), zoom: 12);
  final Set<Marker> _marcador = {};
  late BitmapDescriptor imgPassageiro;
 
  final formKey = GlobalKey<FormState>();
  List<String> listMenu = ["Configuraçoes", "Deslogar"];
  late StreamSubscription<DocumentSnapshot> streamSubscription;

  //DADOS Passageiro
  String meuLoca = "";
  Address? meuLocal;
  Address? meuDestino;

  late Position _localPassageiros;
  late Position _localMotorista;
  late String nomeMotorista = "";

  // Elementos da view
  bool _exibirCaixasDeRotas = false;
  late Widget _textoBotaoPadrao = const CircularProgressIndicator(
    color: Colors.white,
  );
  late Color _corBotaoPadrao = const Color.fromARGB(31, 247, 243, 243);
  late Function _functionPadrao = () {};

  String _idRequisicao = " ";
  late String idUser;

  Map<String, dynamic> _dadosRequisicaoPassageiro = {};
  Map<String, dynamic> _dadosRequisicaoMotorista = {};
  Map<String, dynamic> _dadosRequisicaoDestino = {};

  _escolhaMenu(String escolha, HomePassageiroController controller) {
    switch (escolha) {
      case "Configurações":
        break;
      case "Deslogar":
        controller.logout();
        // _deslogarUsuario();
        break;
    }
  }

  _addMarcador(Position position, String caminho, String titulo) async {
    double config = MediaQuery.of(context).devicePixelRatio;
    await BitmapDescriptor.asset(
            ImageConfiguration(devicePixelRatio: config), "images/$caminho.png")
        .then((ic) {
      crirarMarcador(position, ic, caminho, titulo);
    });
  }

  crirarMarcador(Position position, BitmapDescriptor imgLocal,
      String idMarcador, tiuloLocal) async {
    Marker marker = Marker(
        markerId: MarkerId(idMarcador),
        infoWindow: InfoWindow(title: tiuloLocal),
        position: LatLng(position.latitude, position.longitude),
        icon: imgLocal);
    _marcador.add(marker);
  }

  dialogValorCorrida(String valor) {
    showDialog(
        context: context,
        builder: (contex) => AlertDialog(
              title: const Center(
                child: Text("Valor a ser pago"),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      "R\$ $valor",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                        onPressed: () {},
                        child: const Text("Mudar forma de pagamento")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _statusUberNaoChamdo();
                        },
                        child: const Text("Pagar"))
                  ],
                )
              ],
            ));
  }

  criarDialg(Address destino, context, String valorDaCorrida) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Dados da viagem"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      "Cidade :${destino.cidade}\n"
                      "Bairro :${destino.bairro}\n"
                      "Rua : ${destino.rua},${destino.numero}\n"
                      "Cep : ${destino.cep}\n"
                      "Endereço : ${destino.nomeDestino}\n",
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "R\$ $valorDaCorrida",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () {
                          _salvarRequisicao(destino, valorDaCorrida);
                          Navigator.pop(context);
                        },
                        child: const Text("Confirmar",
                            style: TextStyle(color: Colors.green))),
                  ],
                )
              ],
            ));
  }

  _alterarBotoes(Widget textButton, Color cor, Function function) {
    if (mounted) {
      setState(() {
        _textoBotaoPadrao = textButton;
        _corBotaoPadrao = cor;
        _functionPadrao = function;
      });
    }
  }

  _statusUberNaoChamdo() {
    // _getPermissionLocation();
    _exibirCaixasDeRotas = true;

    _alterarBotoes(const Text("Procurar Motorista",style: TextStyle(color: Colors.white),), Colors.black, () {
      widget.homePassageiroController.getPermissionLocation();
      showModalBottomSheet(
        enableDrag: true,
        context: context,
        builder: (contextBottom) {
          return Observer(
            builder: (contextBottom) {
              return UberListTrip(
                tripOptions: widget.homePassageiroController.trips,
                tripSelected: widget.homePassageiroController.tripSelected,
                onSelected: (tripSelected) {
                  widget.homePassageiroController.selectedTrip(tripSelected);
                },
                onConfirmationTrip: () {
                  widget.homePassageiroController.createRequisitionToRide();
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    });
  }

  _statusUberAguardando() async {
    _exibirCaixasDeRotas = false;

    _alterarBotoes(const Text("Cancelar"), Colors.red, () async {
      await widget.homePassageiroController.cancelarUber();
    });

    // getLocationUser();
    widget.homePassageiroController.updatePositionUser();
    /* DocumentSnapshot snapshot =
        await Banco.db.collection('requisicao').doc(_idRequisicao).get();
       _dadosRequisicaoPassageiro = snapshot.get('passageiro');

    double latPass = _dadosRequisicaoPassageiro['latitude'];
    double longPass = _dadosRequisicaoPassageiro['longitude'];

    _localPassageiros = Position(
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        longitude: longPass,
        latitude: latPass,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 18,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    _addMarcador(_localPassageiros, 'passageiro', 'Meu local'); */
  }

  _statusAcaminho() async {
    getLocationUser();
    DocumentSnapshot dados =
        await Banco.db.collection("requisicao").doc(_idRequisicao).get();

    _dadosRequisicaoMotorista = dados.get('motorista');
    _dadosRequisicaoPassageiro = dados.get('passageiro');

    nomeMotorista = _dadosRequisicaoMotorista['nome'];
    double motLatitude = _dadosRequisicaoMotorista['latitude'];
    double motLongitude = _dadosRequisicaoMotorista['longitude'];

    double passLatitude = _dadosRequisicaoPassageiro['latitude'];
    double passLongitude = _dadosRequisicaoPassageiro['longitude'];

    Marcador marcadorOrigem =
        Marcador(LatLng(motLatitude, motLongitude), 'motorista', nomeMotorista);

    Marcador marcadorDestino = Marcador(
        LatLng(passLatitude, passLongitude), 'passageiro', 'Estou Aqui');

    //  _exibirPosicoesMarcadores(marcadorOrigem, marcadorDestino);
    _alterarBotoes(
        Column(children: <Widget>[
          Text(
            "Motorista $nomeMotorista á Caminho....... ",
            style: const TextStyle(color: Colors.black),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: LinearProgressIndicator(
              minHeight: 6,
            ),
          )
        ]),
        Colors.white30,
        () {});
  }

  _statusEmViagem() async {
    _marcador.clear();
    _exibirCaixasDeRotas = false;
    getLocationUser();
    DocumentSnapshot snapshot =
        await UsuarioFirebase.getDadosRequisicao(_idRequisicao);

    _dadosRequisicaoDestino = snapshot.get('destino');
    _dadosRequisicaoMotorista = snapshot.get('motorista');

    String destino = _dadosRequisicaoDestino['rua'];

    double latDestino = _dadosRequisicaoDestino['latitude'];
    double longDestino = _dadosRequisicaoDestino['longitude'];

    double latOrigem = _dadosRequisicaoMotorista['latitude'];
    double longOrigem = _dadosRequisicaoMotorista['longitude'];

    Marcador marcadorOrigem =
        Marcador(LatLng(latOrigem, longOrigem), 'motorista', 'Meu local');
    Marcador marcadorDestino =
        Marcador(LatLng(latDestino, longDestino), 'destino', destino);

    // _exibirPosicoesMarcadores(marcadorOrigem, marcadorDestino);

    _alterarBotoes(Text("Á caminho de $destino"), _corBotaoPadrao, () {});
  }

  _statusFinalizado() async {
    DocumentSnapshot snapshot =
        await UsuarioFirebase.getDadosRequisicao(_idRequisicao);

    double latDestino = snapshot['motorista']['latitude'];
    double longDestino = snapshot['motorista']['longitude'];

    Position positioFinal = Position(
        longitude: longDestino,
        latitude: latDestino,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        accuracy: 0,
        altitude: 18,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
    _addMarcador(positioFinal, "destino", 'destino');
    setState(() {
      positionCan = CameraPosition(
          target: LatLng(positioFinal.latitude, positioFinal.longitude),
          zoom: 18);
    });
    // _moverCamera(positionCan);

    _confirmarValor();
  }

  _statusUberConfirmado() async {
    _dadosRequisicaoMotorista = {};
    _dadosRequisicaoDestino = {};
    _statusUberNaoChamdo();
  }

  void initReaction() {
    widget.homePassageiroController.getDataUSerOn();
    final userReaction = reaction<Usuario?>(
        (_) => widget.homePassageiroController.usuario, (usuario) async {
      if (usuario != null) {
        await widget.homePassageiroController.verfyActivatedRequisition();
      }
    });
    final erroReaction = reaction<String?>(
        (_) => widget.homePassageiroController.errorMensager, (error) {
      if (error != null) {
        callSnackBar("Nenhuma viagem ativa");
      }
    });

    final requicaoReaction = reaction<Requisicao?>(
        (_) => widget.homePassageiroController.requisicao, (requisicao) {
      if (requisicao == null || requisicao.id == null) {
        _statusUberNaoChamdo();
      } else {
        _idRequisicao = requisicao.id!;
        widget.homePassageiroController.showAllPositionsAndTraceRouter();
        verifyTripState(requisicao.status);
        widget.homePassageiroController.getActiveTripData(requisicao);
        //  _listenerRequisicao(_idRequisicao);
      }
    });

    final serviceEnableReaction =
        reaction<bool>((_) => widget.homePassageiroController.isServiceEnable,
            (isServiceEnable) {
      if (!isServiceEnable) {
        callSnackBar("Ativse sua localização");
      }
    });

    final locationPermissionReaction = reaction<LocationPermission?>(
        (_) => widget.homePassageiroController.locationPermission,
        (permission) {
          showLoaderDialog();
      if (permission == LocationPermission.denied) {
        dialogLocationPermissionDenied(() {
    
          widget.homePassageiroController.getPermissionLocation();
          
        });
      } else if (permission == LocationPermission.deniedForever) {
        dialogLocationPermissionDeniedForeve(() {
          Geolocator.openAppSettings();
        });
      }
      hideLoader();
    });

    /* final stateTripReaction = reaction<String>(
        (_) => widget.homePassageiroController.statusTrip, (stateTrip) {
         verifyTripState(stateTrip);
    }); */

    disposerReactions.addAll([
      erroReaction,
      userReaction,
      requicaoReaction,
      serviceEnableReaction,
      locationPermissionReaction,
     
    ]);
  }

  @override
  void initState() {
    super.initState();
    widget.homePassageiroController.getCameraUserLocationPosition();
    widget.homePassageiroController.getUserAddress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initReaction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Passgeiro "),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  showLoaderDialog();
                  await widget.homePassageiroController.getPermissionLocation();
                  hideLoader();
                  // meuLoca = ;
                },
                icon: const Icon(Icons.my_location)),
            PopupMenuButton<String>(
                onSelected: (String escolhaMenu) {
                  _escolhaMenu(escolhaMenu, widget.homePassageiroController);
                },
                itemBuilder: (context) => listMenu.map((String item) {
                      return PopupMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList())
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(1),
          child: Stack(
            children: <Widget>[
              Observer(builder: (_) {
                return GoogleMap(
                  polylines: widget.homePassageiroController.polynesRouter,
                  markers: widget.homePassageiroController.markers,
                  onCameraMove: (position) {
                    // posicao da camera em movimento
                  },
                  initialCameraPosition:
                      widget.homePassageiroController.cameraPosition ??
                          positionCan,
                  onMapCreated: (GoogleMapController controller) {
                    widget.homePassageiroController.controller
                        .complete(controller);
                  },
                );
              }),
              Visibility(
                visible: _exibirCaixasDeRotas,
                child: Form(
                  key: formKey,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Observer(builder: (context) {
                                  return UberAutoCompleterTextField(
                                    key: UniqueKey(),
                                    hintText: widget.homePassageiroController
                                        .myAddres?.nomeDestino,
                                    prefIcon: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.green,
                                    ),
                                    labalText: "Meu local",
                                    getAddresCallSuggestion:
                                        (nameAdress) async {
                                      return await widget
                                          .homePassageiroController
                                          .findAddresByName(nameAdress);
                                    },
                                    validator: Validatorless.required(
                                        'Campo Requerido'),
                                    onSelcetedAddes: (myActualAddrees) {
                                      widget.homePassageiroController
                                          .setNameMyLocal(myActualAddrees);
                                    },
                                    lastAddress: widget
                                        .homePassageiroController.addresList,
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Observer(builder: (context) {
                                    return UberAutoCompleterTextField(
                                      key: UniqueKey(),
                                      hintText: widget.homePassageiroController
                                          .myDestination?.nomeDestino,
                                      prefIcon: const Icon(
                                        Icons.local_taxi,
                                        color: Colors.black,
                                      ),
                                      labalText: "Destino",
                                      validator: Validatorless.required(
                                          'Campo Requerido'),
                                      getAddresCallSuggestion:
                                          (nameAdress) async {
                                        return await widget
                                            .homePassageiroController
                                            .findAddresByName(nameAdress);
                                      },
                                      onSelcetedAddes: (destinationAddres) {
                                        widget.homePassageiroController
                                            .setDestinationLocal(
                                                destinationAddres);
                                      },
                                      lastAddress: widget
                                          .homePassageiroController.addresList,
                                    );
                                  }),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              widget.homePassageiroController.requisicao?.status == Status.AGUARDANDO
              ?Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width / 1.3,
                  height: MediaQuery.of(context).size.height /5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32)
                  ),
                  child: Column(
                    children: [
                      Text('Buscando Motorista',
                      style: Theme.of(context).textTheme.titleMedium
                      ),
                      
                      SizedBox(
                        height: MediaQuery.of(context).size.height /7.5,
                        child: lotiie.Lottie.asset(UberCloneConstants.LOTTI_ASSET_FIND_DRIVER)
                        )
                    ],
                  ),
                ),
              )
              :const SizedBox.shrink(),
              UberButtonElevated(
                  functionPadrao: () => _functionPadrao(),
                  textoPadrao: _textoBotaoPadrao,
                  corDoBotaoPadrao: _corBotaoPadrao),
            ],
          ),
        ));
  }

  getLocationUser() async {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 5);

    StreamSubscription<Position> positionSt = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_idRequisicao.isNotEmpty) {
        UsuarioFirebase.atualizarPosicaoUsuario(
            _idRequisicao, 'passageiro', position.latitude, position.longitude);
      } else {
        _localPassageiros = position;
      }
    });
  }

  _meuLocal(double latitude, double longitud) async {
    List<Placemark> placemarkLocal =
        await placemarkFromCoordinates(latitude, longitud);

    if (placemarkLocal != 0) {
      //TODO remover este campo
      Placemark local = placemarkLocal[0];
      setState(() {
        meuLoca = "${local.subLocality},"
            "${local.thoroughfare},"
            "${local.subThoroughfare},"
            "${local.subAdministrativeArea},"
            "${local.administrativeArea}";
      });
    }
  }

  _salvarRequisicao(Address destino, String valorFinalCorrida) async {
    Usuario usuario = await UsuarioFirebase.recuperarDadosPassageiro();

    usuario.copyWith(latitude: _localPassageiros.latitude);
    usuario.copyWith(longitude: _localPassageiros.longitude);

    Requisicao requisicao = Requisicao(
        destino: destino,
        id: null,
        motorista: null,
        passageiro: usuario,
        status: Status.AGUARDANDO,
        valorCorrida: valorFinalCorrida);

    //salvar dados a requisiçao
    Banco.db
        .collection("requisicao")
        .doc(requisicao.id)
        .set(requisicao.dadosPassageiroToMap());

    setState(() {
      if (requisicao.id != null) {
        _idRequisicao = requisicao.id!;
      }
    });

    //salvar dados da requisicao activa
    _salvarRequisicaoAtiva(_idRequisicao, idUser);
    // _listenerRequisicao(_idRequisicao);
  }

  _salvarRequisicaoAtiva(String requiscaoId, String usarioId) async {
    Map<String, dynamic> dadosRequisicao = {};
    dadosRequisicao["id_requisisicao"] = requiscaoId;
    dadosRequisicao["id_passageiro"] = usarioId;
    dadosRequisicao["status"] = Status.AGUARDANDO;

    await Banco.db
        .collection("requisicao-ativa")
        .doc(usarioId)
        .set(dadosRequisicao);
  }

  _verificarRequisicaoAtiva() async {
    DocumentSnapshot snapshot =
        await Banco.db.collection("requisicao-ativa").doc(idUser).get();

    if (snapshot.data() != null) {
      _idRequisicao = snapshot.get('id_requisisicao');
      // _listenerRequisicao(_idRequisicao);
    } else {
      _statusUberNaoChamdo();
    }
  }

  /* _listenerRequisicao(String idRequisicao) async {
     streamSubscription = Banco.db
        .collection("requisicao")
        .doc(idRequisicao)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data != null) {
        String status = snapshot["status"];

        verifyTripState(status);
      }
    });
  } */

  void verifyTripState(String status) {
    switch (status) {
      case Status.AGUARDANDO:
        _statusUberAguardando();
        break;

      case Status.A_CAMINHO:
        _statusAcaminho();
        break;

      case Status.EM_VIAGEM:
        _statusEmViagem();
        break;

      case Status.FINALIZADO:
        _statusFinalizado();
        break;
      case Status.CONFIRMADA:
        _statusUberConfirmado();
        break;

      case Status.CANCELADA:
        print("status - $status");
        _statusUberNaoChamdo();
        break;
    }
  }

 /*  _chamarUber() async {
    String destino = _controllerDestino.text;
    if (destino.isNotEmpty) {
      List<Location> locationList = await locationFromAddress(destino);
      if (locationList != null && locationList.length > 0) {
        Location location = locationList[0];
        List<Placemark> placemarkList = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        Placemark placemark = placemarkList[0];
        print("location " + placemark.toString());

        final destino = Address(
            nomeDestino: placemark.name.toString(),
            bairro: placemark.subLocality.toString(),
            cep: placemark.postalCode.toString(),
            cidade: placemark.subAdministrativeArea.toString(),
            numero: placemark.subThoroughfare.toString(),
            rua: placemark.street.toString(),
            latitude: location.latitude,
            longitude: location.longitude);

        /*   String custoCorrida = await _calcularValorVieagem(
            _localPassageiros.latitude,
            _localPassageiros.longitude,
            destino.latitude,
            destino.longitude); */

        criarDialg(destino, context, "custoCorrida");
      }
    }
  } */

  _confirmarValor() async {
    /* if(streamSubscription != null){
      DocumentSnapshot snapshot = await UsuarioFirebase.getDadosRequisicao(_idRequisicao);
      dialogValorCorrida(snapshot['valorCorrida']);
      _getLastPosition();
      streamSubscription.cancel();
    } */
  }

  @override
  void dispose() {
    for (var reaction in disposerReactions) {
      reaction();
    }
  
    widget.homePassageiroController.dispose();
    super.dispose();
  }
}
