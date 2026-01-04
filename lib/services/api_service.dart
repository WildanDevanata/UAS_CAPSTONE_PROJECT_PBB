import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/water_log.dart';
import '../utils/constants.dart';

// REST API Integration
class ApiService {
  static final ApiService instance = ApiService._init();
  ApiService._init();

  final String baseUrl = AppConstants.apiBaseUrl;

  // Helper for headers
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Error handling wrapper
  Future<T> _handleRequest<T>(Future<http.Response> request) async {
    try {
      final response = await request;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as T;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // Sync local data to server (CREATE)
  Future<void> syncWaterLog(WaterLog log) async {
    await _handleRequest(
      http.post(
        Uri.parse('$baseUrl/water_logs'),
        headers: _headers,
        body: jsonEncode(log.toJson()),
      ),
    );
  }

  // Get data from server (READ)
  Future<List<WaterLog>> fetchWaterLogs() async {
    final data = await _handleRequest<List>(
      http.get(Uri.parse('$baseUrl/water_logs'), headers: _headers),
    );

    return data.map((json) => WaterLog.fromJson(json)).toList();
  }

  // Batch sync (untuk offline mode)
  Future<void> batchSync(List<WaterLog> logs) async {
    await _handleRequest(
      http.post(
        Uri.parse('$baseUrl/water_logs/batch'),
        headers: _headers,
        body: jsonEncode(logs.map((log) => log.toJson()).toList()),
      ),
    );
  }
}
