import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/bookmark_presenter.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart'; 
import 'package:projekakhir_praktpm/utils/constants.dart';
import 'package:projekakhir_praktpm/views/plants/plant_card.dart'; 

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  @override
  Widget build(BuildContext context) {
    final userPresenter = context.watch<UserPresenter>();
    final currentUser = userPresenter.currentUser;

    if (currentUser == null) {
      return _buildLoginRequiredUI(context);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryColor, 
      body: Consumer<BookmarkPresenter>(
        builder: (context, bookmarkPresenter, child) {
          final userBookmarks =
              bookmarkPresenter.getBookmarksForUser(currentUser.id);
          if (userBookmarks.isEmpty) {
            return _buildEmptyBookmarksUI(context);
          } else {
            return ListView.builder(
              itemCount: userBookmarks.length,
              itemBuilder: (context, index) {
                final plant = userBookmarks[index];
                return PlantCard(plant: plant);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginRequiredUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.mediumPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: AppColors.hintColor),
            const SizedBox(height: AppPadding.mediumPadding),
            Text(
              'Anda harus login untuk melihat tanaman favorit.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppColors.textColor, 
                  ),
            ),
            const SizedBox(height: AppPadding.mediumPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor, 
                foregroundColor: AppColors.primaryColor, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppPadding.tinyPadding), 
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.largePadding, vertical: AppPadding.mediumPadding),
                elevation: 0, 
                minimumSize: const Size.fromHeight(50), 
              ),
              child: const Text(
                'Login Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBookmarksUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: AppColors.hintColor),
          const SizedBox(height: AppPadding.mediumPadding),
          Text(
            'Belum ada tanaman yang Anda favoritkan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: AppColors.textColor, 
                ),
          ),
          const SizedBox(height: AppPadding.smallPadding),
          Text(
            'Anda bisa menambahkan tanaman ke favorit dari halaman detail tanaman.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.secondaryTextColor, 
                ),
          ),
        ],
      ),
    );
  }
}