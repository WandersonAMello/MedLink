// lib/controllers/paciente_controller.dart

import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/api_service.dart';

class PacienteController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Paciente> pacientes = [];
  int _selectedIndex = -1; 
  bool isLoading = true;
  String? errorMessage;

  int get selectedIndex => _selectedIndex;

  // MUDANÇA: Getter mais seguro para o paciente selecionado.
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
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pacientes = await _apiService.getPacientesDoDia();
      
      if (pacientes.isNotEmpty) {
        _selectedIndex = 0; // Seleciona o primeiro por padrão
      } else {
        _selectedIndex = -1; // Nenhum para selecionar
      }

    } catch (e) {
      errorMessage = e.toString();
      print("Erro ao buscar pacientes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selecionarPaciente(int index) {
    if (index >= 0 && index < pacientes.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}