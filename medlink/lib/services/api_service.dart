// lib/services/api_service.dart (Corrigido)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  // A função de login foi ajustada para enviar os campos que o backend espera
  Future<http.Response> login(String cpf, String password) async {
    final url = Uri.parse("$baseUrl/api/token/"); // CORREÇÃO: URL correta
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      // CORREÇÃO: O backend espera 'cpf' e 'password'
      body: jsonEncode({
        "cpf": cpf,
        "password": password,
      }),
    );
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) { // CORREÇÃO da análise anterior
      return true;
    } else {
      return false;
    }
  }
}