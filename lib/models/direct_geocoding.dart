// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DirectGeocoding extends Equatable {
  final String name;
  final double lat;
  final double lon;
  final String country;

  DirectGeocoding(
      {required this.name,
      required this.lat,
      required this.lon,
      required this.country});

  factory DirectGeocoding.fromJSON(List<dynamic> json) {
    final Map<String, dynamic> data = json[0];

    return DirectGeocoding(
        country: data['country'],
        lat: data['lat'],
        lon: data['lon'],
        name: data['name']);
  }

  @override
  List<Object> get props => [name, lat, lon, country];

  @override
  String toString() {
    return 'DirectGeocoding(name: $name, lat: $lat, lon: $lon, country: $country)';
  }
}
