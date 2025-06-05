// lib/views/weather/weather_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projekakhir_praktpm/models/weather_model.dart'; // Import model
import 'package:projekakhir_praktpm/utils/constants.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _error;
  final String _openWeatherApiKey = "c594ad5eeb2fe2b80cf1adb1fd396f00"; // Ganti jika perlu

  @override
  void initState() {
    super.initState();
    _fetchLocationAndWeather();
  }

  Future<void> _fetchLocationAndWeather() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif. Aktifkan untuk melihat cuaca.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak. Izinkan untuk melihat cuaca.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.');
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      final lat = currentPosition.latitude;
      final lon = currentPosition.longitude;
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_openWeatherApiKey&units=metric&lang=id'));

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _weatherData = WeatherData.fromJson(json.decode(response.body));
        });
      } else {
        throw Exception('Gagal mengambil data cuaca: Status ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
    }

    if (_error != null) {
      return _buildErrorUI();
    }

    if (_weatherData == null) {
      return _buildErrorUI(errorMessage: 'Tidak dapat menampilkan data cuaca saat ini.');
    }

    return _buildWeatherUI();
  }

  Widget _buildWeatherUI() {
    return RefreshIndicator(
      onRefresh: _fetchLocationAndWeather,
      color: AppColors.accentColor,
      backgroundColor: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppPadding.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              _weatherData!.cityName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textColor, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: AppPadding.mediumPadding),
            Image.network(
              _getWeatherIconUrl(_weatherData!.iconCode),
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.cloud_off,
                  size: 100,
                  color: AppColors.hintColor),
            ),
            Text(
              '${_weatherData!.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.accentColor, fontWeight: FontWeight.w900),
            ),
            Text(
              _weatherData!.description,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textColor),
            ),
            const SizedBox(height: AppPadding.extraLargePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherInfoItem(Icons.water_drop_outlined,
                    '${_weatherData!.humidity}%', 'Kelembapan'),
                _buildWeatherInfoItem(Icons.air,
                    '${_weatherData!.windSpeed.toStringAsFixed(1)} m/s', 'Angin'),
              ],
            ),
            const SizedBox(height: AppPadding.largePadding),
            Text(
              'Geser ke bawah untuk memperbarui cuaca.',
              style: TextStyle(color: AppColors.hintColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI({String? errorMessage}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.dangerColor, size: 60),
            const SizedBox(height: AppPadding.mediumPadding),
            Text(
              errorMessage ?? _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.secondaryTextColor, fontSize: 16),
            ),
            const SizedBox(height: AppPadding.mediumPadding),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: _fetchLocationAndWeather,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: AppColors.secondaryTextColor),
        const SizedBox(height: AppPadding.extraSmallPadding),
        Text(value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textColor, fontWeight: FontWeight.w600)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.hintColor)),
      ],
    );
  }
}