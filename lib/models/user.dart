class Usuario {
  int id;
  String nome;
  String email;
  String senha;

  Usuario({required this.id, required this.nome, required this.email, required this.senha});

  void cadastrar() {}
  void validarDados() {}
  void autenticar() {}
  void encerrarSessao() {}
}