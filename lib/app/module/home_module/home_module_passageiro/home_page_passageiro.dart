import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:mobx/mobx.dart';
import 'package:uber/Rotas.dart';
import 'package:uber/app/module/core/widgets/uber_list_trip.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/widgets/option_button.dart';
import 'package:uber_clone_core/uber_clone_core.dart';
import 'package:validatorless/validatorless.dart';

part 'widgets/uber_button_elevated.dart';
part 'widgets/dialog_find_driver.dart';
part 'widgets/dialog_values_info_trip.dart';

part 'widgets/message_ia-widget.dart';

class HomePassageiroPage extends StatefulWidget {
  final HomePassageiroController homePassageiroController;
  const HomePassageiroPage({super.key, required this.homePassageiroController});

  @override
  State<StatefulWidget> createState() => HomePassageiroPageState();
}

class HomePassageiroPageState extends State<HomePassageiroPage>
    with DialogLoader {
  final disposerReactions = <ReactionDisposer>[];
  final placeEC = TextEditingController();
  var address = <Address>[];
  int? _idPaymentType;

  CameraPosition positionCan =
      const CameraPosition(target: LatLng(-13.008864, -38.528722), zoom: 12);

  final formKey = GlobalKey<FormState>();
  List<String> listMenu = ["Pefil", "Deslogar"];

  void initReaction() async {
    final HomePassageiroPage(:homePassageiroController) = widget;

    final userReaction = reaction<Usuario?>(
        (_) => homePassageiroController.usuario, (usuario) async {
      if (usuario == null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Rotas.ROUTE_LOGIN, (_) => false);
        return;
      }
      await widget.homePassageiroController.getMessageIa();
    });

    final erroReaction = reaction<String?>(
        (_) => homePassageiroController.errorMensager, (error) {
      if (error != null) {
        callSnackBar(error);
      }
    });

    final requicaoReaction = reaction<Requisicao?>(
        (_) => homePassageiroController.requisicao, (requisicao) async {
    //  hideLoader(); 
      if (requisicao == null ||
          requisicao.id == null ||
          requisicao.status == RequestState.pagamento_confirmado) {
        homePassageiroController.statusUberNaoChamdo();
      } else {
      //  showLoaderDialog();
        await widget.homePassageiroController.observerRequestState();
       // hideLoader();
      }
    });

    final loadingReaction = autorun((_){
        if(widget.homePassageiroController.loading == true){
            showLoaderDialog();
            return;
        }
          hideLoader();
    });

    final serviceEnableReaction = reaction<bool>(
        (_) => homePassageiroController.isServiceEnable, (isServiceEnable) {
      if (!isServiceEnable) {
        callSnackBar("Ative sua localização");
      }
    });

    final locationPermissionReaction = reaction<LocationPermission?>(
        (_) => homePassageiroController.locationPermission, (permission) {
      if (permission == LocationPermission.denied) {
      //  showLoaderDialog();
        dialogLocationPermissionDenied(() {
          homePassageiroController.getPermissionLocation();
        });
      //  hideLoader();
      } else if (permission == LocationPermission.deniedForever) {
        dialogLocationPermissionDeniedForeve(() {
          Geolocator.openAppSettings();
        });
      }
    });
    homePassageiroController.getPermissionLocation();

   // showLoaderDialog();
    await homePassageiroController.getDataUSerOn();
   // hideLoader();

    disposerReactions.addAll([
      erroReaction,
      userReaction,
      requicaoReaction,
      serviceEnableReaction,
      locationPermissionReaction,
      loadingReaction
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    visible: controller.exibirCaixasDeRotas == true,
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
                                          controller.setNameMyLocal(
                                              myActualAddrees,
                                              'destination1.png');
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
                                                destinationAddres,
                                                'destination2.png');
                                          },
                                          lastAddress: widget
                                              .homePassageiroController
                                              .addresList,
                                        );
                                      }),
                                    ),
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
                        controller.statusRequisicao != RequestState.finalizado,
                    child: controller.requisicao != null
                        ? DialogValuesInfoTrip(
                            request: controller.requisicao!,
                          )
                        : Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              width: MediaQuery.sizeOf(context).width * .70,
                              height: MediaQuery.of(context).size.height * 0.30,
                              decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(220),
                                  borderRadius: BorderRadius.circular(32)),
                              child: Column(
                                spacing: 30,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Algo deu errado,dados da viagem não disponivel",
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        controller.reportError();
                                      },
                                      child: const Text(
                                        "Reportar Erro",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ],
                              ),
                            ),
                          ),
                  );
                }),
                Observer(builder: (context) {
                  return Offstage(
                      offstage: controller.statusRequisicao !=
                          RequestState.aguardando,
                      child: DialogFindDriver(onPressed: () {
                        controller.cancelarUber();
                      }));
                }),
                Observer(builder: (context) {
                  final HomePassageiroController(:messageIa) =
                      widget.homePassageiroController;
                  return Visibility(
                    replacement: const SizedBox.shrink(),
                    visible: controller.statusRequisicao ==
                          RequestState.nao_chamado,
                    child: MessageIaWidget(
                      isMe: true,
                      messageIa: messageIa,
                      onSelected: handleIaOption,
                      onTap: () {
                        controller.getMessageIa();
                      },
                    ),
                  );
                }),
                Observer(builder: (context) {
                  return Visibility(
                    replacement: const SizedBox.shrink(),
                    visible: controller.exibirCaixasDeRotas == true,
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

  void handleIaOption(OptionIa option) async{
     
       final HomePassageiroController(:closeIaMessage,) = widget.homePassageiroController;
       if(option == OptionIa.NOTHING){
         closeIaMessage();
          return;
       }
      
     closeIaMessage();
     final chosedDestination  = await Navigator.of(context).pushNamed(Rotas.ROUTE_CHAT_PAGE,arguments:option);

     if(chosedDestination != null && chosedDestination is String){
        widget.homePassageiroController.getDestinatinationLocalByiaSugestion(chosedDestination);
     }
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

