import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:uber/controller/Banco.dart';
import 'package:uber/app/model/Marcador.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/model/Usuario.dart';
import 'package:uber/app/util/Status.dart';
import 'package:uber/app/util/UsuarioFirebase.dart';
import '../../../Rotas.dart';



class ViewCorrida extends StatefulWidget{
  late String idRequisicao;

  ViewCorrida(this.idRequisicao, {super.key});

  @override
  State<StatefulWidget> createState() => ViewCorridaState();
}

class ViewCorridaState extends State<ViewCorrida> {

  final Completer<GoogleMapController> _comtroler = Completer();
  CameraPosition _cameraPositionViagem =CameraPosition(
      target:LatLng(-13.001478,-38.499390),
  );
  late StreamSubscription<DocumentSnapshot> streamSubscription;

   Set<Marker> marcadoPosicao ={};
  late BitmapDescriptor imgMotorista ;
  String status ="";

  //CONFIGURACAO TELA
  late String _txBotaoPadrao ="";
  late Color _corPadrao =Color( 0xffa9a9a9);
  late Function _funcaoPadrao = _aceitarCorrida();
  late Position localMotorista  ;

  //Dados Requisicao
  Map<String,dynamic> _dadosRequisicaoPassageiro={};
  Map<String,dynamic> _dadosRequisicaoDestino={};
  Map<String,dynamic> _dadosRequisicaoMotorista={};

  String nomePassageiro ="";
  late Position _localPassageiro ;

  late double _passageiroLat ;
  late double _passageiroLong;
  late String valorFinalCorrida ;

  // Metodos
  _onMapCreated(GoogleMapController googleMapController){
     _comtroler.complete(googleMapController);
  }

  _moverCamera(CameraPosition cameraPosition) async{
      GoogleMapController mapController = await _comtroler.future;
      mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)
      );
  }

  _moverCameraBound( LatLngBounds latLngBounds) async{
     GoogleMapController mapController = await _comtroler.future;
     mapController.animateCamera(CameraUpdate.newLatLngBounds(
       latLngBounds,
       100
     ));
  }

  _getLastPosition() async{
    LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high,distanceFilter: 10);

    StreamSubscription<Position> positions= await Geolocator.getPositionStream(
       locationSettings: locationSettings,
    ).listen((Position position) {

      if(position != null){

        setState(() {
          _cameraPositionViagem=CameraPosition(
              target:LatLng(position.latitude,position.longitude)
              ,zoom:18
          );
          localMotorista = position;
           _addMarcador(position, 'motorista', 'Meu local');
          _moverCamera(_cameraPositionViagem);
        });
      }
    });

  }

  _getPosition()async{
     LocationSettings settings = LocationSettings(
       accuracy: LocationAccuracy.high,
       distanceFilter: 5
     );

     StreamSubscription<Position> positionSt = await Geolocator.getPositionStream(locationSettings: settings)
    .listen((Position position) {
              if(position != null){
                UsuarioFirebase.atualizarPosicaoUsuario(
                    widget.idRequisicao,
                    "motorista",
                    position.latitude,
                    position.longitude);

              }else{
                localMotorista = position;
              }

     });

  }

  _getPermissioPosicao() async{
    LocationPermission  permission = await Geolocator.checkPermission();
    bool isSeviceEnable = await Geolocator.isLocationServiceEnabled();

    if(!isSeviceEnable){
       return print("Localizaçao desativada");
    }
    if(permission == LocationPermission.denied && permission == LocationPermission.deniedForever){
       Geolocator.requestPermission();
       Geolocator.checkPermission();
    }else{
      Geolocator.requestPermission();
      _getLastPosition();
    }
  }

  _alterarBotoes(String textoBotao,Color cor,Function function){
    if(mounted){
      setState(() {
        _txBotaoPadrao =textoBotao;
        _corPadrao = cor;
        _funcaoPadrao =function;
      });
    }
  }

  _statusUberAguadando() async {
     status ="${nomePassageiro} - Aguardando ";
    _alterarBotoes(
        "Aceitar Corrida", Colors.green , (){_aceitarCorrida();});
     recuperarDadosRequisicao();
    _getPermissioPosicao();
  }

  _statusUberACaminho() async {

     _alterarBotoes("Iniciar", Colors.amber,(){_iniciarCorrida();} );
     _getPosition();

      DocumentSnapshot  dados = await UsuarioFirebase.getDadosRequisicao(widget.idRequisicao);

      _dadosRequisicaoMotorista = dados.get('motorista');
      _dadosRequisicaoPassageiro=dados.get("passageiro");
       nomePassageiro =_dadosRequisicaoPassageiro['nome'];

       status="A Caminho de ${nomePassageiro}";

      double mLat  = _dadosRequisicaoMotorista['latitude'];
      double mLong = _dadosRequisicaoMotorista['longitude'];

        _passageiroLat =   _dadosRequisicaoPassageiro['latitude'];
        _passageiroLong = _dadosRequisicaoPassageiro['longitude'];

        Marcador marcadorOrigem = Marcador(
              LatLng(mLat,mLong),
             'motorista',
              'Meu-Local'
        );
        Marcador marcadorDestino = Marcador(
            LatLng(_passageiroLat,_passageiroLong),
            'passageiro',
             nomePassageiro
        );

        _exibirPosicoesMarcadores(marcadorOrigem, marcadorDestino);
  }

  _statusUberEmViagem() async{

     _alterarBotoes("Finalizar Corrida",
         Colors.red,
         (){ finalizarCorrida();}
     );

     _getPosition();
     DocumentSnapshot  dados = await UsuarioFirebase.getDadosRequisicao(widget.idRequisicao);

     _dadosRequisicaoMotorista = dados.get('motorista');
     _dadosRequisicaoDestino=dados.get("destino");
     setState(() {
       status ="Destino-"+ _dadosRequisicaoDestino['rua'];
     });

      double latOrigem = _dadosRequisicaoMotorista['latitude'];
      double longOrigem = _dadosRequisicaoMotorista['longitude'];

      double latDestino =  _dadosRequisicaoDestino['latitude'];
      double longDestino = _dadosRequisicaoDestino['longitude'];

     Marcador marcadorOrigemVieagem = Marcador(LatLng(latOrigem,longOrigem) ,"motorista", 'Meu local');
     Marcador marcadorDestino = Marcador(LatLng(latDestino,longDestino) ,"destino", status);

     _exibirPosicoesMarcadores(marcadorOrigemVieagem, marcadorDestino);
  }

  _statusFinalizado()async{   //TODO VERIFICAR METODO
    marcadoPosicao.clear();

    DocumentSnapshot snapshot = await UsuarioFirebase.getDadosRequisicao(widget.idRequisicao);

    double latDestinoFinal  =  snapshot['motorista']['latitude'];
    double longDestinoFinal =  snapshot['motorista']['longitude'];

    Position positioFinal = Position(
        longitude:longDestinoFinal, latitude: latDestinoFinal,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        timestamp: DateTime.now(),
        accuracy:  0,
        altitude: 18,
        heading: 0,
        speed: 0,
        speedAccuracy: 0
    ) ;
    _addMarcador(positioFinal,"destino", 'Destino');

   setState(() {
     _cameraPositionViagem = CameraPosition(
         target:LatLng(positioFinal.latitude,positioFinal.longitude),zoom: 18
     ) ;
   });

    _moverCamera(_cameraPositionViagem);

    String custo =  snapshot['valorCorrida'];
    status ="Confirme o Valor R\$ ${custo}" ;
    _alterarBotoes("Confirmar Valor - R\$ ${custo}", Colors.green, (){confirmarValor();});
  }

  _stausConfirmado(){
       if(streamSubscription != null){
         _dadosRequisicaoPassageiro={};
         _dadosRequisicaoDestino = {};
         streamSubscription.cancel();
       }

  }

  @override
  void initState()  {
    super.initState() ;
    listenerStatusRequisiscao();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( status),
      ),
      body: Container(
        padding: EdgeInsets.all(2),
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _cameraPositionViagem,
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              markers: marcadoPosicao,
            ),
            Positioned(
              bottom: 20, left: 0,right: 0,
               child: Padding(
                 padding: EdgeInsets.only(left: 60,right: 60),
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                         backgroundColor: _corPadrao,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                       elevation: 5,
                       padding: EdgeInsets.fromLTRB(32, 16, 32, 16)
                     ),
                     onPressed: () { _funcaoPadrao(); },
                     child:Text(_txBotaoPadrao) ,
                   )
               )
            )
          ],
        )
      ),
    );
  }

  _exibirPosicoesMarcadores(Marcador marcadorOrigem,Marcador marcadorDestino){

    double mLat =marcadorOrigem.local.latitude;
    double mLong =marcadorOrigem.local.longitude;

    double destinoLat =marcadorDestino.local.latitude;
    double destionoLong =marcadorDestino.local.longitude;

    double nLat,nLong,sLat,sLong;

    if(mLat <= destinoLat){
      sLat =mLat;
      nLat =destinoLat;

    }else{
      sLat =destinoLat;
      nLat=mLat;
    }

    if(mLong <= destionoLong){
      sLong =mLong;
      nLong =destionoLong;

    }else{
      sLong =destionoLong;
      nLong=mLong;
    }

   Position localOrigem = Position(longitude:mLong, latitude: mLat,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        accuracy:  0,
        altitude: 18,
        heading: 0,
        speed: 0,
        speedAccuracy: 0
    ) ;
   Position _localDestino = Position(longitude:destionoLong, latitude: destinoLat,
     altitudeAccuracy: 0,
     headingAccuracy: 0,
        timestamp: DateTime.now(),
        accuracy:  0,
        altitude: 18,
        heading: 0,
        speed: 0,
        speedAccuracy: 0
    ) ;

    _moverCameraBound(
        LatLngBounds(
          northeast: LatLng(nLat,nLong),
          southwest: LatLng(sLat,sLong),
        )
    );

     _addMarcador(localOrigem,marcadorOrigem.Caminho,marcadorOrigem.titulo);
     _addMarcador(_localDestino,marcadorDestino.Caminho,marcadorDestino.titulo);
  }

  _addMarcador(Position position,String caminho,String titulo) async {

       await BitmapDescriptor.fromAssetImage(
           ImageConfiguration(size: Size(48,48) ) ,
           "images/${caminho}.png").then((icon){
         setState(() {
           gerarMarcador(position,icon ,titulo,caminho);
         });
       });
  }

  gerarMarcador(Position position,BitmapDescriptor icon,String titulo,String id){
    Marker marker = Marker(
        markerId:   MarkerId(id),
      position:     LatLng(position.latitude,position.longitude),
      infoWindow:   InfoWindow(title: titulo),
      icon: icon

    );
      marcadoPosicao.add(marker);

  }

  _aceitarCorrida() async{

     Usuario usuarioMotorista = await UsuarioFirebase.recuperarDadosPassageiro();
     usuarioMotorista.copyWith(latitude: localMotorista.latitude);
     usuarioMotorista.copyWith(longitude: localMotorista.longitude);

     Banco.db.collection("requisicao")
         .doc(widget.idRequisicao).update({
         "motorista" :  usuarioMotorista.toMapUp(),
         "status"  : Status.A_CAMINHO
       }
     ).then((_) async{

       String idPassageiro =_dadosRequisicaoPassageiro['idUsuario'];
       Banco.db.collection("requisicao-ativa").doc(idPassageiro).update({
         "status" : Status.A_CAMINHO
       });

       // REQUISICAO  ATIVA-MOTORISTA
       requisicaoAtivaMotorista();

     }).catchError((erro){
       print("dado "  + erro);
     });

  }

  requisicaoAtivaMotorista( ) async{

    User? user = await UsuarioFirebase.getFirebaseUser();
    String? idMotorista = user?.uid.toString();

    await Banco.db.collection("requisicao-ativa-motorista")
        .doc(idMotorista).set({
      "id_motorista" : idMotorista,
      "id_requisicao" : widget.idRequisicao,
      "status" : Status.A_CAMINHO
    });
  }

  recuperarDadosRequisicao() async{

    DocumentSnapshot snapshot = await UsuarioFirebase.getDadosRequisicao(widget.idRequisicao);

       _dadosRequisicaoPassageiro = snapshot.get("passageiro");
       _dadosRequisicaoDestino = snapshot.get("destino");
       _dadosRequisicaoMotorista  = snapshot.get('motorista');

         nomePassageiro  = _dadosRequisicaoPassageiro['nome'] ;
        _passageiroLat  = _dadosRequisicaoPassageiro["latitude"];
        _passageiroLong = _dadosRequisicaoPassageiro["longitude"];
  }

  listenerStatusRequisiscao( ) async {
         
     streamSubscription = await Banco.db.collection("requisicao").doc(widget.idRequisicao)
          .snapshots()
          .listen((snapshot) {
              if(snapshot.data() != null){

                   switch(snapshot.get("status")){
                     case Status.AGUARDANDO:
                         _statusUberAguadando();
                       break;
                     case Status.A_CAMINHO:
                        _statusUberACaminho();
                       break;

                     case Status.EM_VIAGEM:
                       _statusUberEmViagem();
                       break;
                     case Status.FINALIZADO:
                       _statusFinalizado();
                       break;
                     case Status.CONFIRMADA:
                         _stausConfirmado();
                       break;
                     case Status.CANCELADA:
                       break;
                   }
              }
      });
  }

   _iniciarCorrida() {
    Banco.db.collection("requisicao").doc(widget.idRequisicao)
        .update({
        "origem" :{
          "latitude" : _dadosRequisicaoMotorista['latitude'],
          "longitude" : _dadosRequisicaoMotorista['longitude']
        },
        "status" : Status.EM_VIAGEM
    });
     String idPassageiro = _dadosRequisicaoPassageiro['idUsuario'];
      Banco.db.collection("requisicao-ativa").doc(idPassageiro).update({
        'status' : Status.EM_VIAGEM
      });

    String idMotorista = _dadosRequisicaoMotorista['idUsuario'];
    Banco.db.collection("requisicao-ativa-motorista").doc(idMotorista).update({
       'status' : Status.EM_VIAGEM
    });
    marcadoPosicao.clear();
   }

   @override
  void dispose() {
    super.dispose();
     streamSubscription.cancel();
  }

  finalizarCorrida() async{
     recuperarDadosRequisicao();
     Banco.db.collection("requisicao").doc(widget.idRequisicao)
         .update({
       'status': Status.FINALIZADO,
     });

     String idPassageiro = _dadosRequisicaoPassageiro['idUsuario'];
     Banco.db.collection('requisicao-ativa').doc(idPassageiro).update({
       'status' : Status.FINALIZADO
     });
     String idMotorista = _dadosRequisicaoMotorista['idUsuario'];
     Banco.db.collection('requisicao-ativa-motorista').doc(idMotorista).update({
       'status' : Status.FINALIZADO
     });
  }

  confirmarValor()async{
    Banco.db.collection('requisicao').doc(widget.idRequisicao)
        .update({
      'status' :Status.CONFIRMADA
    });
    DocumentSnapshot snapshot = await UsuarioFirebase.getDadosRequisicao(widget.idRequisicao);
     String idPass =snapshot['passageiro']['idUsuario'];
     print("teste " + idPass.toString());
      Banco.db.collection('requisicao-ativa').doc(idPass).delete();

    String idMoto = snapshot['motorista']['idUsuario'];
      Banco.db.collection('requisicao-ativa-motorista').doc(idMoto).delete();
    Navigator.pushNamedAndRemoveUntil(context, Rotas.ROUTE_VIEWMOTORISTA, (route) => false);
  }
}