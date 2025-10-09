// lib/models/consultas.dart (VERSÃO COMPLETA E CORRIGIDA)

class Consulta {
  final int id;
  final DateTime horario;
  final String status;
  final String especialidade;
  final String profissional;

  Consulta({
    required this.id,
    required this.horario,
    required this.status,
    required this.especialidade,
    required this.profissional,
  });

  // Factory atualizada para ler o JSON da API de histórico
  factory Consulta.fromJson(Map<String, dynamic> json) {
    final medicoDetalhes = json['medico_detalhes'] as Map<String, dynamic>?;

    return Consulta(
      id: json['id'] ?? 0, // Lê o ID
      horario: DateTime.parse(json['data_hora']),
      status: json['status_atual'] ?? 'N/A',
      especialidade: medicoDetalhes?['especialidade'] ?? 'Não informada',
      profissional: medicoDetalhes?['nome_completo'] ?? 'Não informado',
    );
  }

  // --- CORREÇÃO: ADICIONADO O MÉTODO toJson ---
  // Isto resolve o erro que estava a acontecer no ficheiro paciente.dart
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_hora': horario.toIso8601String(),
      'status_atual': status,
      'especialidade': especialidade,
      'profissional': profissional,
    };
  }
}