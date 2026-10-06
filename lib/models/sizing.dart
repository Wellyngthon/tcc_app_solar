import 'dart:math';

class Dimensionamento {
  // Valores utilizados como premissas do dimensionamento
  static const double irradiacaoPadrao = 5.0;
  static const double eficienciaPadrao = 0.75;

  // Dados utilizados no cálculo
  final double consumoMensal;
  final double consumoDiario;
  final double potenciaModulo;

  // Resultados
  final double potenciaSistema;
  final int quantidadeModulos;
  final double potenciaInstalada;

  Dimensionamento({
    required this.consumoMensal,
    required this.consumoDiario,
    required this.potenciaModulo,
    required this.potenciaSistema,
    required this.quantidadeModulos,
    required this.potenciaInstalada,
  });

  factory Dimensionamento.calcular({
    required double consumoMensal,
    required double potenciaModulo,
  }) {
    // Consumo diário médio anual
    final consumoDiario = consumoMensal / 30;

    // Potência pico do sistema em kWp
    //
    // P_FV = C / (ηSistema × Imd)
    final potenciaSistema =
        consumoDiario / (eficienciaPadrao * irradiacaoPadrao);

    // Quantidade de módulos
    //
    // Converte a potência do sistema de kWp para Wp
    // e divide pela potência de cada módulo.
    //
    // ceil() arredonda para cima, pois não podemos
    // utilizar uma fração de módulo.
    final quantidadeModulos = (potenciaSistema * 1000 / potenciaModulo).ceil();

    // Potência realmente instalada considerando
    // a quantidade inteira de módulos.
    final potenciaInstalada =
        quantidadeModulos * potenciaModulo / 1000;

    return Dimensionamento(
      consumoMensal: consumoMensal,
      consumoDiario: consumoDiario,
      potenciaModulo: potenciaModulo,
      potenciaSistema: potenciaSistema,
      quantidadeModulos: quantidadeModulos,
      potenciaInstalada: potenciaInstalada,
    );
  }
}