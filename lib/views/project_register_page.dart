import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../services/client_service.dart';
import '../services/project_service.dart';

class ProjectRegisterPage extends StatefulWidget {
  final ProjetoFotovoltaico? projeto;

  const ProjectRegisterPage({
    super.key,
    this.projeto,
  });

  bool get editando => projeto != null;

  @override
  State<ProjectRegisterPage> createState() => _ProjectRegisterPageState();
}

class _ProjectRegisterPageState extends State<ProjectRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _localizacaoController = TextEditingController();
  final _inclinacaoController = TextEditingController();
  final _consumoController = TextEditingController();
  final _potenciaModuloController = TextEditingController();

  final _clientService = ClientService();
  final _projectService = ProjectService();

  String? _clienteSelecionado;
  String? _orientacaoSelecionada;

  bool _carregando = false;

  final List<String> _orientacoes = [
    'Norte',
    'Nordeste',
    'Leste',
    'Sudeste',
    'Sul',
    'Sudoeste',
    'Oeste',
    'Noroeste',
  ];

  @override
  void initState() {
    super.initState();

    final projeto = widget.projeto;

    if (projeto != null) {
      _clienteSelecionado = projeto.clienteId;
      _localizacaoController.text = projeto.localizacao;
      _orientacaoSelecionada = projeto.orientacaoTelhado;
      _inclinacaoController.text = projeto.inclinacaoTelhado.toString();
      _consumoController.text = projeto.consumoMensal.toString();
      _potenciaModuloController.text = projeto.potenciaModulo.toString();
    }
  }

  @override
  void dispose() {
    _localizacaoController.dispose();
    _inclinacaoController.dispose();
    _consumoController.dispose();
    _potenciaModuloController.dispose();

    super.dispose();
  }

  double? _converterNumero(String valor) {
    return double.tryParse(
      valor.trim().replaceAll(',', '.'),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente.'),
        ),
      );
      return;
    }

    if (_orientacaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a orientação do telhado.'),
        ),
      );
      return;
    }

    final inclinacao = _converterNumero(_inclinacaoController.text);
    final consumo = _converterNumero(_consumoController.text);
    final potenciaModulo =
        _converterNumero(_potenciaModuloController.text);

    if (inclinacao == null ||
        consumo == null ||
        potenciaModulo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe valores numéricos válidos.'),
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      if (widget.editando) {
        final projetoAtualizado = ProjetoFotovoltaico(
          id: widget.projeto!.id,
          clienteId: _clienteSelecionado!,
          localizacao: _localizacaoController.text.trim(),
          orientacaoTelhado: _orientacaoSelecionada!,
          inclinacaoTelhado: inclinacao,
          consumoMensal: consumo,
          potenciaModulo: potenciaModulo,
        );

        await _projectService.editar(projetoAtualizado);
      } else {
        final novoProjeto = ProjetoFotovoltaico(
          id: '',
          clienteId: _clienteSelecionado!,
          localizacao: _localizacaoController.text.trim(),
          orientacaoTelhado: _orientacaoSelecionada!,
          inclinacaoTelhado: inclinacao,
          consumoMensal: consumo,
          potenciaModulo: potenciaModulo,
        );

        await _projectService.cadastrar(novoProjeto);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar projeto: $e'),
        ),
      );
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
      appBar: AppBar(
        title: Text(
          editando
              ? 'Editar projeto fotovoltaico'
              : 'Novo projeto fotovoltaico',
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Cliente>>(
          stream: _clientService.listar(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Erro ao carregar clientes: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final clientes = snapshot.data ?? [];

            if (clientes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum cliente cadastrado.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cadastre um cliente antes de criar um projeto fotovoltaico.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final clienteExiste = clientes.any(
              (cliente) => cliente.id == _clienteSelecionado,
            );

            if (!clienteExiste) {
              _clienteSelecionado = null;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _clienteSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: clientes.map((cliente) {
                        return DropdownMenuItem<String>(
                          value: cliente.id,
                          child: Text(cliente.nome),
                        );
                      }).toList(),
                      onChanged: _carregando
                          ? null
                          : (value) {
                              setState(() {
                                _clienteSelecionado = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione o cliente.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _localizacaoController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Localização',
                        hintText: 'Ex.: Dourados - MS',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a localização.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _orientacaoSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Orientação do telhado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.explore),
                      ),
                      items: _orientacoes.map((orientacao) {
                        return DropdownMenuItem<String>(
                          value: orientacao,
                          child: Text(orientacao),
                        );
                      }).toList(),
                      onChanged: _carregando
                          ? null
                          : (value) {
                              setState(() {
                                _orientacaoSelecionada = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione a orientação.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _inclinacaoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Inclinação do telhado',
                        hintText: 'Ex.: 22',
                        suffixText: '°',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a inclinação.';
                        }

                        final numero = _converterNumero(value);

                        if (numero == null) {
                          return 'Informe um número válido.';
                        }

                        if (numero < 0 || numero > 90) {
                          return 'Informe um valor entre 0 e 90°.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _consumoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Consumo mensal',
                        hintText: 'Ex.: 450',
                        suffixText: 'kWh',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bolt),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o consumo mensal.';
                        }

                        final numero = _converterNumero(value);

                        if (numero == null) {
                          return 'Informe um número válido.';
                        }

                        if (numero <= 0) {
                          return 'O consumo deve ser maior que zero.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _potenciaModuloController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Potência do módulo',
                        hintText: 'Ex.: 550',
                        suffixText: 'Wp',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.solar_power),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a potência do módulo.';
                        }

                        final numero = _converterNumero(value);

                        if (numero == null) {
                          return 'Informe um número válido.';
                        }

                        if (numero <= 0) {
                          return 'A potência deve ser maior que zero.';
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
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                editando
                                    ? 'Salvar alterações'
                                    : 'Cadastrar projeto',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}