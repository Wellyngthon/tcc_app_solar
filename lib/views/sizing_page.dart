import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/sizing.dart';
import '../services/client_service.dart';
import '../services/project_service.dart';

class SizingPage extends StatefulWidget {
  const SizingPage({super.key});

  @override
  State<SizingPage> createState() => _SizingPageState();
}

class _SizingPageState extends State<SizingPage> {
  final _projectService = ProjectService();
  final _clientService = ClientService();

  String? _projetoSelecionadoId;
  Dimensionamento? _dimensionamento;

  void _calcularDimensionamento(
    ProjetoFotovoltaico projeto,
  ) {
    final resultado = Dimensionamento.calcular(
      consumoMensal: projeto.consumoMensal,
      potenciaModulo: projeto.potenciaModulo,
    );

    setState(() {
      _projetoSelecionadoId = projeto.id;
      _dimensionamento = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dimensionamento'),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: _clientService.listar(),
        builder: (context, clientesSnapshot) {
          if (clientesSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (clientesSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar clientes: '
                  '${clientesSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final clientes = clientesSnapshot.data ?? [];

          return StreamBuilder<List<ProjetoFotovoltaico>>(
            stream: _projectService.listar(),
            builder: (context, projetosSnapshot) {
              if (projetosSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (projetosSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro ao carregar projetos: '
                      '${projetosSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final projetos = projetosSnapshot.data ?? [];

              if (projetos.isEmpty) {
                return _semProjetos(context);
              }

              return _conteudo(
                context,
                projetos,
                clientes,
              );
            },
          );
        },
      ),
    );
  }

  Widget _semProjetos(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calculate,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum projeto cadastrado.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um projeto fotovoltaico '
              'antes de realizar o dimensionamento.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudo(
    BuildContext context,
    List<ProjetoFotovoltaico> projetos,
    List<Cliente> clientes,
  ) {
    ProjetoFotovoltaico? projetoSelecionado;

    if (_projetoSelecionadoId != null) {
      for (final projeto in projetos) {
        if (projeto.id == _projetoSelecionadoId) {
          projetoSelecionado = projeto;
          break;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecione o projeto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _projetoSelecionadoId,
            decoration: const InputDecoration(
              labelText: 'Projeto fotovoltaico',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.solar_power),
            ),
            items: projetos.map((projeto) {
              String nomeCliente = 'Cliente não encontrado';

              for (final cliente in clientes) {
                if (cliente.id == projeto.clienteId) {
                  nomeCliente = cliente.nome;
                  break;
                }
              }

              return DropdownMenuItem<String>(
                value: projeto.id,
                child: Text(
                  '$nomeCliente - ${projeto.localizacao}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              ProjetoFotovoltaico? projeto;

              for (final item in projetos) {
                if (item.id == value) {
                  projeto = item;
                  break;
                }
              }

              if (projeto != null) {
                _calcularDimensionamento(projeto);
              }
            },
          ),

          if (projetoSelecionado != null) ...[
            const SizedBox(height: 32),

            _buildDadosProjeto(projetoSelecionado, clientes),

            const SizedBox(height: 24),

            if (_dimensionamento != null)
              _buildResultado(_dimensionamento!),
          ],
        ],
      ),
    );
  }

  Widget _buildDadosProjeto(
    ProjetoFotovoltaico projeto,
    List<Cliente> clientes,
  ) {
    String nomeCliente = 'Cliente não encontrado';

    for (final cliente in clientes) {
      if (cliente.id == projeto.clienteId) {
        nomeCliente = cliente.nome;
        break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados do projeto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.person,
              'Cliente',
              nomeCliente,
            ),

            _buildInfoRow(
              Icons.location_on,
              'Localização',
              projeto.localizacao,
            ),

            _buildInfoRow(
              Icons.explore,
              'Orientação',
              projeto.orientacaoTelhado,
            ),

            _buildInfoRow(
              Icons.straighten,
              'Inclinação',
              '${projeto.inclinacaoTelhado.toStringAsFixed(1)}°',
            ),

            _buildInfoRow(
              Icons.bolt,
              'Consumo mensal',
              '${projeto.consumoMensal.toStringAsFixed(2)} kWh',
            ),

            _buildInfoRow(
              Icons.solar_power,
              'Potência do módulo',
              '${projeto.potenciaModulo.toStringAsFixed(0)} Wp',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultado(Dimensionamento dimensionamento) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado do dimensionamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildResultItem(
              Icons.bolt,
              'Consumo diário',
              '${dimensionamento.consumoDiario.toStringAsFixed(2)} kWh/dia',
            ),

            const Divider(),

            _buildResultItem(
              Icons.wb_sunny,
              'Irradiação média diária',
              '${Dimensionamento.irradiacaoPadrao.toStringAsFixed(2)} '
                  'kWh/m².dia',
            ),

            const Divider(),

            _buildResultItem(
              Icons.percent,
              'Eficiência do sistema',
              '${(Dimensionamento.eficienciaPadrao * 100).toStringAsFixed(0)}%',
            ),

            const Divider(),

            _buildResultItem(
              Icons.electrical_services,
              'Potência pico necessária',
              '${dimensionamento.potenciaSistema.toStringAsFixed(2)} kWp',
              destaque: true,
            ),

            const Divider(),

            _buildResultItem(
              Icons.grid_view,
              'Quantidade de módulos',
              '${dimensionamento.quantidadeModulos} módulos',
              destaque: true,
            ),

            const Divider(),

            _buildResultItem(
              Icons.solar_power,
              'Potência instalada',
              '${dimensionamento.potenciaInstalada.toStringAsFixed(2)} kWp',
              destaque: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
  IconData icon,
  String titulo,
  String valor,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$titulo: ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: valor,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildResultItem(
    IconData icon,
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: destaque ? 16 : 15,
                fontWeight:
                    destaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 17 : 15,
              fontWeight:
                  destaque ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}