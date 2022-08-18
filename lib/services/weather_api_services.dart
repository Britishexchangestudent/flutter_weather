import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_weather_openapi/constants/constants.dart';
import 'package:flutter_weather_openapi/exceptions/weather_exception.dart';
import 'package:flutter_weather_openapi/models/direct_geocoding.dart';
import 'package:flutter_weather_openapi/models/weather.dart';
import 'package:flutter_weather_openapi/services/http_error_handler.dart';
import 'package:http/http.dart' as http;

class WeatherApiServices {
  final http.Client httpClient;

  WeatherApiServices({required this.httpClient});

  Future<DirectGeocoding> getDirectGeocoding(String city) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: kApiHost,
      path: '/geo/1.0/direct',
      queryParameters: {
        'q': city,
        'limit': kLimit,
        'appid': dotenv.env['APPID'],
      },
    );

    try {
      final http.Response response = await httpClient.get(uri);
      if (response.statusCode != 200) {
        throw httpErrorHandler(response);
      }

      final responseBody = json.decode(response.body);

      if (responseBody.isEmpty) {
        throw WeatherException('Cannot get location of $city');
      }

      final directGeocoding = DirectGeocoding.fromJSON(responseBody);

      return directGeocoding;
    } catch (e) {
      rethrow;
    }
  }

  Future<Weather> getWeather(DirectGeocoding directGeocoding) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: kApiHost,
      path: '/data/2.5/weather',
      queryParameters: {
        'lat': '${directGeocoding.lat}',
        'lon': '${directGeocoding.lon}',
        'units': kUnit,
        'appid': dotenv.env['APPID'],
      },
    );

    try {
      final http.Response response = await httpClient.get(uri);

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }

      final weatherJson = json.decode(response.body);

      final Weather weather = Weather.fromJSON(weatherJson);

      return weather;
    } catch (e) {
      rethrow;
    }
  }
}
