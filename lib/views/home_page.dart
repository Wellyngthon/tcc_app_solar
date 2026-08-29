import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _sair(BuildContext context) async {
    final authService = AuthService();

    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Solar')),

      // Menu lateral
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho do Drawer
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.solar_power, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'App Solar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),

              // Cliente
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Cliente'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Projeto Fotovoltaico
              ListTile(
                leading: const Icon(Icons.solar_power),
                title: const Text('Projeto Fotovoltaico'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Dimensionamento
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Dimensionamento'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Relatório
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Relatório'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Sobre
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const Spacer(),

              const Divider(),

              // Sair
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.pop(context);
                  await _sair(context);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // Conteúdo da Home
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.solar_power, size: 80),

              const SizedBox(height: 24),

              const Text(
                'Bem-vindo ao App Solar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const Text(
                'Utilize o menu lateral para acessar as funcionalidades do aplicativo.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
