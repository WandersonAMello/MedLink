// lib/controllers/login_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http; // Importe o http
import '../services/api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 1. IMPORTA O DECODIFICADOR DE TOKEN

class LoginController {
  final ApiService _apiService = ApiService();

  // Função interna para remover a formatação do CPF
  String _limparCPF(String cpf) {
    return cpf.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // A função de validação de CPF continua a mesma
  bool validarCPF(String cpf) {
    final cpfLimpo = _limparCPF(cpf);
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

  // 👇 ALTERAÇÃO PRINCIPAL NA FUNÇÃO DE LOGIN 👇
  /// Tenta fazer o login e, se bem-sucedido, retorna um mapa com os tokens e o tipo de usuário.
  /// Retorna nulo em caso de falha.
  Future<Map<String, dynamic>?> login(String cpf, String senha) async {
    final cpfLimpo = _limparCPF(cpf);

    try {
      final response = await _apiService.login(cpfLimpo, senha);

      if (response.statusCode == 200) {
        // Sucesso na chamada da API
        final responseBody = jsonDecode(response.body);
        final String accessToken = responseBody['access'];
        final String refreshToken = responseBody['refresh'];

        // Decodifica o token de acesso para ler o tipo de usuário
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        final String userType = decodedToken['user_type'];

        print('Login bem-sucedido para o tipo de usuário: $userType');

        // Retorna um mapa com todas as informações necessárias para a LoginPage
        return {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'user_type': userType,
        };
      } else {
        // Falha no login (ex: senha incorreta)
        print('Erro no login: ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
        return null; // Retorna nulo para indicar falha
      }
    } catch (e) {
      // Captura erros de conexão (servidor offline, sem internet)
      print('Erro de conexão no login: $e');
      return null;
    }
  }
}
