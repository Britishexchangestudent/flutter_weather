import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_weather_openapi/models/custom_error.dart';
import 'package:flutter_weather_openapi/models/weather.dart';
import 'package:flutter_weather_openapi/repositories/weather_repo.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepo weatherRepo;
  WeatherCubit({required this.weatherRepo}) : super(WeatherState.initial());

  Future<void> fetchWeather(String city) async {
    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final Weather weather = await weatherRepo.fetchWeather(city);

      emit(state.copyWith(status: WeatherStatus.loaded, weather: weather));
      print('state: $state');
    } on CustomError catch (e) {
      emit(state.copyWith(status: WeatherStatus.error, error: e));
      print('state: $state');
    }
  }
}
