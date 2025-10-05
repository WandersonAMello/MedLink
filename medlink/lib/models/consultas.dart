class Consulta {
  final int pacienteId; // novo
  final DateTime data;
  final DateTime horario;
  final String especialidade;
  final String profissional;

  Consulta({
    required this.pacienteId, // novo
    required this.data,
    required this.horario,
    required this.especialidade,
    required this.profissional,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      pacienteId: json['pacienteId'], // novo
      data: DateTime.parse(json['data']),
      horario: DateTime.parse(json['horario']),
      especialidade: json['especialidade'],
      profissional: json['profissional'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pacienteId': pacienteId, // novo
      'data': data.toIso8601String(),
      'horario': horario.toIso8601String(),
      'especialidade': especialidade,
      'profissional': profissional,
    };
  }
}