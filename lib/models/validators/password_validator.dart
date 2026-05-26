class PasswordValidator {
  static bool isValid(String password) {
    // Mínimo:
    // 8 caracteres
    // 1 letra maiúscula
    // 1 número

    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*\d).{8,}$',
    );

    return regex.hasMatch(password);
  }
}