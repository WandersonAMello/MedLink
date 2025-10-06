// lib/controllers/login_controller.dart

import '../services/api_service.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  String _limparCPF(String cpf) {
    return cpf.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool validarCPF(String cpf) {
    final cpfLimpo = _limparCPF(cpf);
    if (cpfLimpo.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfLimpo)) return false;
    // ... (resto da validação do CPF)
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

  // --- FUNÇÃO DE LOGIN ATUALIZADA ---
  // Agora retorna o tipo de usuário (String) ou nulo em caso de falha
  Future<String?> login(String cpf, String senha) async {
    final cpfLimpo = _limparCPF(cpf);

    final response = await _apiService.login(cpfLimpo, senha);

    if (response != null && response['success'] == true) {
      final userType = response['user_type'] as String?;
      print('Login bem-sucedido! Tipo de usuário: $userType');
      return userType;
    } else {
      print('Erro no login.');
      return null;
    }
  }
}