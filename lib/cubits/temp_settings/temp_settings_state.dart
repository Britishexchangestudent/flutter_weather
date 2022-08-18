part of 'temp_settings_cubit.dart';

enum TempUnit {
  celsius,
  fahrenheit,
}

class TempSettingsState extends Equatable {
  final TempUnit tempUnit;

  TempSettingsState({this.tempUnit = TempUnit.celsius});

  factory TempSettingsState.initial() {
    return TempSettingsState();
  }

  @override
  String toString() => 'TempSettingsState(tempUnit: $tempUnit)';

  @override
  List<Object> get props => [tempUnit];

  TempSettingsState copyWith({
    TempUnit? tempUnit,
  }) {
    return TempSettingsState(
      tempUnit: tempUnit ?? this.tempUnit,
    );
  }
}
