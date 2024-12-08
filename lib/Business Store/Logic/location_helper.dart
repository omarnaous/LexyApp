import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lexyapp/Business%20Store/Data/location_model.dart';

class LocationHelperClass {
  final String apiKey = 'AIzaSyB17TAHLxsO7oNTeIsZPwhR0mfwSEaA0ZY';

  Future<List<GoogleLocationModel>> search(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results
            .map((json) => GoogleLocationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
