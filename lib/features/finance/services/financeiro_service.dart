import '../models/boleto_model.dart';
import '../models/mensalidade_model.dart';

class FinanceiroService {
  // Busca a lista de boletos em aberto para um usuário
  Future<List<Boleto>> getBoletosEmAberto(String codigoUsuario) async {
    // TODO: Implementar a chamada à API para buscar boletos
    // Exemplo de retorno mockado:
    await Future.delayed(const Duration(seconds: 2));
    return []; // Retorna uma lista vazia por enquanto
  }

  // Busca o histórico de mensalidades de um usuário
  Future<List<Mensalidade>> getHistoricoMensalidades(
    String codigoUsuario,
  ) async {
    // TODO: Implementar a chamada à API para buscar mensalidades
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }

  // Busca o link ou o arquivo do informe de rendimentos (DMED)
  Future<String> getInformeRendimentos(String codigoUsuario, int ano) async {
    // TODO: Implementar a chamada à API para buscar o informe
    await Future.delayed(const Duration(seconds: 2));
    return "link_para_o_pdf_ou_dados_do_informe";
  }
}
