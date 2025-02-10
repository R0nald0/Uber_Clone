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


  final formKey = GlobalKey<FormState>();
  List<String> listMenu = ["Configuraçoes", "Deslogar"];
  
 


  void initReaction() async {
   
   

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
        // _statusUberNaoChamdo();
      } else {
        //  _idRequisicao = requisicao.id!;
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
    widget.homePassageiroController.getDataUSerOn();
   
          showLoaderDialog();
          await widget.homePassageiroController.getPermissionLocation();
          hideLoader();
  

    disposerReactions.addAll([
      erroReaction,
      userReaction,
      requicaoReaction,
      serviceEnableReaction,
      locationPermissionReaction,
    ]);
  }

  void CallBottomTrips() {
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
  }

  @override
  void initState() {
    super.initState();
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
                onSelected: (String escolhaMenu) {},
                itemBuilder: (context) => listMenu.map((String item) {
                      return PopupMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList())
          ],
        ),
        body: SafeArea(
          child: Container(
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
                Observer(builder: (context) {
                  return Visibility(
                    visible:
                        widget.homePassageiroController.exibirCaixasDeRotas ??
                            true,
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
                                          hintText: widget
                                              .homePassageiroController
                                              .myDestination
                                              ?.nomeDestino,
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
                                              .homePassageiroController
                                              .addresList,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                }),
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
                    functionPadrao: () {
                      final isValid = formKey.currentState?.validate() ?? false;
                      if (isValid) {
                         CallBottomTrips();
                      }
                    },
                    textoPadrao: const Text("Procurar Motorista"),
                    corDoBotaoPadrao: Colors.black),
              ],
            ),
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
