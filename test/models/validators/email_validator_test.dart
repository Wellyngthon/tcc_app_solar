import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_app_solar/models/validators/email_validator.dart';

void main() {
  group('Validação de Email', () {
    test('Deve aceitar emails válidos', () {
      expect(
        EmailValidator.isValid('teste@email.com'),
        true,
      );

      expect(
        EmailValidator.isValid('usuario123@gmail.com'),
        true,
      );
    });

    test('Deve rejeitar emails inválidos', () {
      expect(
        EmailValidator.isValid('email_invalido'),
        false,
      );

      expect(
        EmailValidator.isValid('teste@gmail'),
        false,
      );
    });
  });
}