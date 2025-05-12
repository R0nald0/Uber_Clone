import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/core/widgets/uber_list_trip.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';
import 'package:uber_clone_core/uber_clone_core.dart';
import 'package:validatorless/validatorless.dart';

part 'widgets/uber_button_elevated.dart';
part 'widgets/dialog_find_driver.dart';

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
  int? _idPaymentType;

  CameraPosition positionCan =
      const CameraPosition(target: LatLng(-13.008864, -38.528722), zoom: 12);

  final formKey = GlobalKey<FormState>();
  List<String> listMenu = ["Pefil", "Deslogar"];

  void initReaction() async {
     
    final userReaction = reaction<Usuario?>(
        (_) => widget.homePassageiroController.usuario, (usuario) async {
      if (usuario == null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_) => false);
        return;
      }
    });

    final erroReaction = reaction<String?>(
        (_) => widget.homePassageiroController.errorMensager, (error) {
      if (error != null) {
         callSnackBar(error);
      }
    });

    final requicaoReaction = reaction<Requisicao?>(
        (_) => widget.homePassageiroController.requisicao, (requisicao) async {
      hideLoader();
      if (requisicao == null || requisicao.id == null) {
        widget.homePassageiroController.statusUberNaoChamdo();
      } else {
        widget.homePassageiroController.statusVeifyRequest(requisicao);
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

      if (permission == LocationPermission.denied) {
         dialogLocationPermissionDenied(() {
          widget.homePassageiroController.getPermissionLocation();
        });
      } else if (permission == LocationPermission.deniedForever) {
        dialogLocationPermissionDeniedForeve(() {
          Geolocator.openAppSettings();
        });
      }
    });
    widget.homePassageiroController.getPermissionLocation();
    showLoaderDialog();
    await widget.homePassageiroController.getDataUSerOn();


    disposerReactions.addAll([
      erroReaction,
      userReaction,
      requicaoReaction,
      serviceEnableReaction,
      locationPermissionReaction,
    ]);
  }

  void callBottomTrips() {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (contextBottom) {
        return Observer(
          builder: (contextBottom) {
            return UberListTrip(
              paymentsType: widget.homePassageiroController.payments,
              tripSelected: widget.homePassageiroController.tripSelected,
              tripOptions: widget.homePassageiroController.trips,
              onSelected: (tripSelected) {
                widget.homePassageiroController.selectedTrip(tripSelected);
              },
              onSelectedPayment: (int paymentType) {
                _idPaymentType = paymentType;
              },
              onConfirmationTrip: () {
                _idPaymentType ??= 2;
                widget.homePassageiroController
                    .createRequisitionToRide(_idPaymentType!);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initReaction();
      widget.homePassageiroController.listenMessage();
      widget.homePassageiroController.getMessgeBackGround();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    var controller = widget.homePassageiroController;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Observer(
              builder: (context) {
                return Visibility(
                  visible: controller.exibirCaixasDeRotas ?? true,
                  replacement: const SizedBox.shrink(),
                  child: AppBar(
                    title: const Text("Passgeiro "),
                    actions: <Widget>[
                      IconButton(
                          onPressed: () async {
                            await controller.getPermissionLocation();
                          },
                          icon: const Icon(Icons.my_location)),
                      PopupMenuButton<String>(
                          onSelected: (String escolhaMenu) {
                            switch (escolhaMenu) {
                              case "Deslogar":
                                controller.deslogar();
                              case "Perfil":
                                () {};
                            }
                          },
                          itemBuilder: (context) => listMenu.map((String item) {
                                return PopupMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList())
                    ],
                  ),
                );
              },
            )),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(1),
            child: Stack(
              children: <Widget>[
                Observer(builder: (_) {
                  return GoogleMap(
                    polylines: controller.polynesRouter,
                    markers: controller.markers,
                    onCameraMove: (position) {
                      // posicao da camera em movimento
                    },
                    initialCameraPosition:
                        controller.cameraPosition ?? positionCan,
                    onMapCreated: (GoogleMapController mapController) {
                      controller.controller.complete(mapController);
                    },
                  );
                }),
                Observer(builder: (context) {
                  return Visibility(
                    replacement: const SizedBox.shrink(),
                    visible: controller.exibirCaixasDeRotas ?? true,
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
                                        hintText: widget
                                            .homePassageiroController
                                            .myAddres
                                            ?.nomeDestino,
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
                                          controller
                                              .setNameMyLocal(myActualAddrees);
                                        },
                                        lastAddress: widget
                                            .homePassageiroController
                                            .addresList,
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
                                            controller.setDestinationLocal(
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
                Observer(builder: (context) {
                  return Offstage(
                      offstage:
                          controller.statusRequisicao != Status.AGUARDANDO,
                      child: DialogFindDriver(onPressed: () {
                        controller.cancelarUber();
                      }));
                }),
                Observer(builder: (context) {
                  return Visibility(
                    replacement: const SizedBox.shrink(),
                    visible: controller.exibirCaixasDeRotas ?? true,
                    child: UberButtonElevated(
                        functionPadrao: () {
                          switch (formKey.currentState?.validate()) {
                            case (false || null):
                              break;
                            case true:
                              callBottomTrips();
                              break;
                          }
                        },
                        textoPadrao:
                            controller.textoBotaoPadrao ?? "Procurar Motorista",
                        statusRequisicao: controller.statusRequisicao),
                  );
                }),
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
