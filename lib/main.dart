// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
// Services
import 'package:projekakhir_praktpm/services/hive_service.dart';
import 'package:projekakhir_praktpm/services/notification_service.dart';

// Utils
import 'package:projekakhir_praktpm/utils/constants.dart'; 

// Network 
import 'package:projekakhir_praktpm/network/plant_api_service.dart';

// Presenters
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/presenters/plant_presenter.dart';
import 'package:projekakhir_praktpm/presenters/comment_presenter.dart';
import 'package:projekakhir_praktpm/presenters/bookmark_presenter.dart';
import 'package:projekakhir_praktpm/presenters/budget_presenter.dart'; // IMPORT BARU

// Models (cukup import yang digunakan untuk registrasi adapter jika belum)
import 'package:projekakhir_praktpm/models/user_model.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
// import 'package:projekakhir_praktpm/models/budget_item_model.dart'; // Adapter didaftar di HiveService

// Views
import 'package:projekakhir_praktpm/views/auth/login_screen.dart';
import 'package:projekakhir_praktpm/views/auth/register_screen.dart';
import 'package:projekakhir_praktpm/views/home_wrapper.dart'; 
import 'package:projekakhir_praktpm/views/plants/plant_detail_screen.dart';
// Import halaman baru yang akan dibuat
import 'package:projekakhir_praktpm/views/tools/currency_converter_screen.dart';
import 'package:projekakhir_praktpm/views/budget/budget_list_screen.dart';

import 'package:projekakhir_praktpm/views/tools/time_converter_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().init();
  await initializeDateFormatting('id_ID', null);

  tz.initializeTimeZones();
  // Inisialisasi Hive dan daftarkan semua adapter di HiveService.init()
  // Tidak perlu mendaftarkan adapter di sini lagi jika sudah dihandle HiveService.init()
  await HiveService().init(); // Panggil init di sini

  runApp(
    MultiProvider(
      providers: [
        Provider<PlantApi>(create: (_) => PlantApi()),
        ChangeNotifierProvider(create: (context) => UserPresenter()),
        ChangeNotifierProvider(create: (context) => PlantPresenter(context.read<PlantApi>())),
        ChangeNotifierProvider(create: (context) => CommentPresenter()),
        ChangeNotifierProvider(create: (context) => BookmarkPresenter()),
        ChangeNotifierProvider(create: (context) => BudgetPresenter()), // DAFTARKAN PRESENTER BARU
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... tema yang sudah ada ...
         primaryColor: AppColors.primaryColor, // Tambahkan ini agar tema konsisten
         scaffoldBackgroundColor: AppColors.primaryColor, // Latar belakang default
         colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primaryColor,
            secondary: AppColors.accentColor,
            brightness: Brightness.dark, // Jika mayoritas UI gelap
         ),
         appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textColor,
            titleTextStyle: TextStyle(
                color: AppColors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
            ),
         ),
         textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textColor),
            bodyMedium: TextStyle(color: AppColors.textColor),
            titleLarge: TextStyle(color: AppColors.textColor), // Untuk judul di dialog/card
            titleMedium: TextStyle(color: AppColors.textColor),
            labelLarge: TextStyle(color: AppColors.textColor), // Untuk teks tombol
         ),
         cardTheme: CardTheme(
            color: AppColors.primaryColor.withOpacity(0.8), // Warna kartu sedikit transparan atau beda
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppPadding.smallPadding),
            ),
         ),
         elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.primaryColor, // Teks tombol jadi warna primer gelap
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppPadding.tinyPadding), // Menggunakan tinyPadding dari constants
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.largePadding, vertical: AppPadding.mediumPadding),
                elevation: 2,
                textStyle: const TextStyle(fontWeight: FontWeight.bold)
            ),
         ),
         textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor,
            )
         ),
         inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: AppColors.hintColor),
            hintStyle: const TextStyle(color: AppColors.hintColor),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.softGrey.withOpacity(0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accentColor, width: 2),
            ),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.softGrey.withOpacity(0.5)),
            ),
            prefixIconColor: AppColors.hintColor,
            suffixIconColor: AppColors.hintColor,
            filled: false, // Biasanya tidak di-fill jika pakai UnderlineInputBorder
         ),
         dialogTheme: DialogTheme(
            backgroundColor: AppColors.primaryColor.withBlue(AppColors.primaryColor.blue + 10), // Warna dialog
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPadding.mediumPadding)),
            titleTextStyle: const TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.bold),
            contentTextStyle: const TextStyle(color: AppColors.secondaryTextColor),
         )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeWrapper(),
        '/plant-detail': (context) {
          final plant = ModalRoute.of(context)!.settings.arguments as Plant;
          return PlantDetailScreen(plant: plant);
        },
        // TAMBAHKAN RUTE BARU
        '/currency-converter': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CurrencyConverterScreen(
            plantId: args['plantId'] as int,
            plantName: args['plantName'] as String,
          );
        },
        '/budget-list': (context) => const BudgetListScreen(),

        '/time-converter': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TimeConverterScreen(
            plantName: args['plantName'] as String,
            wateringBenchmark: args['wateringBenchmark'] as Map<String, dynamic>?,
          );
        },
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userPresenter = Provider.of<UserPresenter>(context, listen: false);

    return FutureBuilder<User?>(
      future: userPresenter.getLoggedInUser(), // Ini sudah benar
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryColor, // Samakan BG
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            ),
          );
        }

        // Tidak perlu lagi cek snapshot.hasError karena getLoggedInUser sudah handle error internal
        if (snapshot.hasData && snapshot.data != null) {
             // Jika user sudah login, update currentUser di UserPresenter
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<UserPresenter>(context, listen: false).setCurrentUser(snapshot.data);
            });
          return const HomeWrapper();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}