import 'dart:convert';


class Addres {
  final String rua;
  final String nomeDestino;
  final String bairo;
  final String cep;
  final String cidade;
  final String numero;
  final double latitude;
  final double longitude;

  Addres({required this.bairo,required this.cep,required this.cidade,required this.latitude,required this.longitude,required this.nomeDestino,required this.numero,required this.rua});
   
  Addres.emptyAddres():
   rua ='',
   bairo ='',
   cep ='',
   cidade ='',
   latitude = 0.0,
    longitude = 0.0,
    nomeDestino ='',
    numero = '',
  super();
  
  Addres copyWith({
    String? rua,
    String? nomeDestino,
    String? bairo,
    String? cep,
    String? cidade,
    String? numero,
    double? latitude,
    double? longitude,
  }) {
    return Addres(
      rua: rua ?? this.rua,
      nomeDestino: nomeDestino ?? this.nomeDestino,
      bairo: bairo ?? this.bairo,
      cep: cep ?? this.cep,
      cidade: cidade ?? this.cidade,
      numero: numero ?? this.numero,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rua': rua,
      'nomeDestino': nomeDestino,
      'bairo': bairo,
      'cep': cep,
      'cidade': cidade,
      'numero': numero,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Addres.fromMap(Map<String, dynamic> map) {
    return Addres(
      rua: map['rua'] ?? '',
      nomeDestino: map['nomeDestino'] ?? '',
      bairo: map['bairo'] ?? '',
      cep: map['cep'] ?? '',
      cidade: map['cidade'] ?? '',
      numero: map['numero'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Addres.fromJson(String source) => Addres.fromMap(json.decode(source));
}
