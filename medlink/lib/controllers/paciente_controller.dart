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

  // --- NOVOS ESTADOS PARA A ANOTAÇÃO ---
  String anotacaoAtual = "";
  bool isAnotacaoLoading = false;
  bool isSaving = false; // Para o botão de salvar

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

  // Atualize o selecionarPaciente para buscar também a anotação
  void selecionarPaciente(int index) {
    if (index >= 0 && index < pacientes.length) {
      _selectedIndex = index;
      final paciente = pacientes[index];

      // Busca o histórico E a anotação da consulta atual
      _fetchHistorico(paciente.id);
      
      // O ID da consulta de hoje já vem no objeto Paciente
      final consultaDeHojeId = paciente.id; // Supondo que o ID do Paciente e Consulta coincidam neste contexto
      _fetchAnotacao(consultaDeHojeId); 
      
      notifyListeners();
    }
  }

  // --- NOVO MÉTODO PARA BUSCAR A ANOTAÇÃO ---
  Future<void> _fetchAnotacao(int consultaId) async {
    isAnotacaoLoading = true;
    notifyListeners();
    try {
      anotacaoAtual = await _apiService.getAnotacao(consultaId) ?? "";
    } catch(e) {
      print("Erro ao buscar anotação: $e");
      anotacaoAtual = ""; // Reseta em caso de erro
    } finally {
      isAnotacaoLoading = false;
      notifyListeners();
    }
  }

  // --- NOVO MÉTODO PARA SALVAR A ANOTAÇÃO ---
  Future<bool> salvarAnotacao(String conteudo) async {
    if (pacienteSelecionado == null) return false;

    isSaving = true;
    notifyListeners();

    try {
      final consultaId = pacienteSelecionado!.id; // Supondo que o ID coincida
      await _apiService.salvarAnotacao(consultaId, conteudo);
      anotacaoAtual = conteudo; // Atualiza o estado local
      
      // Força a atualização do histórico para refletir a nova anotação
      _fetchHistorico(pacienteSelecionado!.id);
      
      return true;
    } catch (e) {
      print("Erro ao salvar anotação: $e");
      return false;
    } finally {
      isSaving = false;
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