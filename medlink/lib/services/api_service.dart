// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/paciente.dart';

class ApiService {
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
  
  // MUDANÇA: O token agora é estático para ser compartilhado entre todas as instâncias do ApiService.
  static String? _accessToken;

  Future<http.Response> login(String cpf, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cpf": cpf,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access']; // Armazena o token na variável estática
    }
    return response;
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/pacientes/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<List<Paciente>> getPacientesDoDia() async {
    final url = Uri.parse("$baseUrl/api/pacientes/hoje/"); 

    if (_accessToken == null) {
      throw Exception('Token de acesso não encontrado. Faça o login novamente.');
    }

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (response.statusCode == 200) {
      // Usar utf8.decode para garantir a correta interpretação de caracteres especiais
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      
      List<Paciente> pacientes = body
          .map((dynamic item) => Paciente.fromJson(item as Map<String, dynamic>))
          .toList();
          
      return pacientes;
    } else {
      throw Exception('Falha ao carregar os pacientes do dia: ${response.statusCode}');
    }
  }
}