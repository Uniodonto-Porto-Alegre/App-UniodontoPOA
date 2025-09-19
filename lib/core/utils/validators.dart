class Validators {
  // Validação de CPF (existente)
  static String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu CPF';
    }

    // Remove caracteres não numéricos
    final cleanedCpf = value.replaceAll(RegExp(r'[^\d]'), '');

    // Verifica se tem 11 dígitos
    if (cleanedCpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais (CPF inválido)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanedCpf)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    if (!_isValidCpf(cleanedCpf)) {
      return 'CPF inválido';
    }

    return null;
  }

  static bool _isValidCpf(String cpf) {
    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }

    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[9]) != firstDigit) {
      return false;
    }

    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }

    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cpf[10]) == secondDigit;
  }

  // Validação de senha (existente)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  // NOVO: Validação de confirmação de senha
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != password) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  // NOVO: Validação de seleção de tipo (titular ou dependente)
  static String? validateTipoCadastro(bool isTitular, bool isDependente) {
    if (!isTitular && !isDependente) {
      return 'Por favor, selecione o tipo de cadastro';
    }

    return null;
  }

  // NOVO: Validação condicional do CPF do titular
  static String? validateTitularCpf(String? value, bool isDependente) {
    // Só valida se for dependente
    if (!isDependente) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF do titular';
    }

    // Reutiliza a validação de CPF normal
    return validateCpf(value);
  }

  // NOVO: Validação se os CPFs são diferentes (para dependente)
  static String? validateCpfDiferente(
    String cpf,
    String titularCpf,
    bool isDependente,
  ) {
    // Só valida se for dependente
    if (!isDependente) {
      return null;
    }

    final cleanedCpf = cleanCpf(cpf);
    final cleanedTitularCpf = cleanCpf(titularCpf);

    if (cleanedCpf == cleanedTitularCpf) {
      return 'O CPF do dependente não pode ser igual ao do titular';
    }

    return null;
  }

  // NOVO: Validação de força da senha (opcional)
  static String? validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    // Verifica se tem pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }

    // Verifica se tem pelo menos uma letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }

    // Verifica se tem pelo menos um número
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }

    // Verifica se tem pelo menos um caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }

    return null;
  }

  // NOVO: Validação de termos e condições
  static String? validateTerms(bool? value) {
    if (value == null || value == false) {
      return 'Você deve aceitar os termos e condições';
    }

    return null;
  }

  // Método auxiliar para formatar CPF (existente)
  static String formatCpf(String cpf) {
    final cleanedCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedCpf.length != 11) return cpf;

    return '${cleanedCpf.substring(0, 3)}.${cleanedCpf.substring(3, 6)}.${cleanedCpf.substring(6, 9)}-${cleanedCpf.substring(9)}';
  }

  // Método para limpar formatação do CPF (existente)
  static String cleanCpf(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }

  // NOVO: Método para validar se é maior de idade (opcional)
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Por favor, informe sua data de nascimento';
    }

    final today = DateTime.now();
    final age = today.year - birthDate.year;

    if (age < 18) {
      return 'Você deve ser maior de 18 anos';
    }

    return null;
  }

  // NOVO: Validação de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }

    return null;
  }

  // NOVO: Validação de telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu telefone';
    }

    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedPhone.length < 10 || cleanedPhone.length > 11) {
      return 'Telefone inválido';
    }

    return null;
  }
}
