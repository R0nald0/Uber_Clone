
class Destino {
  late String _rua;
  late String _nomeDestino;
  late String _bairo;
  late String _cep;
  late String _cidade;
  late String _numero;
  late double _latitude;
  late double _longitude;


  Destino();


  String get nomeDestino => _nomeDestino;

  set nomeDestino(String value) {
    _nomeDestino = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get bairo => _bairo;

  set bairo(String value) {
    _bairo = value;
  }

  String get rua => _rua;

  set rua(String value) {
    _rua = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }
}