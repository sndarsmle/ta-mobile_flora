import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';

class TimeConverterScreen extends StatefulWidget {
  final String plantName;
  final Map<String, dynamic>? wateringBenchmark; 
  const TimeConverterScreen({
    super.key,
    required this.plantName,
    this.wateringBenchmark,
  });

  @override
  State<TimeConverterScreen> createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  TimeOfDay? _selectedLocalTime;
  String? _localTimeZoneName; 
  bool _isLocalTimeZoneLoading = true;

  final Map<String, String> _targetTimeZonesDisplay = {
    'Asia/Jakarta': 'WIB (Jakarta)',
    'Asia/Makassar': 'WITA (Makassar)',
    'Asia/Jayapura': 'WIT (Jayapura)',
    'Europe/London': 'London (GMT/BST)',
  };

  final Map<String, String> _convertedTimes = {};
  bool _isLoadingConversion = false; 
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocalTimeZone();
  }

  Future<void> _loadLocalTimeZone() async {
  setState(() {
    _isLocalTimeZoneLoading = true;
    _error = null;
  });
  try {
    // PERUBAHAN DI SINI:
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    setState(() {
      _localTimeZoneName = timeZoneName;
    });
  } catch (e) {
    setState(() {
      _error = 'Gagal mendapatkan zona waktu lokal: ${e.toString()}. Menggunakan Asia/Jakarta sebagai default.';
      _localTimeZoneName = 'Asia/Jakarta'; 
    });
  } finally {
    setState(() {
      _isLocalTimeZoneLoading = false;
      if (_selectedLocalTime != null) {
        _convertTime();
      }
    });
  }
}

  Future<void> _pickLocalTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedLocalTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedLocalTime) {
      setState(() {
        _selectedLocalTime = picked;
        if (_localTimeZoneName != null) {
          _convertTime();
        } else if (!_isLocalTimeZoneLoading) {
          setState(() {
            _error = 'Zona waktu lokal belum termuat. Silakan coba lagi.';
          });
        }
      });
    }
  }

  void _convertTime() {
    if (_selectedLocalTime == null || _localTimeZoneName == null) {
      return;
    }

    setState(() {
      _isLoadingConversion = true;

      _convertedTimes.clear();
    });

    try {
      final now = DateTime.now();
      final localScheduledTime = DateTime(
          now.year, now.month, now.day, _selectedLocalTime!.hour, _selectedLocalTime!.minute);

      
      final tz.Location localLocation = tz.getLocation(_localTimeZoneName!);
      final tz.TZDateTime tzScheduledTimeLocal = tz.TZDateTime.from(localScheduledTime, localLocation);

      _targetTimeZonesDisplay.forEach((tzName, display) {
        if (tzName == _localTimeZoneName) {
          
          _convertedTimes[display] = '${DateFormat('HH:mm').format(tzScheduledTimeLocal)} (Lokal Anda)';
        } else {
          try {
            final tz.Location targetLocation = tz.getLocation(tzName);
            final tz.TZDateTime tzScheduledTimeTarget = tz.TZDateTime.from(tzScheduledTimeLocal, targetLocation);
            _convertedTimes[display] = DateFormat('HH:mm').format(tzScheduledTimeTarget);
          } catch (e) {
            _convertedTimes[display] = 'Error';
            
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = '${_error ?? ''}\nError saat konversi waktu: ${e.toString()}'; 
      });
    } finally {
      setState(() {
        _isLoadingConversion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    String benchmarkText = 'Frekuensi penyiraman tidak tersedia.';
    if (widget.wateringBenchmark != null &&
        widget.wateringBenchmark!['value'] != null &&
        widget.wateringBenchmark!['unit'] != null) {
      benchmarkText = 'Penyiraman: ${widget.wateringBenchmark!['value']} ${widget.wateringBenchmark!['unit']}';
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Konversi Waktu: ${widget.plantName}'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              benchmarkText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppPadding.mediumPadding),

            if (_isLocalTimeZoneLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(AppPadding.mediumPadding),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppPadding.smallPadding),
                    Text("Mendeteksi zona waktu lokal..."),
                  ],
                ),
              ))
            else
              Column(
                children: [
                  Text(
                    _localTimeZoneName != null
                        ? '$_localTimeZoneName'
                        : 'Zona waktu lokal tidak dapat ditentukan.', 
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppPadding.smallPadding),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedLocalTime == null
                          ? 'Pilih Waktu Penyiraman Lokal'
                          : ': ${_selectedLocalTime!.format(context)}',
                    ),
                    onPressed: _isLocalTimeZoneLoading ? null : _pickLocalTime, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppPadding.mediumPadding),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: AppPadding.largePadding),
                  if (_isLoadingConversion)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null && !_error!.toLowerCase().contains("default.") && !_error!.toLowerCase().contains("konversi waktu")) 
                     Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppPadding.mediumPadding),
                        child: Text(
                          _error!, 
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                  else if (_selectedLocalTime != null && _convertedTimes.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppPadding.mediumPadding),
                          child: Text(
                            'Jika Anda menyiram pukul ${_selectedLocalTime!.format(context)} (waktu ${_localTimeZoneName ?? "lokal Anda"}), maka di zona waktu lain adalah:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ..._convertedTimes.entries.map((entry) {
                          bool isLocal = entry.value.contains('(Lokal Anda)');
                          return Card(
                            color: isLocal ? AppColors.primaryColor.withOpacity(0.1) : null,
                            margin: const EdgeInsets.only(bottom: AppPadding.smallPadding),
                            child: ListTile(
                              title: Text(entry.key, style: TextStyle(color: AppColors.textColor, fontWeight: isLocal ? FontWeight.bold : FontWeight.w500)),
                              trailing: Text(
                                entry.value.replaceFirst(' (Lokal Anda)', ''), 
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isLocal ? AppColors.primaryColor : AppColors.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: isLocal ? Text('Zona Waktu Anda Saat Ini', style: TextStyle(fontSize: 12, color: AppColors.hintColor)) : null,
                            ),
                          );
                        }),
                         if (_error != null && _error!.toLowerCase().contains("konversi waktu")) 
                           Padding(
                             padding: const EdgeInsets.only(top: AppPadding.mediumPadding),
                             child: Text(
                               _error!,
                               style: const TextStyle(color: Colors.red, fontSize: 14),
                               textAlign: TextAlign.center,
                             ),
                           ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppPadding.largePadding),
                    child: Text(
                      _isLocalTimeZoneLoading
                          ? 'Sedang mendeteksi zona waktu perangkat Anda...'
                          : _error != null && _error!.toLowerCase().contains("default.") 
                              ? 'Catatan: $_error' 
                              : _localTimeZoneName != null
                                  ? 'Catatan: Konversi waktu menggunakan zona ($_localTimeZoneName) sebagai waktu lokal Anda.'
                                  : 'Catatan: Pilih waktu untuk melihat konversi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hintColor, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}