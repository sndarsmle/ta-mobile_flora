// lib/views/tools/currency_converter_screen.dart
import 'dart:math'; // Import 'dart:math' untuk Random
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/budget_presenter.dart';
import 'package:projekakhir_praktpm/utils/constants.dart'; 
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';

class CurrencyConverterScreen extends StatefulWidget {
  final int plantId;
  final String plantName;

  const CurrencyConverterScreen({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  // Rentang harga simulasi dalam IDR
  final double _minPriceIDR = 75000.0;
  final double _maxPriceIDR = 5000000.0;
  final Random _random = Random();

  // Kurs mata uang (hardcode untuk contoh)
  final Map<String, double> _exchangeRatesToIDR = {
    'USD': 16000, // 1 USD = Rp 16.000
    'EUR': 17500, // 1 EUR = Rp 17.500
    'JPY': 105,   // 1 JPY = Rp 105
  };
  final List<String> _targetCurrencies = ['USD', 'EUR', 'JPY'];
  
  String? _selectedTargetCurrency;
  double? _randomlyGeneratedPriceIDR; // Harga IDR yang digenerate secara acak
  String? _conversionResultText;
  String? _originalPriceIDRText; 

  final NumberFormat _currencyFormatIDR = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Fungsi untuk mendapatkan harga acak dan formatnya

  void _generateAndSetRandomPrice() {
    // Generate harga acak antara minPrice dan maxPrice
    // Untuk membuatnya lebih "bulat" seperti harga sungguhan, kita bisa atur kelipatan
    double randomPrice = _minPriceIDR + _random.nextDouble() * (_maxPriceIDR - _minPriceIDR);
    // Pembulatan ke ratusan atau ribuan terdekat agar terlihat lebih natural
    randomPrice = (randomPrice / 500).round() * 500; 
    
    setState(() {
      _randomlyGeneratedPriceIDR = randomPrice;
      _originalPriceIDRText = _currencyFormatIDR.format(_randomlyGeneratedPriceIDR!);
    });
  }

  @override
  void initState() {
    super.initState();
    _generateAndSetRandomPrice(); // Generate harga acak saat halaman dimuat
    _selectedTargetCurrency = _targetCurrencies[0]; // Default ke USD
    _convertCurrency(); // Langsung konversi dengan harga acak dan default currency
  }

  void _convertCurrency() {
    if (_randomlyGeneratedPriceIDR == null || _selectedTargetCurrency == null) {
      setState(() {
        _conversionResultText = 'Error: Data tidak lengkap.';
      });
      return;
    }

    final rateToIDR = _exchangeRatesToIDR[_selectedTargetCurrency!];
    if (rateToIDR == null || rateToIDR == 0) {
       setState(() {
        _conversionResultText = 'Error: Kurs tidak ditemukan.';
      });
      return;
    }

    final convertedValue = _randomlyGeneratedPriceIDR! / rateToIDR;
    
    NumberFormat targetFormatter;
    switch (_selectedTargetCurrency) {
      case 'USD':
        targetFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
        break;
      case 'EUR':
        targetFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
        break;
      case 'JPY':
        targetFormatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);
        break;
      default:
        targetFormatter = NumberFormat.currency(symbol: '${_selectedTargetCurrency!} ', decimalDigits: 2);
    }

    setState(() {
      _conversionResultText = targetFormatter.format(convertedValue);
    });
  }

  Future<void> _saveToBudget() async {
    // Dapatkan UserPresenter untuk mengakses currentUser
    final userPresenter = Provider.of<UserPresenter>(context, listen: false);
    final currentUser = userPresenter.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menyimpan budget.'), backgroundColor: AppColors.dangerColor),
      );
      return;
    }

    if (_originalPriceIDRText == null || _conversionResultText == null || _selectedTargetCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data konversi untuk disimpan.'), backgroundColor: AppColors.dangerColor),
      );
      return;
    }

    try {
      await Provider.of<BudgetPresenter>(context, listen: false).addBudgetItem(
        userId: currentUser.id, // SERTAKAN USER ID
        plantId: widget.plantId,
        plantName: widget.plantName,
        originalPriceIDR: _originalPriceIDRText!,
        targetCurrency: _selectedTargetCurrency!,
        convertedPrice: _conversionResultText!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil disimpan ke Wishlist Budget!'), backgroundColor: AppColors.successColor),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.dangerColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konversi Harga: ${widget.plantName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.mediumPadding), //
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Perkiraan Harga Acak (IDR):', // Judul diubah
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryTextColor), //
            ),
            Text(
              _originalPriceIDRText ?? 'Menghasilkan harga...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accentColor, fontWeight: FontWeight.bold), //
            ),
            const SizedBox(height: AppPadding.smallPadding), //
            TextButton.icon( // Tombol untuk generate harga baru jika diinginkan
              icon: Icon(Icons.refresh, color: AppColors.accentColor, size: 18), //
              label: Text('Dapatkan Harga Acak Baru', style: TextStyle(color: AppColors.accentColor, fontSize: 12)), //
              onPressed: () {
                _generateAndSetRandomPrice();
                _convertCurrency(); // Langsung konversi ulang setelah harga baru digenerate
              },
            ),
            const SizedBox(height: AppPadding.largePadding), //
            Text(
              'Konversi ke:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryTextColor), //
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.smallPadding), //
               decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.softGrey.withOpacity(0.7))) //
                ),
              child: DropdownButton<String>(
                value: _selectedTargetCurrency,
                isExpanded: true,
                dropdownColor: AppColors.primaryColor.withBlue(AppColors.primaryColor.blue + 20), //
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentColor), //
                style: TextStyle(color: AppColors.textColor, fontSize: 16), //
                items: _targetCurrencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTargetCurrency = newValue;
                    _convertCurrency();
                  });
                },
              ),
            ),
            const SizedBox(height: AppPadding.largePadding), //
            Text(
              'Hasil Konversi:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryTextColor), //
            ),
            Text(
              _conversionResultText ?? '...', // Placeholder saat awal
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accentColor, fontWeight: FontWeight.bold), //
            ),
            const SizedBox(height: AppPadding.extraLargePadding), //
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Simpan ke Wishlist Budget'),
              onPressed: _saveToBudget,
            ),
            const SizedBox(height: AppPadding.mediumPadding), //
             Padding(
              padding: const EdgeInsets.only(top: AppPadding.mediumPadding), //
              child: Text(
                'Catatan: Harga dan kurs adalah simulasi dan dapat berbeda dengan kondisi pasar sebenarnya.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hintColor, fontStyle: FontStyle.italic), //
              ),
            ),
          ],
        ),
      ),
    );
  }
}