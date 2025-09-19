// Arquivo: user_model.dart (versão ajustada)

class User {
  final String name;
  final String id;
  final String plan;
  final String? photoUrl;
  final String memberSince; // Armazenará a data de inclusão, ex: "01/07/2023"

  User({
    required this.name,
    required this.id,
    required this.plan,
    this.photoUrl,
    required this.memberSince,
  });

  /// Método privado para capitalizar o nome (primeira letra de cada palavra em maiúscula)
  static String _capitalizeName(String name) {
    if (name.isEmpty) return name;

    // Divide o nome em palavras, capitaliza cada uma e junta novamente
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Construtor de fábrica para criar um User a partir de um mapa JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    // Obtém e trata o nome do JSON
    final rawName = json['NOME']?.toString() ?? 'Nome não encontrado';
    final capitalizedName = _capitalizeName(rawName);

    return User(
      name: capitalizedName,
      id: json['ID']?.toString() ?? 'ID não encontrado',
      plan: json['MOD']?.toString() ?? 'Plano não encontrado',
      memberSince: json['INCLUSAO']?.toString() ?? 'Data não encontrada',
      photoUrl: null, // O JSON fornecido não possui URL de foto
    );
  }

  // Mock data para desenvolvimento (pode ser mantido para testes)
  static User get mockUser => User(
    name: 'Bryan Lamanna',
    id: '123456789',
    plan: 'ODONTO GESTÃO EMPRESA',
    photoUrl: null,
    memberSince: 'Membro desde Jan/2023',
  );

  // Método para converter o objeto User em um mapa (útil para persistência)
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'plan': plan,
    'photoUrl': photoUrl,
    'memberSince': memberSince,
  };

  // Método para criar uma cópia do usuário com alguns campos alterados
  User copyWith({
    String? name,
    String? id,
    String? plan,
    String? photoUrl,
    String? memberSince,
  }) {
    return User(
      name: _capitalizeName(name ?? this.name),
      id: id ?? this.id,
      plan: plan ?? this.plan,
      photoUrl: photoUrl ?? this.photoUrl,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
