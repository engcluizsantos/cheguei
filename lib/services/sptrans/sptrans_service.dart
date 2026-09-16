import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cheguei/models/sptrans_line_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cheguei/models/sptrans_stop_model.dart';
import 'package:cheguei/models/sptrans_forecast_model.dart';

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

      final response = await _client.get(
        Uri.parse('$baseUrl/Parada/Buscar?termosBusca=$term'),
        headers: {if (_cookie != null) 'Cookie': _cookie!},
      );

      debugPrint('Status BuscarParadas: ${response.statusCode}');
      debugPrint('Body BuscarParadas: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Falha ao consultar paradas da SPTrans. '
          'Status: ${response.statusCode}',
        );
      }

      final List data = jsonDecode(response.body);

      return data.map((item) => SpTransStopModel.fromJson(item)).toList();
    } catch (e, s) {
      debugPrint('ERRO searchStops: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getForecast({
    required int stopId,
    required int lineId,
  }) async {
    try {
      debugPrint('Entrou no método getForecast()');
      debugPrint('Parada: $stopId');
      debugPrint('Linha: $lineId');

      final response = await _client.get(
        Uri.parse('$baseUrl/Previsao?codigoParada=$stopId&codigoLinha=$lineId'),
        headers: {if (_cookie != null) 'Cookie': _cookie!},
      );

      debugPrint('Status Previsao: ${response.statusCode}');
      debugPrint('Body Previsao: ${response.body}');

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return null;
      }

      return data;
    } catch (e, s) {
      debugPrint('ERRO getForecast: $e');
      debugPrint('$s');

      return null;
    }
  }

  static Future<Map<String, dynamic>?> getForecastByStop(int stopId) async {
    try {
      debugPrint('Entrou no método getForecastByStop()');
      debugPrint('Parada: $stopId');

      final response = await _client.get(
        Uri.parse('$baseUrl/Previsao/Parada?codigoParada=$stopId'),
        headers: {if (_cookie != null) 'Cookie': _cookie!},
      );

      debugPrint('Status PrevisaoParada: ${response.statusCode}');
      debugPrint('Body PrevisaoParada: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Falha ao consultar previsões da SPTrans. '
          'Status: ${response.statusCode}',
        );
      }

      final dynamic data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return null;
      }

      return data;
    } catch (e, s) {
      debugPrint('ERRO getForecastByStop: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  static Future<List<SpTransForecastModel>> getForecastsByStop(
    int stopId,
  ) async {
    final data = await getForecastByStop(stopId);

    if (data == null) {
      return [];
    }

    final stop = data['p'];

    if (stop is! Map<String, dynamic>) {
      return [];
    }

    final lines = stop['l'];

    if (lines is! List) {
      return [];
    }

    final forecasts = <SpTransForecastModel>[];

    for (final line in lines) {
      if (line is! Map<String, dynamic>) {
        continue;
      }

      final vehicles = line['vs'];

      if (vehicles is! List || vehicles.isEmpty) {
        continue;
      }

      final firstVehicle = vehicles.first;

      if (firstVehicle is! Map<String, dynamic>) {
        continue;
      }

      forecasts.add(
        SpTransForecastModel(
          lineId: line['cl'] ?? 0,
          lineCode: line['c'] ?? '',
          origin: line['lt0'] ?? '',
          destination: line['lt1'] ?? '',
          direction: line['sl'] ?? 0,
          vehicleCount: line['qv'] ?? 0,
          arrivalTime: firstVehicle['t'] ?? '',
          accessible: firstVehicle['a'] ?? false,
        ),
      );
    }

    forecasts.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    return forecasts;
  }
}
