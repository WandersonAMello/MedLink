import 'package:medlink/models/consultas.dart' as consultas_model;

class Paciente {
  final int id;
  final String nome;
  final DateTime horario;
  final String status;
  final String telefone;
  final String email;
  final List<consultas_model.Consulta> consultasHistoricas;

  Paciente({
    required this.id,
    required this.nome,
    required this.horario,
    required this.status,
    required this.telefone,
    required this.email,
    required this.consultasHistoricas,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nome: json['nome'],
      horario: DateTime.parse(json['horario']),
      status: json['status'],
      telefone: json['telefone'],
      email: json['email'],
      consultasHistoricas: json['consultasHistoricas'] != null
        ? List<consultas_model.Consulta>.from(
            json['consultasHistoricas'].map(
              (c) => consultas_model.Consulta.fromJson(c),
            ),
          )
        : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'horario': horario.toIso8601String(),
      'status': status,
      'telefone': telefone,
      'email': email,
      'consultasHistoricas': consultasHistoricas
          .map((c) => c.toJson())
          .toList(),
    };
  }
}