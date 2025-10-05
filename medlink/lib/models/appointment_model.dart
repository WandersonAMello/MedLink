class Appointment {
  final int id;
  final DateTime dateTime;
  final String patientName;
  final String doctorName;
  final String type;
  final String status;

  // Campos para enviar ao criar um novo agendamento
  final int? patientId;
  final int? doctorId;
  final int? clinicId;
  final double? valor;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.patientName,
    required this.doctorName,
    required this.type,
    required this.status,
    this.valor,
    this.patientId,
    this.doctorId,
    this.clinicId,
  });

  // Construtor que "traduz" o JSON vindo da API para um objeto Appointment
  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Pega a hora do JSON (ex: "11:20") e a combina com a data de hoje.
    final timeParts = (json['time'] as String? ?? '00:00').split(':');
    final now = DateTime.now();
    final parsedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(timeParts[0]) ?? 0,
      int.tryParse(timeParts[1]) ?? 0,
    );

    return Appointment(
      id: json['id'] ?? 0,
      dateTime: parsedDateTime,
      patientName: json['patient'] ?? 'Paciente não informado',
      doctorName: json['doctor'] ?? 'Médico não informado',
      type: json['type'] ?? 'Não especificado',
      status: json['status'] ?? 'desconhecido',
      valor: json['valor'] != null
          ? double.tryParse(json['valor'].toString())
          : null,
    );
  }

  // 👇 MÉTODO QUE ESTAVA FALTANDO 👇
  // "Traduz" um objeto Appointment para o formato JSON para enviar à API
  Map<String, dynamic> toJson() {
    return {
      'data_hora': dateTime.toIso8601String(),
      'status_atual': status,
      'valor': valor.toString(),
      'paciente': patientId,
      'medico': doctorId,
      'clinica': clinicId,
    };
  }
}
