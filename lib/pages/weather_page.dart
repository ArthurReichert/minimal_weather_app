import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_model.dart';
import '../services/weather_services.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService("74a0173ce0b298e38ac129fea3b0603a");
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return "assets/sunny.json";

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':  
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default: 
        return 'assets/sunny.json';
    }
  }

  Color getBackgroundColor(String? mainCondition) {
    if (mainCondition == null) return Colors.white;

    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return Colors.white;
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Colors.grey[300]!;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.grey[600]!;
      case 'thunderstorm':
        return Colors.grey[900]!;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: getBackgroundColor(_weather?.mainCondition),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weather?.cityName ?? "Carregando cidade...",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
              Text('${_weather?.temperature.round().toString()}°C',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(_weather?.mainCondition ?? "",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
