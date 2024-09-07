
import 'package:geolocator/geolocator.dart';

class LocationServiceImpl {
   Future<LocationPermission> getPermissionLocation() async {

    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        return  await Geolocator.requestPermission();
        
      case LocationPermission.deniedForever:
         return LocationPermission.deniedForever;
      
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        return permission;

    }
  }
  
  void getUserLocation() {} 
}