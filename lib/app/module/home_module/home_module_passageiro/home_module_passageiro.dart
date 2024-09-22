import 'package:flutter_modular/flutter_modular.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_page_passageiro.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/home_passageiro_controller.dart';
import 'package:uber/app/repository/location_repository/location_repository.dart';
import 'package:uber/app/repository/mapsCameraRepository/maps_camera_repository.dart';
import 'package:uber/app/repository/requisition_repository/i_requisition_repository.dart';
import 'package:uber/app/repository/requisition_repository/impl/requisition_repository.dart';
import 'package:uber/app/services/location_service/location_service_impl.dart';
import 'package:uber/app/services/trip_service/trip_service.dart';
import 'package:uber/app/services/user_service/requisicao_service/I_requisicao_service.dart';
import 'package:uber/app/services/user_service/requisicao_service/impl/requisicao_service.dart';

class HomeModulePassageiro extends Module {
  
  @override
  void binds(Injector i) {
      i.addLazySingleton(LocationRepositoryImpl.new);
      i.addLazySingleton(TripService.new);
      i.addLazySingleton<IRequisitionRepository>(()=>RequisitionRepository(logger: Modular.get()));
      i.addLazySingleton<IRequisicaoService>(()=> RequisicaoService(requisitionRepository: Modular.get()));
      i.addLazySingleton(LocationServiceImpl.new);
      i.addLazySingleton(MapsCameraService.new);
      i.addLazySingleton( () => HomePassageiroController(
        authRepository: Modular.get(),
        userService: Modular.get(),
        requisicaoService: Modular.get(),
        locattionService: Modular.get(),
        cameraService: Modular.get(),
        tripService: Modular.get()
      ));
    super.binds(i);
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    
    r.child('/', child: (_) => HomePassageiroPage(homePassageiroController: Modular.get() ));
  }
}