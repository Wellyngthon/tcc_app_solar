import 'package:flutter/material.dart';

import '../models/client.dart';
import '../services/client_service.dart';
import 'client_register_page.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clientService = ClientService();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),

      body: StreamBuilder<List<Cliente>>(
        stream: clientService.listar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar clientes:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(cliente.nome),
                  subtitle: Text(
                    'CPF: ${cliente.cpf}\n'
                    'Telefone: ${cliente.telefone}',
                  ),
                  isThreeLine: true,

                  trailing: PopupMenuButton<String>(
                    onSelected: (opcao) async {
                      if (opcao == 'editar') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientRegisterPage(cliente: cliente),
                          ),
                        );
                      }

                      if (opcao == 'excluir') {
                        await _confirmarExclusao(
                          context,
                          clientService,
                          cliente,
                        );
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientRegisterPage()),
          );
        },
        tooltip: 'Novo cliente',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    ClientService clientService,
    Cliente cliente,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir cliente'),
          content: Text(
            'Deseja realmente excluir o cliente "${cliente.nome}"?',
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
      await clientService.excluir(cliente.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente excluído com sucesso.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir cliente: $e')));
    }
  }
}
