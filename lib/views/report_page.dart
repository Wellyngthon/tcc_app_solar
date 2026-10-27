
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../services/client_service.dart';
import '../services/project_service.dart';
import '../services/report_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _clientService = ClientService();
  final _projectService = ProjectService();

  final _tarifaController = TextEditingController();
  final _custoController = TextEditingController();

  late final Stream<List<Cliente>> _clientesStream;
  late final Stream<List<ProjetoFotovoltaico>> _projetosStream;

  String? _clienteSelecionadoId;
  String? _projetoSelecionadoId;
  bool _gerando = false;

  @override
  void initState() {
    super.initState();
    _clientesStream = _clientService.listar();
    _projetosStream = _projectService.listar();
  }

  @override
  void dispose() {
    _tarifaController.dispose();
    _custoController.dispose();
    super.dispose();
  }

  double? _converterNumero(String texto) {
    return double.tryParse(
      texto.trim().replaceAll(',', '.'),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _gerarRelatorio(
    Cliente cliente,
    ProjetoFotovoltaico projeto,
  ) async {
    final tarifa = _converterNumero(_tarifaController.text);
    final custo = _converterNumero(_custoController.text);

    if (tarifa == null || tarifa <= 0) {
      _mostrarMensagem(
        'Informe uma tarifa de energia válida, em R\$/kWh.',
      );
      return;
    }

    if (custo == null || custo <= 0) {
      _mostrarMensagem(
        'Informe um custo de instalação válido.',
      );
      return;
    }

    setState(() => _gerando = true);

    try {
      final bytes = await RelatorioService.gerarPdf(
        cliente: cliente,
        projeto: projeto,
        tarifaKwh: tarifa,
        custoInstalacao: custo,
      );

      if (!mounted) return;

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'relatorio_solar_${projeto.id}.pdf',
      );
    } catch (e) {
      if (mounted) {
        _mostrarMensagem('Erro ao gerar o PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _gerando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Fotovoltaico'),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: _clientesStream,
        builder: (context, snapshotClientes) {
          if (snapshotClientes.hasError) {
            return const Center(
              child: Text('Erro ao carregar clientes.'),
            );
          }

          if (!snapshotClientes.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final clientes = snapshotClientes.data!;
          final clienteSelecionado = clientes
              .where((c) => c.id == _clienteSelecionadoId)
              .firstOrNull;

          return StreamBuilder<List<ProjetoFotovoltaico>>(
            stream: _projetosStream,
            builder: (context, snapshotProjetos) {
              if (snapshotProjetos.hasError) {
                return const Center(
                  child: Text('Erro ao carregar projetos.'),
                );
              }

              if (!snapshotProjetos.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final projetos = snapshotProjetos.data!
                  .where(
                    (p) => p.clienteId == _clienteSelecionadoId,
                  )
                  .toList();

              final projetoSelecionado = projetos
                  .where((p) => p.id == _projetoSelecionadoId)
                  .firstOrNull;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Gerar relatório em PDF',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecione o cliente e o projeto para calcular '
                    'a geração, a economia estimada e o payback.',
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: clienteSelecionado?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: clientes.map((cliente) {
                      return DropdownMenuItem(
                        value: cliente.id,
                        child: Text(
                          cliente.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _gerando
                        ? null
                        : (id) {
                            setState(() {
                              _clienteSelecionadoId = id;
                              _projetoSelecionadoId = null;
                            });
                          },
                  ),

                  if (clientes.isEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhum cliente cadastrado. Cadastre um '
                      'cliente antes de gerar o relatório.',
                    ),
                  ],

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    value: projetoSelecionado?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Projeto fotovoltaico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.solar_power),
                    ),
                    hint: Text(
                      clienteSelecionado == null
                          ? 'Selecione primeiro um cliente'
                          : 'Selecione um projeto',
                    ),
                    items: projetos.map((projeto) {
                      return DropdownMenuItem(
                        value: projeto.id,
                        child: Text(
                          projeto.localizacao,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: clienteSelecionado == null || _gerando
                        ? null
                        : (id) {
                            setState(() {
                              _projetoSelecionadoId = id;
                            });
                          },
                  ),

                  if (clienteSelecionado != null &&
                      projetos.isEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Este cliente ainda não possui projetos '
                      'fotovoltaicos cadastrados.',
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Dados financeiros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _tarifaController,
                    enabled: !_gerando,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9,.]'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tarifa de energia (R\$/kWh)',
                      hintText: 'Ex.: 0,85',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bolt),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _custoController,
                    enabled: !_gerando,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9,.]'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Custo total da instalação (R\$)',
                      hintText: 'Ex.: 18000,00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FilledButton.icon(
                    onPressed: _gerando ||
                            clienteSelecionado == null ||
                            projetoSelecionado == null
                        ? null
                        : () => _gerarRelatorio(
                              clienteSelecionado,
                              projetoSelecionado,
                            ),
                    icon: _gerando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(
                      _gerando
                          ? 'Gerando relatório...'
                          : 'Gerar relatório PDF',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
