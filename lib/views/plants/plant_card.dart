// lib/views/plants/plant_card.dart
import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  const PlantCard({super.key, required this.plant});

  String getImageUrl(Map<String, dynamic>? defaultImage) {
    if (defaultImage != null && defaultImage['regular_url'] != null && defaultImage['regular_url'].isNotEmpty) {
      return defaultImage['regular_url'];
    }
    return '';
  }

  // Helper widget untuk menampilkan baris info dengan label dan value
  // Hanya ditampilkan jika value tidak null dan tidak kosong
  Widget _buildInfoText(String label, String? value, BuildContext context) {
    if (value != null && value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppPadding.extraSmallPadding), // Sedikit spasi antar baris info
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.secondaryTextColor, // Warna default untuk teks value
                ),
            children: <TextSpan>[
              TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.hintColor)), // Label di-bold
              TextSpan(text: value),
            ],
          ),
          maxLines: 2, // Batasi agar tidak terlalu panjang di kartu
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return const SizedBox.shrink(); // Tidak menampilkan apa-apa jika value null atau kosong
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.mediumPadding, vertical: AppPadding.smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppPadding.smallPadding),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/plant-detail',
            arguments: plant,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppPadding.smallPadding),
                child: getImageUrl(plant.defaultImage).isNotEmpty
                    ? Image.network(
                        getImageUrl(plant.defaultImage),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/noCover.jpg', // Pastikan path asset ini benar
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/noCover.jpg', // Pastikan path asset ini benar
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: AppPadding.smallPadding),
              Text(
                plant.commonName.isNotEmpty ? plant.commonName : (plant.scientificName.isNotEmpty ? plant.scientificName[0] : 'Nama Tanaman Tidak Diketahui'),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Spasi sebelum menampilkan info tambahan
              const SizedBox(height: AppPadding.smallPadding),

              // Menampilkan Family, Genus, dan Other Name jika tersedia
              _buildInfoText('Famili', plant.family, context),
              _buildInfoText('Genus', plant.genus, context),
              _buildInfoText('Dikenal juga sebagai', plant.otherName, context),
            ],
          ),
        ),
      ),
    );
  }
}