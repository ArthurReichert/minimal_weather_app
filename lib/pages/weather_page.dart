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
    try {
      String cityName = await _weatherService.getCurrentCity();
      
      if (cityName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível obter sua localização. Verifique se o GPS está ativado e as permissões concedidas.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final weather = await _weatherService.getWeather(cityName);
      if (mounted) {
        setState(() {
          _weather = weather;
        });
      }
    } catch (e) {
      print("Erro ao buscar clima: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do clima: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  bool isDaytime() {
    final now = DateTime.now();
    return now.hour >= 7 && now.hour < 18;
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return "assets/sunny.json";

    if (!isDaytime()) {
      return 'assets/moon.json';
    }

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

  String translateWeatherCondition(String? condition) {
    if (condition == null) return "Desconhecido";

    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'Nublado';
      case 'mist':
        return 'Névoa';
      case 'smoke':
        return 'Fumaça';
      case 'haze':
        return 'Neblina';
      case 'dust':
        return 'Poeira';
      case 'fog':
        return 'Nevoeiro';
      case 'rain':
        return 'Chuva';
      case 'drizzle':
        return 'Garoa';
      case 'shower rain':
        return 'Pancadas de Chuva';
      case 'thunderstorm':
        return 'Tempestade';
      case 'clear':
        return isDaytime() ? 'Céu Limpo' : 'Céu Limpo (Noite)';
      default:
        return condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDaytime() 
        ? Colors.blue[100] 
        : const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Localização e cidade
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: isDaytime() ? Colors.blue[900] : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _weather?.cityName ?? "Carregando cidade...",
                    style: TextStyle(
                      color: isDaytime() ? Colors.blue[900] : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Animação do clima
              Lottie.asset(
                getWeatherAnimation(_weather?.mainCondition),
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 40),

              // Temperatura
              Text(
                '${_weather?.temperature.round()}°C',
                style: TextStyle(
                  color: isDaytime() ? Colors.blue[900] : Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Condição do clima
              Text(
                translateWeatherCondition(_weather?.mainCondition),
                style: TextStyle(
                  color: isDaytime() ? Colors.blue[900] : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
