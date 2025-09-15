class User {
  final String cpf;
  final String senha;

  User({required this.cpf, required this.senha});

  Map<String, dynamic> toJson() {
    return {
      "cpf": cpf,
      "senha": senha,
    };
  }
}