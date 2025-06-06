// lib/views/auth/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';
import 'package:projekakhir_praktpm/views/profile/kesan_pesan_screen.dart'; // <-- Pastikan import ini ada

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPresenter>(
      builder: (context, userPresenter, child) {
        final currentUser = userPresenter.currentUser;

        if (currentUser == null) {
          // ... (UI jika belum login - tidak berubah) ...
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.mediumPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined,
                      size: 80, color: AppColors.hintColor),
                  const SizedBox(height: AppPadding.mediumPadding),
                  Text(
                    'Anda belum login.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: AppColors.secondaryTextColor),
                  ),
                  const SizedBox(height: AppPadding.smallPadding),
                  Text(
                    'Login untuk melihat profil Anda.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.hintColor),
                  ),
                  const SizedBox(height: AppPadding.mediumPadding),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Login Sekarang'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppPadding.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppPadding.largePadding),
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.accentColor,
                child: Text(
                  currentUser.username.isNotEmpty
                      ? currentUser.username[0].toUpperCase()
                      : 'U',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppPadding.largePadding),
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppPadding.mediumPadding),
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.mediumPadding),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person,
                            color: AppColors.accentColor),
                        title: Text(
                          'Username',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.hintColor),
                        ),
                        subtitle: Text(
                          currentUser.username,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: AppColors.textColor),
                        ),
                      ),
                      const Divider(color: AppColors.softGrey),
                      ListTile(
                        leading: const Icon(Icons.email,
                            color: AppColors.accentColor),
                        title: Text(
                          'Email',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.hintColor),
                        ),
                        subtitle: Text(
                          currentUser.email,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: AppColors.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.mediumPadding), // Spasi

              // =================== KODE TAMBAHAN DIMULAI DI SINI ===================
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppPadding.mediumPadding,
                    vertical: AppPadding.smallPadding),
                child: ListTile(
                  leading: const Icon(Icons.school_outlined,
                      color: AppColors.accentColor),
                  title: Text('Kesan & Pesan Proyek',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.textColor)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.hintColor, size: 16),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KesanPesanScreen()));
                  },
                ),
              ),
              // =================== KODE TAMBAHAN SELESAI DI SINI ===================

              // TOMBOL UNTUK WISHLIST BUDGET
              Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppPadding.mediumPadding,
                    vertical: AppPadding.smallPadding),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: AppColors.accentColor),
                  title: Text('Wishlist Budget Tanaman',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.textColor)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.hintColor, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/budget-list');
                  },
                ),
              ),

              const SizedBox(height: AppPadding.largePadding), // Spasi sebelum logout
              ElevatedButton.icon(
                onPressed: () async {
                  // ... (logika logout - tidak berubah) ...
                  bool confirmLogout = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content:
                              const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.dangerColor,
                              ),
                              child: const Text('Logout',
                                  style:
                                      TextStyle(color: AppColors.textColor)),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirmLogout) {
                    await userPresenter.logout();
                    // Navigasi setelah logout, pastikan tidak ada error jika context sudah tidak valid
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (route) => false);
                    } else {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                icon: const Icon(Icons.logout,
                    color: AppColors.textColor), 
                label: Text('Logout',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge 
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerColor,
                  foregroundColor: AppColors.textColor, 
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}