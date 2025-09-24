class User {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String senha;
  final String? tipo; // paciente, medico, secretaria, adm (opcional no cadastro inicial)

  User({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.senha,
    this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "cpf": cpf,
      "email": email,
      "telefone": telefone,
      "senha": senha,
      "tipo": tipo ?? "Paciente", // por padrão, no app mobile será paciente
    };
  }
}