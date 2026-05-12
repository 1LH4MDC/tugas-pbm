// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ─── Simpan & Ambil Token ───────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: Constants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: Constants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: Constants.tokenKey);
  }

  // ─── Header helper ─────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── 1. LOGIN ───────────────────────────────────────────
  Future<UserModel?> login(String nim) async {
    final url = Uri.parse('${Constants.baseUrl}${Constants.loginEndpoint}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': nim,
        'password': nim,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);
      await saveToken(user.token);
      return user;
    } else {
      return null;
    }
  }

  // ─── 2. GET PRODUCTS (GET) ──────────────────────────────
  Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('${Constants.baseUrl}${Constants.productsEndpoint}');
    final response = await http.get(url, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data']['products'];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  // ─── 3. TAMBAH PRODUK (POST) ────────────────────────────
  Future<bool> addProduct(String name, int price, String description) async {
    final url = Uri.parse('${Constants.baseUrl}${Constants.productsEndpoint}');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // ─── 4. DELETE PRODUK ───────────────────────────────────
  Future<bool> deleteProduct(int id) async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.productsEndpoint}/$id');
    final response = await http.delete(url, headers: await _authHeaders());
    return response.statusCode == 200;
  }

  // ─── 5. SUBMIT TUGAS (POST) ─────────────────────────────
  Future<bool> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}${Constants.submitEndpoint}');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // ─── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    await deleteToken();
  }
}