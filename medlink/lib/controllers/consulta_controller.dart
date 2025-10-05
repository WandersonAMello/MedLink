import '../models/consultas.dart' as consultas_model;

class ConsultaController {
  // Lista de consultas de teste
  final List<consultas_model.Consulta> consultas = [
    consultas_model.Consulta(
      pacienteId: 1,
      data: DateTime(2025, 10, 5),
      horario: DateTime(2025, 10, 5, 14, 30),
      especialidade: "Cardiologia",
      profissional: "Dr. Silva",
    ),
    consultas_model.Consulta(
      pacienteId: 2,
      data: DateTime(2025, 10, 5),
      horario: DateTime(2025, 10, 5, 15, 0),
      especialidade: "Dermatologia",
      profissional: "Dra. Maria",
    ),
    consultas_model.Consulta(
      pacienteId: 3,
      data: DateTime(2025, 10, 5),
      horario: DateTime(2025, 10, 5, 15, 30),
      especialidade: "Ortopedia",
      profissional: "Dr. João",
    ),
  ];

  // ✅ Método para buscar consulta por paciente
  consultas_model.Consulta getConsultaPorPaciente(int pacienteId) {
    return consultas.firstWhere(
      (c) => c.pacienteId == pacienteId,
      orElse: () => consultas[0],
    );
  }
}