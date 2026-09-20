import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../services/client_service.dart';
import '../services/project_service.dart';
import 'project_register_page.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  Future<void> _excluirProjeto(
    BuildContext context,
    ProjetoFotovoltaico projeto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir projeto'),
          content: const Text(
            'Tem certeza que deseja excluir este projeto?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await ProjectService().excluir(projeto.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projeto excluído com sucesso.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir projeto: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectService = ProjectService();
    final clientService = ClientService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos Fotovoltaicos'),
      ),

      body: StreamBuilder<List<Cliente>>(
        stream: clientService.listar(),
        builder: (context, clientesSnapshot) {
          if (clientesSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (clientesSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar clientes: '
                '${clientesSnapshot.error}',
              ),
            );
          }

          final clientes = clientesSnapshot.data ?? [];

          return StreamBuilder<List<ProjetoFotovoltaico>>(
            stream: projectService.listar(),
            builder: (context, projetosSnapshot) {
              if (projetosSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (projetosSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar projetos: '
                    '${projetosSnapshot.error}',
                  ),
                );
              }

              final projetos = projetosSnapshot.data ?? [];

              if (projetos.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.solar_power,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum projeto cadastrado.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toque no botão + para cadastrar '
                          'um novo projeto.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projetos.length,
                itemBuilder: (context, index) {
                  final projeto = projetos[index];

                  String nomeCliente = 'Cliente não encontrado';

                  for (final cliente in clientes) {
                    if (cliente.id == projeto.clienteId) {
                      nomeCliente = cliente.nome;
                      break;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.solar_power),
                      ),

                      title: Text(
                        nomeCliente,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Localização: '
                              '${projeto.localizacao}',
                            ),
                            Text(
                              'Orientação: '
                              '${projeto.orientacaoTelhado}',
                            ),
                            Text(
                              'Inclinação: '
                              '${projeto.inclinacaoTelhado}°',
                            ),
                            Text(
                              'Consumo: '
                              '${projeto.consumoMensal} kWh/mês',
                            ),
                            Text(
                              'Módulo: '
                              '${projeto.potenciaModulo} Wp',
                            ),
                          ],
                        ),
                      ),

                      trailing: PopupMenuButton<String>(
                        onSelected: (opcao) async {
                          if (opcao == 'editar') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProjectRegisterPage(
                                  projeto: projeto,
                                ),
                              ),
                            );
                          }

                          if (opcao == 'excluir') {
                            await _excluirProjeto(
                              context,
                              projeto,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'excluir',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectRegisterPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}