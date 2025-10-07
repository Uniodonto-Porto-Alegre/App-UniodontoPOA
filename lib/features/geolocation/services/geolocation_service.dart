import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/provider_model.dart';
import 'cep_service.dart'; // Import do novo serviço de CEP

class GeolocationService {
  static const String _baseUrl =
      'https://api.uniodontopoa.com.br/api/ListaGeolocalizador';
  static const String _token =
      'Bearer 46|2ZbdfGpOvrkhUaG56Ky8Ppan704wCHRpHJKii1w4';

  /// Solicita permissões de localização
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtém a localização atual do usuário
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permissão de localização negada');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// NOVA FUNÇÃO: Obtém coordenadas a partir de um CEP
  static Future<Map<String, double>?> getCoordinatesFromCep(String cep) async {
    try {
      return await CepService.getCoordinatesByCep(cep);
    } catch (e) {
      rethrow;
    }
  }

  /// NOVA FUNÇÃO: Busca prestadores próximos usando CEP
  static Future<List<ProviderModel>> getProvidersNearbyCep(String cep) async {
    try {
      final coordinates = await getCoordinatesFromCep(cep);
      if (coordinates == null) {
        throw Exception('Não foi possível obter coordenadas do CEP informado');
      }

      return await getProvidersNearby(
        coordinates['latitude']!,
        coordinates['longitude']!,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Busca prestadores próximos à localização fornecida (mantida a função original)
  static Future<List<ProviderModel>> getProvidersNearby(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl?lat=$latitude&lon=$longitude');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'Authorization': _token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<ProviderModel> providers = data
            .map((json) => ProviderModel.fromJson(json))
            .toList();

        // Filtra por um raio máximo de 5km
        const maxDistanceKm = 5.0;
        providers = providers
            .where((p) => p.distancia != null && p.distancia! <= maxDistanceKm)
            .toList();

        // Ordena pela distância
        providers.sort(
          (a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0),
        );

        return providers;
      } else {
        throw Exception(
          'Falha ao carregar prestadores: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao buscar prestadores: $e');
    }
  }

  /// NOVA FUNÇÃO: Valida formato do CEP
  static bool isValidCep(String cep) {
    String cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8;
  }

  /// NOVA FUNÇÃO: Formata CEP para exibição
  static String formatCep(String cep) {
    String cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }
}
