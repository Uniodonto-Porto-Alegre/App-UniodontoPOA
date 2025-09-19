import '../models/comunicado_model.dart';

class FeedService {
  static Future<List<Comunicado>> getComunicados() async {
    // Simular chamada API
    await Future.delayed(const Duration(seconds: 1));
    return Comunicado.mockComunicados;
  }

  static Future<void> marcarComoLido(int comunicadoId) async {
    // Simular chamada API
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
