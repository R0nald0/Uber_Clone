import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lotiie;
import 'package:mobx/mobx.dart';
import 'package:uber/app/module/core/widgets/uber_list_trip.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';
import 'package:uber_clone_core/uber_clone_core.dart';
import 'package:validatorless/validatorless.dart';

part 'widgets/uber_button_elevated.dart';

class HomePassageiroPage extends StatefulWidget {
  final HomePassageiroController homePassageiroController;

  const HomePassageiroPage({super.key, required this.homePassageiroController});

  @override
  State<StatefulWidget> createState() => HomePassageiroPageState();
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

    _alterarBotoes(
        const Text(
          "Procurar Motorista",
          style: TextStyle(color: Colors.white),
        ),
        Colors.black, () {
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
              widget.homePassageiroController.requisicao?.status ==
                      Status.AGUARDANDO
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width / 1.3,
                        height: MediaQuery.of(context).size.height / 5,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32)),
                        child: Column(
                          children: [
                            Text('Buscando Motorista',
                                style: Theme.of(context).textTheme.titleMedium),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 7.5,
                                child: lotiie.Lottie.asset(
                                    UberCloneConstants.LOTTI_ASSET_FIND_DRIVER))
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              UberButtonElevated(
                  functionPadrao: () => _functionPadrao(),
                  textoPadrao: _textoBotaoPadrao,
                  corDoBotaoPadrao: _corBotaoPadrao),
            ],
          ),
        ));
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
