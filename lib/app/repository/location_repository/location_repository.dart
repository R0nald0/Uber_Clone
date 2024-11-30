import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places/google_places.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/model/polyline_data.dart';
import 'package:uber/core/exceptions/addres_exception.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationRepositoryImpl {
  Future<Addres> setNameMyLocal(double latitude, double longitude) async {
    setLocaleIdentifier('pt_BR');
    final placeMarkers = await placemarkFromCoordinates(latitude, longitude);
    final placeMark = placeMarkers.first;
    if (kDebugMode) {
      print(placeMark);
    }
    return Addres(
        bairo: placeMark.subLocality ?? '',
        cep: placeMark.postalCode ?? '',
        cidade: placeMark.subLocality ?? '',
        latitude: latitude,
        longitude: longitude,
        nomeDestino:
            '${placeMark.thoroughfare},${placeMark.subLocality},${placeMark.subAdministrativeArea}',
        numero: placeMark.subThoroughfare ?? '',
        rua: placeMark.thoroughfare ?? '');
  }

  Future<List<Addres>> findAddresByName(String nameAddres) async {
    final apiKey = dotenv.env['maps_key'];
    if (apiKey == null) {
      throw AddresException(message: 'erroa ao buscar api key');
    }

    final googlPlace = GooglePlaces(apiKey);
    final search = await googlPlace.search.getTextSearch(nameAddres);
    final resultsSeaches = search?.results;

    if (resultsSeaches != null) {
      final adreess = resultsSeaches.map<Addres>((element) {
        final location = element.geometry?.location;
        final fomatedAdres = element.formattedAddress ?? '';
        final namePlace = element.name ?? '';

        return Addres(
          bairo: "",
          cep: "",
          cidade: "",
          latitude: location?.lat ?? 0.0,
          longitude: location?.lng ?? 0.0,
          nomeDestino: '$namePlace,$fomatedAdres',
          numero: '',
          rua: "",
        );
      }).toList();

      return adreess;
    }
    return <Addres>[];
  }

  Future<PolylineData> getRouteTrace(
      Addres myLocation, Addres myDestination,Color lineColor,int widthLine) async {
    final apiKey = dotenv.env['maps_key'];
    if (apiKey == null) {
      throw AddresException(message: 'erroa ao buscar api key');
    }

    var poliCordernate = <LatLng>[];
   

    final polyline = PolylinePoints();
    final polylineResult = await polyline.getRouteBetweenCoordinates(
        googleApiKey: apiKey,
        request: PolylineRequest(
            origin: PointLatLng(myLocation.latitude, myLocation.longitude),
            destination:
                PointLatLng(myDestination.latitude, myDestination.longitude),
            mode: TravelMode.driving)
            );

    if (polylineResult.points.isNotEmpty) {
      for (var point in polylineResult.points) {
        poliCordernate.add(LatLng(point.latitude, point.longitude));
      }
    }
    final route = _createPolineRoute(poliCordernate,lineColor,widthLine); 
    final polylineData = PolylineData(
      router: route, 
      distanceBetween: polylineResult.distanceTexts?.first ?? '', 
      durationBetweenPoints: polylineResult.durationTexts?.first ?? '',
      distanceInt: polylineResult.totalDistanceValue ?? 0,
      duration: polylineResult.totalDurationValue ?? 0

      );  
    return polylineData;
  }

  Map<PolylineId, Polyline> _createPolineRoute(
      List<LatLng> poliCordernate,Color lineColor,int widthLine) {
      Map<PolylineId, Polyline> polylines = {};
           
    if (poliCordernate.isNotEmpty) {
      const id = PolylineId('poly');
      final poliRouter = Polyline(
        polylineId: id,
        color: lineColor,
        points: poliCordernate,
        width: 5
      );
      polylines[id] = poliRouter;
    }
    return polylines;
  }
}
