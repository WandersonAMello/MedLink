// lib/controllers/login_controller.dart (Versão Corrigida)

import 'dart:convert';
import '../services/api_service.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  // Função interna para remover a formatação do CPF
  String _limparCPF(String cpf) {
    return cpf.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool validarCPF(String cpf) {
    final cpfLimpo = _limparCPF(cpf); // Usa a função de limpeza

    if (cpfLimpo.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;

    List<int> numbers = cpfLimpo.split('').map(int.parse).toList();

    int soma1 = 0;
    for (int i = 0; i < 9; i++) {
      soma1 += numbers[i] * (10 - i);
    }
    int digito1 = (soma1 * 10) % 11;
    if (digito1 == 10) digito1 = 0;
    if (digito1 != numbers[9]) return false;

    int soma2 = 0;
    for (int i = 0; i < 10; i++) {
      soma2 += numbers[i] * (11 - i);
    }
    int digito2 = (soma2 * 10) % 11;
    if (digito2 == 10) digito2 = 0;
    if (digito2 != numbers[10]) return false;

    return true;
  }

  Future<bool> login(String cpf, String senha) async {
    // 1. Limpa o CPF antes de enviar para a API
    final cpfLimpo = _limparCPF(cpf);

    // 2. Envia o CPF limpo para o serviço
    final response = await _apiService.login(cpfLimpo, senha);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('Login bem-sucedido! Token de acesso: ${responseBody['access']}');
      return true;
    } else {
      print('Erro no login: ${response.statusCode}');
      print('Corpo da resposta: ${response.body}');
      return false;
    }
  }
}