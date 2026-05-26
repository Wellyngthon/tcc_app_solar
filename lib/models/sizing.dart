class Dimensionamento {
  double potenciaSistema;
  int quantidadeModulos;
  double geracaoEstimada;
  double eficiencia;
  double irradiacao;

  Dimensionamento({
    required this.potenciaSistema,
    required this.quantidadeModulos,
    required this.geracaoEstimada,
    required this.eficiencia,
    required this.irradiacao,
  });

  void calcularPotencia() {}
  void calcularModulos() {}
  void aplicarFatoresTecnicos() {}
  void estimarGeracao() {}
}