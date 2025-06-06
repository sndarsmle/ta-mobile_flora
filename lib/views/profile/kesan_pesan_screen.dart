// lib/views/profile/kesan_pesan_screen.dart

import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';

class KesanPesanScreen extends StatelessWidget {
  const KesanPesanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan gradient untuk background yang lebih menarik
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.8),
              AppColors.primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent, // Appbar transparan
              elevation: 0,
              centerTitle: true,
              pinned: true,
              title: const Text(
                'Kesan & Pesan',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.textColor),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Foto profil dengan border
                    CircleAvatar(
                      radius: 85,
                      backgroundColor: AppColors.accentColor.withOpacity(0.5),
                      child: const CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('assets/images/fotoProfil.jpg'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ageng Sandar R.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '123220011',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    const Divider(
                      color: AppColors.hintColor,
                      height: 40,
                      thickness: 0.5,
                      indent: 40,
                      endIndent: 40,
                    ),
                    // Card untuk pesan agar terlihat terpisah dan rapi
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: AppColors.primaryColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(AppPadding.largePadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"Terimakasih Pak Bagus atas 1 semester yang luar biasa. Karena hanya di semester ini saya baru merasakan rasanya menjadi mahasiswa Informatika. Kalo kata orang orang semester 1, 2, 3, 4, 5 rasanya kurang nendang, kalian wajib ngerasain 3 matkul bersama Pak Bagus di Semester 6 <3\n\nTapi jangan salah, banyak sekali pembelajaran dan ilmu yang didapat, kalo kata orang "Kuliah Cuma Belajar Basicnya aja selebihnya Kalian Harus Eksplor sendiri". Di dalam matkul Pak Bagus khususnya Teknologi Pemrograman Mobile kalian ga perlu ngeksplornya sendiri, kalian bakal dibimbing untuk "belajar apa" dan tentunya sesuai dengan porsi mahasiswa semester 6.\n\nJadi Terimakasih Pak Bagus Telah Berhasil Memberikan Kesan yang Bisa terkenang dan membekas di semester 6 ini, bukan kenangan buruk atau trauma melainkan kenangan yang super duper mantap karena saya berhasil membuat aplikasi PLAN PAL. ini yang bahkan gapernah ada dalam ekspetasi saya bisa menciptakannya."',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textColor.withOpacity(0.9),
                                height: 1.5, // Jarak antar baris
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Ageng-011\n8 Juni 2025 (3 jam sebelum Deadline)',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}