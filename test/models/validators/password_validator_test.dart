import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_app_solar/models/validators/password_validator.dart';

void main() {
  group('Validação de Senha', () {
    test('Deve aceitar senhas válidas', () {
      expect(
        PasswordValidator.isValid('Senha123'),
        true,
      );

      expect(
        PasswordValidator.isValid('Flutter2025'),
        true,
      );

      expect(
        PasswordValidator.isValid('MinhaSenha1'),
        true,
      );
    });

    test('Deve rejeitar senhas inválidas', () {
      // Menos de 8 caracteres
      expect(
        PasswordValidator.isValid('Abc12'),
        false,
      );

      // Sem número
      expect(
        PasswordValidator.isValid('SenhaTeste'),
        false,
      );

      // Sem letra maiúscula
      expect(
        PasswordValidator.isValid('senha123'),
        false,
      );

      // Vazía
      expect(
        PasswordValidator.isValid(''),
        false,
      );
    });
  });
}