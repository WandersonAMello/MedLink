// lib/controllers/paciente_controller.dart (VERSÃO ATUALIZADA)

import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../models/consultas.dart' as consultas_model; // Importa o modelo de consulta
import '../services/api_service.dart';

class PacienteController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Estados para a lista de pacientes do dia
  List<Paciente> pacientes = [];
  int _selectedIndex = -1; 
  bool isLoading = true;
  String? errorMessage;

  // --- NOVOS ESTADOS PARA O HISTÓRICO ---
  List<consultas_model.Consulta> historicoConsultas = [];
  bool isHistoricoLoading = false;
  String? historicoErrorMessage;

  int get selectedIndex => _selectedIndex;
  Paciente? get pacienteSelecionado {
    if (_selectedIndex >= 0 && _selectedIndex < pacientes.length) {
      return pacientes[_selectedIndex];
    }
    return null;
  }

  PacienteController() {
    fetchPacientesDoDia();
  }

  Future<void> fetchPacientesDoDia() async {
    // ... (este método continua igual)
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pacientes = await _apiService.getPacientesDoDia();
      if (pacientes.isNotEmpty) {
        // Ao carregar a lista, já busca o histórico do primeiro paciente
        selecionarPaciente(0); 
      } else {
        _selectedIndex = -1;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODO ATUALIZADO ---
  void selecionarPaciente(int index) {
    if (index >= 0 && index < pacientes.length) {
      _selectedIndex = index;
      // Ao selecionar um paciente, chama a função para buscar o histórico dele
      _fetchHistorico(pacientes[index].id); 
      notifyListeners();
    }
  }

  // --- NOVO MÉTODO PRIVADO PARA BUSCAR O HISTÓRICO ---
  Future<void> _fetchHistorico(int pacienteId) async {
    isHistoricoLoading = true;
    historicoErrorMessage = null;
    notifyListeners();

    try {
      historicoConsultas = await _apiService.getHistoricoConsultas(pacienteId);
    } catch (e) {
      historicoErrorMessage = e.toString();
      print("Erro ao buscar histórico: $e");
    } finally {
      isHistoricoLoading = false;
      notifyListeners();
    }
  }
}