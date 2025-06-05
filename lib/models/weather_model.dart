// lib/models/weather_model.dart

class WeatherData {
  final String cityName;
  final String description;
  final String iconCode;
  final double temperature;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.cityName,
    required this.description,
    required this.iconCode,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Kapitalisasi huruf pertama deskripsi
    String desc = json['weather'][0]['description'] ?? 'Tidak diketahui';
    desc = desc[0].toUpperCase() + desc.substring(1);

    return WeatherData(
      cityName: json['name'] ?? 'Lokasi Tidak Diketahui',
      description: desc,
      iconCode: json['weather'][0]['icon'] ?? '01d',
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}