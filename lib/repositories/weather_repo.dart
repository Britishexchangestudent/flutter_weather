import 'package:flutter_weather_openapi/exceptions/weather_exception.dart';
import 'package:flutter_weather_openapi/models/custom_error.dart';
import 'package:flutter_weather_openapi/models/direct_geocoding.dart';
import 'package:flutter_weather_openapi/models/weather.dart';
import 'package:flutter_weather_openapi/services/weather_api_services.dart';

class WeatherRepo {
  final WeatherApiServices weatherApiServices;

  WeatherRepo({required this.weatherApiServices});

  Future<Weather> fetchWeather(String city) async {
    try {
      final DirectGeocoding directGeocoding =
          await weatherApiServices.getDirectGeocoding(city);
      print('directGeocoding: $directGeocoding');

      final Weather tempWeather =
          await weatherApiServices.getWeather(directGeocoding);

      print('tempWeather: $tempWeather');

      final Weather weather = tempWeather.copyWith(
          name: directGeocoding.name, country: directGeocoding.country);

          print('weather: $weather');

          return weather;
    } on WeatherException catch (e) {
      throw CustomError(errorMessage: e.message);
    } catch (e) {
      throw CustomError(errorMessage: e.toString());
    }
  }
}
