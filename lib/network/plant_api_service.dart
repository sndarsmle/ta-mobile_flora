import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/network/api_constants.dart';

class PlantApi {
  Future<List<Plant>> getSpeciesList({String? query, int page = 1, int pageSize = 30}) async {
    String url = '${ApiConstants.perenualBaseUrl}/species-list?key=${ApiConstants.perenualApiKey}&page=$page&per_page=$pageSize';
    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        final plants = data['data'] as List;
        return plants.map((plantJson) => Plant.fromJson(plantJson)).toList();
      } else {
        throw Exception('API Error: ${data['message'] ?? 'Unknown error'} (Status Code: ${response.statusCode})');
      }
    } else {
      throw Exception('Failed to load plants list: HTTP Status Code ${response.statusCode}');
    }
  }

  Future<Plant> getSpeciesDetails(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.perenualBaseUrl}/species/details/$id?key=${ApiConstants.perenualApiKey}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Plant.fromJson(data); 
    } else {
      throw Exception('Failed to load plant details for ID $id: HTTP Status Code ${response.statusCode}');
    }
  }
}