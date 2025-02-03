import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService { 

  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final respose = await  http.get(Uri.parse("$BASE_URL?q=$cityName&appid=$apiKey&units=metric"));
      
    if (respose.statusCode == 200) {
      return Weather.fromJson(jsonDecode(respose.body));
    } else {
      throw Exception("Falha ao carregar dados meteorológicos");
    }
  }

  Future<String> getCurrentCity() async {
    try {
      // Verificar permissão do usuário
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print("Permissão de localização negada");
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          print("Usuário negou a permissão de localização");
          return "";
        }
      }

      // Verificar se o GPS está ativado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Serviço de localização está desativado");
        return "";
      }

      print("Obtendo posição atual...");
      // Buscar localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      print("Posição obtida: Lat: ${position.latitude}, Long: ${position.longitude}");

      // Tentar obter o clima diretamente usando as coordenadas
      final response = await http.get(
        Uri.parse(
          "$BASE_URL?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric"
        )
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cityName = data['name'];
        print("Cidade encontrada via API: $cityName");
        return cityName ?? "";
      }

      // Se não conseguir via API, tentar via geocoding
      print("Tentando obter cidade via geocoding...");
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
        );

        String? city = placemarks[0].locality;
        print("Cidade encontrada via geocoding: $city");
        return city ?? "";
      } catch (geocodingError) {
        print("Erro no geocoding: $geocodingError");
        return "";
      }

    } catch (e) {
      print("Erro ao obter cidade atual: $e");
      return "";
    }
  }
}