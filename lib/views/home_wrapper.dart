// lib/views/home_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/views/plants/plant_list_screen.dart';
import 'package:projekakhir_praktpm/views/plants/my_plants_screen.dart';
import 'package:projekakhir_praktpm/views/auth/profile_screen.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PlantListScreen(),
    const MyPlantsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPresenter = context.watch<UserPresenter>();
   

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Row( 
          mainAxisSize: MainAxisSize.min, 
          children: [
            Image.asset(
              'assets/logo/logo2.jpg',
              height: 40, 
              width: 40,  
            ),
            const SizedBox(width: AppPadding.smallPadding), 
            Text(
              _selectedIndex == 0
                  ? 'Dashboard Tanaman'
                  : _selectedIndex == 1
                      ? 'Tanaman Favorit'
                      : 'Profil Pengguna',
              style: TextStyle(color: AppColors.textColor),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        elevation: 0,
      ),
      body: IndexedStack( 
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(), 
    );
  }

  Widget _buildCustomBottomNavBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        child: Container(
          height: 60,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(0, Icons.grass, 'Tanaman'),
              _buildNavBarItem(1, Icons.favorite, 'Favorit'),
              _buildNavBarItem(2, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        highlightColor: Colors.transparent,
        splashColor: AppColors.accentColor.withOpacity(0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentColor : AppColors.hintColor,
              size: isSelected ? 28 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accentColor : AppColors.secondaryTextColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}