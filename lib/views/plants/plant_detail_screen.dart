// lib/views/plants/plant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/presenters/bookmark_presenter.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/presenters/plant_presenter.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';
import 'package:projekakhir_praktpm/views/comments/comment_section.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant; // Ini adalah plant dari list, mungkin minim info
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? _detailedPlant; // Untuk menyimpan data plant yang sudah lengkap
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlantDetails();
  }

  Future<void> _fetchPlantDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final plantPresenter = Provider.of<PlantPresenter>(context, listen: false);
      final detailedPlantData = await plantPresenter.getPlantDetails(widget.plant.id);

      if (mounted) {
        setState(() {
          _detailedPlant = detailedPlantData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat detail tanaman: ${e.toString().replaceFirst("Exception: ", "")}';
          _isLoading = false;
        });
        _showErrorSnackbar(_errorMessage!);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerColor, //
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor, //
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String getImageUrl(Map<String, dynamic>? defaultImage) {
    if (defaultImage != null && defaultImage['regular_url'] != null && defaultImage['regular_url'].isNotEmpty) {
      return defaultImage['regular_url'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkPresenter = context.watch<BookmarkPresenter>();
    final userPresenter = context.watch<UserPresenter>();
    final currentUser = userPresenter.currentUser;

    final Plant displayPlant = _detailedPlant ?? widget.plant;

    bool isBookmarked = currentUser != null &&
        bookmarkPresenter.isBookmarked(currentUser.id, displayPlant.id);

    return Scaffold(
      backgroundColor: AppColors.primaryColor, //
      appBar: AppBar(
        title: Text(displayPlant.commonName.isNotEmpty ? displayPlant.commonName : 'Detail Tanaman'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.favorite : Icons.favorite_border,
              color: isBookmarked ? AppColors.accentColor : AppColors.textColor, //
            ),
            onPressed: () {
              if (currentUser == null) {
                _showErrorSnackbar('Anda harus login untuk menambahkan favorit');
                return;
              }
              final Plant plantToBookmark = _detailedPlant ?? widget.plant;
              if (isBookmarked) {
                bookmarkPresenter.removeBookmark(currentUser.id, plantToBookmark.id);
                _showSuccessSnackbar('Tanaman dihapus dari favorit.');
              } else {
                bookmarkPresenter.addBookmark(currentUser.id, plantToBookmark);
                _showSuccessSnackbar('Tanaman ditambahkan ke favorit.');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor)) //
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.mediumPadding), //
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.dangerColor) //
                    ),
                  ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppPadding.mediumPadding), //
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayPlant.commonName,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor, //
                            ),
                      ),
                      const SizedBox(height: AppPadding.smallPadding), //
                      Text(
                        displayPlant.scientificName.join(', '),
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.secondaryTextColor, //
                            ),
                      ),
                      const SizedBox(height: AppPadding.mediumPadding), //
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppPadding.smallPadding), //
                        child: getImageUrl(displayPlant.defaultImage).isNotEmpty
                            ? Image.network(
                                getImageUrl(displayPlant.defaultImage),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/noCover.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/noCover.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: AppPadding.mediumPadding), //
                      _buildInfoRow('Jenis', displayPlant.type ?? 'N/A'),
                      _buildInfoRow('Siklus Hidup', displayPlant.cycle), //
                      _buildInfoRow('Penyiraman', displayPlant.watering), //
                      if (displayPlant.wateringGeneralBenchmark != null &&
                          displayPlant.wateringGeneralBenchmark!['value'] != null)
                        _buildInfoRow(
                            'Patokan Penyiraman',
                            '${displayPlant.wateringGeneralBenchmark!['value']} ${displayPlant.wateringGeneralBenchmark!['unit'] ?? ''}'),
                      _buildInfoRow(
                          'Sinar Matahari',
                          (displayPlant.sunlight.isNotEmpty
                                  ? displayPlant.sunlight.map((s) => s.toString()).join(', ')
                                  : null) ??
                              'Tidak Diketahui'), //
                      _buildInfoRow('Deskripsi', displayPlant.description), //
                      
                      // --- TOMBOL NAVIGASI KE CURRENCY CONVERTER ---
                      const SizedBox(height: AppPadding.mediumPadding), //
                      ElevatedButton.icon(
                        icon: const Icon(Icons.price_change_outlined, color: AppColors.primaryColor), //
                        label: Text(
                          'Lihat Perkiraan Harga & Konversi',
                          style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold) //
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: AppColors.accentColor, //
                        ),
                        onPressed: () {
                          if (displayPlant.commonName.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              '/currency-converter', 
                              arguments: {
                                'plantId': displayPlant.id,
                                'plantName': displayPlant.commonName,
                              },
                            );
                          } else {
                            _showErrorSnackbar('Informasi tanaman tidak lengkap untuk konversi harga.');
                          }
                        },
                      ),
                      // --- AKHIR TOMBOL CURRENCY CONVERTER ---
                      
                      // --- TOMBOL NAVIGASI KE TIME CONVERTER ---
                      const SizedBox(height: AppPadding.smallPadding), //
                      ElevatedButton.icon(
                        icon: const Icon(Icons.access_time_filled_outlined, color: AppColors.primaryColor), //
                        label: Text(
                          'Konversi Waktu Penyiraman Global',
                          style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold) //
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: AppColors.accentColor, //
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/time-converter', // Rute yang sudah didaftarkan di main.dart
                            arguments: {
                              'plantName': displayPlant.commonName,
                              'wateringBenchmark': displayPlant.wateringGeneralBenchmark,
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppPadding.mediumPadding), //
                      // --- AKHIR TOMBOL TIME CONVERTER ---

                      const Divider(
                          height: AppPadding.extraLargePadding, //
                          thickness: 1,
                          color: AppColors.softGrey), //
                      CommentSection(plantId: displayPlant.id.toString()), //
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.extraSmallPadding), //
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.hintColor, //
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textColor, //
                  ),
            ),
          ),
        ],
      ),
    );
  }
}