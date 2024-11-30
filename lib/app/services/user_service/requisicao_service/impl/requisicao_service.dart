import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/repository/requisition_repository/i_requisition_repository.dart';
import 'package:uber/app/services/user_service/requisicao_service/I_requisicao_service.dart';

class RequisicaoService implements IRequisicaoService {
  final IRequisitionRepository _requisicaoRepository;

  RequisicaoService({required IRequisitionRepository requisitionRepository})
      : _requisicaoRepository = requisitionRepository;

  Future<Requisicao?> verfyActivatedRequisition(String idUser) => _requisicaoRepository.verfyActivatedRequisition(idUser);
}
