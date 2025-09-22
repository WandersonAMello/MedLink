import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000/";

  Future<http.Response> login(User user) async {
    final url = Uri.parse("$baseUrl/login");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return true; // cadastro ok
    } else {
      return false; // falha
    }
  }
}
