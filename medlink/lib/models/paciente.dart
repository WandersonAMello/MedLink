// lib/models/paciente.dart
import 'package:medlink/models/consultas.dart' as consultas_model;

class Paciente {
  final int id;
  final String nome;
  final DateTime horario; // Horário da consulta de hoje
  final String status;    // Status da consulta de hoje
  final String telefone;
  final String email;
  final String cpf; // Adicionado para consistência
  // O histórico completo pode ser carregado depois, ao selecionar o paciente
  final List<consultas_model.Consulta> consultasHistoricas;

  Paciente({
    required this.id,
    required this.nome,
    required this.horario,
    required this.status,
    required this.telefone,
    required this.email,
    required this.cpf,
    required this.consultasHistoricas,
  });

  // FÁBRICA AJUSTADA para o novo formato da API
  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      // Dados que vêm do PacienteSerializer
      id: json['id'] ?? 0,
      nome: json['nome_completo'] ?? 'Nome não encontrado', // O serializer envia 'nome_completo'
      email: json['email'] ?? 'E-mail não informado',
      telefone: json['telefone'] ?? 'Telefone não informado',
      cpf: json['cpf'] ?? 'CPF não informado',

      // Dados que adicionamos na view
      horario: DateTime.parse(json['horario']),
      status: json['status'] ?? 'N/A',
      
      // O histórico não vem na lista inicial, então criamos uma lista vazia.
      consultasHistoricas: [],
    );
  }

  Map<String, dynamic> toJson() {
    // Este método não precisa de alterações
    return {
      'id': id,
      'nome': nome,
      'horario': horario.toIso8601String(),
      'status': status,
      'telefone': telefone,
      'email': email,
      'cpf': cpf,
      'consultasHistoricas': consultasHistoricas
          .map((c) => c.toJson())
          .toList(),
    };
  }
}