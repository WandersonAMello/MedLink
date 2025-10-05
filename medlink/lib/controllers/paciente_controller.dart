import 'package:flutter/material.dart';
import '../models/consultas.dart' as consultas_model;
import '../models/paciente.dart';

class PacienteController extends ChangeNotifier {
  List<Paciente> pacientes = [];
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  Paciente get pacienteSelecionado => pacientes[_selectedIndex];

  PacienteController() {
    // Dados fake (depois troca por chamada ao backend)
    pacientes = List.generate(
      8,
      (i) => Paciente(
        id: i + 1,
        nome: 'Paciente ${i + 1}',
        horario: DateTime.now().add(Duration(minutes: i * 30)),
        status: i % 3 == 0
            ? 'Confirmado'
            : (i % 3 == 1 ? 'Pendente' : 'Cancelado'),
        telefone: '(63) 9${100000000 + i}',
        email: 'paciente${i + 1}@email.com',
        consultasHistoricas: List.generate(
          i, // só pra criar histórico variável
          (j) => consultas_model.Consulta(
            pacienteId: i + 1,
            data: DateTime.now().subtract(Duration(days: (j + 1) * 7)),
            horario: DateTime.now().subtract(Duration(days: (j + 1) * 7, hours: 2)),
            especialidade: "Especialidade ${j + 1}",
            profissional: "Dr. Fulano",
          )
        ),
      ),
    );
  }

  void selecionarPaciente(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}