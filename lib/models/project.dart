class ProjetoFotovoltaico {
  int id;
  String localizacao;
  String orientacaoTelhado;
  double inclinacaoTelhado;
  double consumoMensal;
  double potenciaModulo;
  
  ProjetoFotovoltaico({
    required this.id,
    required this.localizacao,
    required this.orientacaoTelhado,
    required this.inclinacaoTelhado,
    required this.consumoMensal,
    required this.potenciaModulo,
  });

  void cadastrar() {}
  void editar() {}
  void excluir() {}
  void listar() {}
}