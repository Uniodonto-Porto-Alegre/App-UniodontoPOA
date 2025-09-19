class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String cpf;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.cpf,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      cpf: json['cpf'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'cpf': cpf, 'token': token};
  }
}
