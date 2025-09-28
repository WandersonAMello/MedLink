// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // 1. IMPORTE A BIBLIOTECA
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  // 2. USE A LÓGICA PARA DEFINIR A URL AUTOMATICAMENTE
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  Future<http.Response> login(String cpf, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cpf": cpf,
        "password": password,
      }),
    );
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/pacientes/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}