
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/client.dart';
import '../models/project.dart';
import '../models/sizing.dart';

class RelatorioService {
  static Future<Uint8List> gerarPdf({
    required Cliente cliente,
    required ProjetoFotovoltaico projeto,
    required double tarifaKwh,
    required double custoInstalacao,
  }) async {
    final dimensionamento = Dimensionamento.calcular(
      consumoMensal: projeto.consumoMensal,
      potenciaModulo: projeto.potenciaModulo,
    );

    final geracaoMensal = dimensionamento.potenciaInstalada *
        Dimensionamento.irradiacaoPadrao *
        30 *
        Dimensionamento.eficienciaPadrao;

    final economiaMensal = geracaoMensal * tarifaKwh;
    final economiaAnual = economiaMensal * 12;

    final paybackMeses = economiaMensal > 0
        ? custoInstalacao / economiaMensal
        : 0.0;

    final pdf = pw.Document();
    final dataGeracao = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'RELATÓRIO FOTOVOLTAICO',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Gerado em ${_data(dataGeracao)}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 24),

          _secao('1. DADOS DO CLIENTE'),
          _linha('Nome', cliente.nome),
          _linha('CPF', cliente.cpf),
          _linha('Telefone', cliente.telefone),
          _linha('Endereço', cliente.endereco),

          pw.SizedBox(height: 16),
          _secao('2. DADOS DO PROJETO'),
          _linha('Localização', projeto.localizacao),
          _linha('Orientação do telhado', projeto.orientacaoTelhado),
          _linha(
            'Inclinação do telhado',
            '${_numero(projeto.inclinacaoTelhado)}°',
          ),
          _linha(
            'Consumo mensal',
            '${_numero(projeto.consumoMensal)} kWh',
          ),
          _linha(
            'Potência de cada módulo',
            '${_numero(projeto.potenciaModulo)} Wp',
          ),

          pw.SizedBox(height: 16),
          _secao('3. DIMENSIONAMENTO E GERAÇÃO'),
          _linha(
            'Consumo diário médio',
            '${_numero(dimensionamento.consumoDiario)} kWh/dia',
          ),
          _linha(
            'Irradiação de referência',
            '${_numero(Dimensionamento.irradiacaoPadrao)} h/dia',
          ),
          _linha(
            'Eficiência considerada',
            '${_numero(Dimensionamento.eficienciaPadrao * 100)}%',
          ),
          _linha(
            'Potência requerida',
            '${_numero(dimensionamento.potenciaSistema)} kWp',
          ),
          _linha(
            'Quantidade de módulos',
            '${dimensionamento.quantidadeModulos}',
          ),
          _linha(
            'Potência instalada',
            '${_numero(dimensionamento.potenciaInstalada)} kWp',
          ),
          _linha(
            'Geração mensal estimada',
            '${_numero(geracaoMensal)} kWh/mês',
            destaque: true,
          ),

          pw.SizedBox(height: 16),
          _secao('4. ECONOMIA ESTIMADA'),
          _linha(
            'Tarifa informada',
            '${_moeda(tarifaKwh)}/kWh',
          ),
          _linha(
            'Economia mensal estimada',
            _moeda(economiaMensal),
            destaque: true,
          ),
          _linha(
            'Economia anual estimada',
            _moeda(economiaAnual),
            destaque: true,
          ),

          pw.SizedBox(height: 16),
          _secao('5. INVESTIMENTO E PAYBACK'),
          _linha(
            'Custo total da instalação',
            _moeda(custoInstalacao),
          ),
          _linha(
            'Payback simples estimado',
            '${_numero(paybackMeses / 12)} anos '
                '(${_numero(paybackMeses)} meses)',
            destaque: true,
          ),

          pw.SizedBox(height: 24),
          pw.Text(
            'Observações técnicas',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Este relatório apresenta estimativas calculadas com '
            'base nos dados informados e nas premissas adotadas pelo '
            'aplicativo. A geração utiliza 30 dias por mês, irradiação '
            'de referência de ${_numero(Dimensionamento.irradiacaoPadrao)} '
            'h/dia e eficiência de '
            '${_numero(Dimensionamento.eficienciaPadrao * 100)}%. '
            'A economia considera a geração estimada multiplicada '
            'pela tarifa informada. O payback é simples e não considera '
            'custos de manutenção, degradação dos módulos, reajustes '
            'tarifários, financiamento ou particularidades da '
            'compensação de energia. Os resultados reais podem variar.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _secao(String titulo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      margin: const pw.EdgeInsets.only(bottom: 8),
      color: PdfColors.green100,
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.green900,
        ),
      ),
    );
  }

  static pw.Widget _linha(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              titulo,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              valor,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: destaque
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _numero(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  static String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  static String _data(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year}';
}
