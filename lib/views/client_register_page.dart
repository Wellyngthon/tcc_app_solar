import 'package:flutter/material.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class ClientRegisterPage extends StatefulWidget {
  final Cliente? cliente;

  const ClientRegisterPage({super.key, this.cliente});

  bool get editando => cliente != null;

  @override
  State<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  final _clientService = ClientService();

  bool _carregando = false;

  @override
  void initState() {
    super.initState();

    final cliente = widget.cliente;

    if (cliente != null) {
      _nomeController.text = cliente.nome;
      _cpfController.text = cliente.cpf;
      _telefoneController.text = cliente.telefone;
      _enderecoController.text = cliente.endereco;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();

    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      if (widget.editando) {
        final clienteAtualizado = Cliente(
          id: widget.cliente!.id,
          nome: _nomeController.text.trim(),
          cpf: _cpfController.text.trim(),
          telefone: _telefoneController.text.trim(),
          endereco: _enderecoController.text.trim(),
        );

        await _clientService.editar(clienteAtualizado);
      } else {
        final novoCliente = Cliente(
          id: '',
          nome: _nomeController.text.trim(),
          cpf: _cpfController.text.trim(),
          telefone: _telefoneController.text.trim(),
          endereco: _enderecoController.text.trim(),
        );

        await _clientService.cadastrar(novoCliente);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar cliente: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.editando;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar cliente' : 'Novo cliente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do cliente.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o CPF.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o telefone.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _enderecoController,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o endereço.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _salvar,
                    child: _carregando
                        ? const CircularProgressIndicator()
                        : Text(
                            editando
                                ? 'Salvar alterações'
                                : 'Cadastrar cliente',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
