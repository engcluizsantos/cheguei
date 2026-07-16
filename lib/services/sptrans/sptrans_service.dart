import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cheguei/models/sptrans_line_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cheguei/models/sptrans_stop_model.dart';

class SpTransService {
  SpTransService._();

  static const String baseUrl = 'http://api.olhovivo.sptrans.com.br/v2.1';

  static final http.Client _client = http.Client();

  static String? _cookie;

  static Future<bool> authenticate(String apiKey) async {

    debugPrint('Entrou no authenticate()');

    final response = await _client.post(
      Uri.parse('$baseUrl/Login/Autenticar?token=$apiKey'),
    );

    final cookie = response.headers['set-cookie'];

    if (cookie != null) {
      _cookie = cookie.split(';').first;
      debugPrint('Cookie salvo: $_cookie');
    }

    return response.statusCode == 200;
  }

  static Future<List<SpTransLineModel>> getLinesByStop(int stopId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Parada/BuscarLinhas?codigoParada=$stopId'),
      headers: {if (_cookie != null) 'Cookie': _cookie!},
    );

    debugPrint('Buscando linhas da parada: $stopId');
    debugPrint('Status BuscarLinhas: ${response.statusCode}');
    debugPrint('Body BuscarLinhas: ${response.body}');

    if (response.statusCode != 200) {
      return [];
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => SpTransLineModel.fromJson(item)).toList();
  }

  static Future<List<SpTransLineModel>> searchLines(String term) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Linha/Buscar?termosBusca=$term'),
      headers: {if (_cookie != null) 'Cookie': _cookie!},
    );

    debugPrint('Status BuscarLinhas: ${response.statusCode}');
    debugPrint('Body BuscarLinhas: ${response.body}');

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> json = jsonDecode(response.body);

    return json.map((item) => SpTransLineModel.fromJson(item)).toList();
  }

  // METODO TEMPORÁRIO

  static Future<Map<String, dynamic>?> getItinerary(int lineId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Itinerario/Buscar?codigoLinha=$lineId'),
      headers: {if (_cookie != null) 'Cookie': _cookie!},
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode != 200) {
      return null;
    }

    return jsonDecode(response.body);
  }

  /* METODO ANTIGO
  static Future<Map<String, dynamic>?> getItinerary(int lineId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Itinerario/Buscar?codigoLinha=$lineId'),
      headers: {if (_cookie != null) 'Cookie': _cookie!},
    );


    if (response.statusCode != 200) {
      return null;
    }

    return jsonDecode(response.body);
  }
*/

  static Future<List<SpTransStopModel>> searchStops(String term) async {
    try {
      debugPrint('Entrou no método searchStops()');
      debugPrint('Cookie atual: $_cookie');

      final response = await _client.get(
        Uri.parse('$baseUrl/Parada/Buscar?termosBusca=$term'),
        headers: {if (_cookie != null) 'Cookie': _cookie!},
      );

      debugPrint('Status BuscarParadas: ${response.statusCode}');
      debugPrint('Body BuscarParadas: ${response.body}');

      if (response.statusCode != 200) {
        return [];
      }

      final List data = jsonDecode(response.body);

      return data.map((item) => SpTransStopModel.fromJson(item)).toList();
    } catch (e, s) {
      debugPrint('ERRO searchStops: $e');
      debugPrint('$s');
      return [];
    }
  }
}
