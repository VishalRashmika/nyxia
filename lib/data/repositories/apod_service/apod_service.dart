import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/apod.dart';

class ApodService {
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';
  String get _apiKey => dotenv.env['NASA_API_KEY'] ?? '';

  /// fetch apod for a date
  Future<Apod?> fetchApod({DateTime? date}) async {
    try {
      String url = '$_baseUrl?api_key=$_apiKey';

      if (date != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        url += '&date=$dateStr';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Apod.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// fetch today image url
  Future<String?> fetchApodImage() async {
    try {
      final apod = await fetchApod();
      return apod?.url;
    } catch (e) {
      return null;
    }
  }

  /// fetch random image url
  Future<String?> fetchRandomApodImage() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?api_key=$_apiKey&count=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          if (data[0]['media_type'] == 'image') {
            return data[0]['url'];
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
