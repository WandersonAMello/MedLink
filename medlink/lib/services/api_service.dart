import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "http://seu-backend.com/api";

  Future<http.Response> login(User user) async {
    final url = Uri.parse("$baseUrl/login");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
  }
}