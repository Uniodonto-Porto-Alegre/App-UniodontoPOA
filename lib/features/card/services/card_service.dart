// card/services/card_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/beneficiario_model.dart';
import 'dart:developer';

class CardService {
  /// Fetches the beneficiary data from SharedPreferences and parses it.
  ///
  /// Returns a list of [Beneficiario] objects.
  /// If no data is found or there's an error, it returns an empty list.
  Future<List<Beneficiario>> getBeneficiarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? beneficiarioData = prefs.getString('beneficiario_data');

      if (beneficiarioData != null && beneficiarioData.isNotEmpty) {
        // Use the helper function from the model to parse the JSON string
        log(beneficiarioData);
        return beneficiarioFromJson(beneficiarioData);
      } else {
        // Return an empty list if no data is found
        return [];
      }
    } catch (e) {
      // In case of any error during the process, log it and return an empty list
      print('Erro ao buscar dados do beneficiário: $e');
      return [];
    }
  }
}
