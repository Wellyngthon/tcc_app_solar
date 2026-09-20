class ProjetoFotovoltaico {
  final String id;
  final String clienteId;
  final String localizacao;
  final String orientacaoTelhado;
  final double inclinacaoTelhado;
  final double consumoMensal;
  final double potenciaModulo;

  ProjetoFotovoltaico({
    required this.id,
    required this.clienteId,
    required this.localizacao,
    required this.orientacaoTelhado,
    required this.inclinacaoTelhado,
    required this.consumoMensal,
    required this.potenciaModulo,
  });

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'localizacao': localizacao,
      'orientacaoTelhado': orientacaoTelhado,
      'inclinacaoTelhado': inclinacaoTelhado,
      'consumoMensal': consumoMensal,
      'potenciaModulo': potenciaModulo,
    };
  }

  factory ProjetoFotovoltaico.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ProjetoFotovoltaico(
      id: id,
      clienteId: map['clienteId'] ?? '',
      localizacao: map['localizacao'] ?? '',
      orientacaoTelhado: map['orientacaoTelhado'] ?? '',
      inclinacaoTelhado: (map['inclinacaoTelhado'] ?? 0).toDouble(),
      consumoMensal: (map['consumoMensal'] ?? 0).toDouble(),
      potenciaModulo: (map['potenciaModulo'] ?? 0).toDouble(),
    );
  }
}