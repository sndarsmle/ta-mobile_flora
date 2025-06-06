import 'dart:async'; 
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart'; 

import 'package:projekakhir_praktpm/presenters/plant_presenter.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/utils/constants.dart'; 
import 'package:projekakhir_praktpm/views/plants/plant_card.dart'; 


class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _accelerometerSubscription;

  static const double _shakeThreshold = 2.2; 
  static const int _shakeSlopTimeMS = 500; 
  static const int _shakeCountResetTimeMS = 3000; 
  static const double earthGravity = 9.80665; 

  int _shakeCount = 0;
  int _lastShakeTimestamp = 0;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    print("[PlantListScreen] initState: Called");

    // Memuat data tanaman awal setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[PlantListScreen] initState: addPostFrameCallback executing");
      final plantPresenter = Provider.of<PlantPresenter>(context, listen: false);
      print("[PlantListScreen] initState: Current state - isLoading: ${plantPresenter.isLoading}, plantList.isEmpty: ${plantPresenter.plantList.isEmpty}");
      if (plantPresenter.plantList.isEmpty && !plantPresenter.isLoading) {
        print("[PlantListScreen] initState: Calling loadPlants()");
        plantPresenter.loadPlants().then((_) {
          if (mounted) { // Selalu cek mounted dalam callback async
             final currentPresenter = Provider.of<PlantPresenter>(context, listen: false);
            print("[PlantListScreen] initState: loadPlants() finished. isLoading: ${currentPresenter.isLoading}, plantList.isEmpty: ${currentPresenter.plantList.isEmpty}");
          }
        }).catchError((error) {
          print("[PlantListScreen] initState: Error loading plants: $error");
        });
      }
    });

    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMorePlants();
      }
    });

    // Listener untuk accelerometer (shake detection)
    _accelerometerSubscription = accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 200)) 
        .listen(
      (AccelerometerEvent event) {
        _handleAccelerometerEvent(event);
      },
      onError: (error) {
        print('[PlantListScreen] Accelerometer Error: $error');
        
      },
      cancelOnError: true,
    );


    _searchController.addListener(() {
      if (mounted) {
        setState(() {}); 
      }
    });
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (_isDialogShowing) return; 

    double x = event.x;
    double y = event.y;
    double z = event.z;

    double accelerationMagnitude = sqrt(x * x + y * y + z * z);
    double gForce = accelerationMagnitude / earthGravity;
    

    if (gForce > _shakeThreshold) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if ((now - _lastShakeTimestamp) < _shakeSlopTimeMS) {
        return; 
      }

      if ((now - _lastShakeTimestamp) > _shakeCountResetTimeMS) {
        _shakeCount = 0; 
      }

      _lastShakeTimestamp = now;
      _shakeCount++;
      print('[PlantListScreen] Shake detected! Count: $_shakeCount, G-Force: ${gForce.toStringAsFixed(2)}');


      if (_shakeCount >= 1) { // Cukup satu goyangan yang memenuhi syarat untuk memicu
        _shakeCount = 0; 
        
        final plantPresenter = Provider.of<PlantPresenter>(context, listen: false);
        print("[PlantListScreen] Shake action triggered. Current state - isLoading: ${plantPresenter.isLoading}, plantList.isEmpty: ${plantPresenter.plantList.isEmpty}");

        if (!_isDialogShowing) {
          _showRandomPlantDialog();
        }
      }
    }
  }

  String _getImageUrlFromPlant(Plant plant) {
    if (plant.defaultImage != null &&
        plant.defaultImage!['regular_url'] != null &&
        plant.defaultImage!['regular_url'].isNotEmpty) {
      return plant.defaultImage!['regular_url'];
    }
    return ''; 
  }

  void _showRandomPlantDialog() {
    if (!mounted) {
      print("[PlantListScreen] _showRandomPlantDialog: Widget not mounted. Aborting.");
      return;
    }

    final plantPresenter = Provider.of<PlantPresenter>(context, listen: false);
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); 

    // PERUBAHAN UTAMA: Cek kondisi sebelum menampilkan dialog
    if (plantPresenter.isLoading) {
      print("[PlantListScreen] _showRandomPlantDialog: Data is loading. Showing SnackBar.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data tanaman sedang dimuat. Coba goyangkan lagi nanti!'),
          backgroundColor: Colors.orangeAccent, 
        ),
      );
      return; 
    }

    if (plantPresenter.plantList.isEmpty) {
      print("[PlantListScreen] _showRandomPlantDialog: Plant list is empty. Showing SnackBar.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Daftar tanaman masih kosong. Muat data dulu ya!'),
            backgroundColor: AppColors.dangerColor), 
      );
      return; 
    }

    
    final random = Random();
    final randomPlant = plantPresenter.plantList[random.nextInt(plantPresenter.plantList.length)];
    final String imageUrl = _getImageUrlFromPlant(randomPlant);

    setState(() {
      _isDialogShowing = true;
    });
    print("[PlantListScreen] _showRandomPlantDialog: Showing dialog for ${randomPlant.commonName}");

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor.withOpacity(0.97),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPadding.mediumPadding)),
          title: Row(
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.accentColor, size: 28),
              const SizedBox(width: AppPadding.smallPadding),
              Expanded( 
                child: Text(
                  'Tanaman Untukmu!',
                  style: TextStyle(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(dialogContext).textTheme.titleLarge?.fontSize ?? 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: <Widget>[
              SizedBox(
                height: 150, 
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppPadding.smallPadding),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.accentColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("[PlantListScreen] Image.network error: $error");
                            return Image.asset('assets/images/noCover.jpg', fit: BoxFit.cover); // Pastikan path aset ini benar
                          },
                        )
                      : Image.asset('assets/images/noCover.jpg', fit: BoxFit.cover), // Pastikan path aset ini benar
                ),
              ),
              const SizedBox(height: AppPadding.mediumPadding),
              Text(
                randomPlant.commonName.isNotEmpty
                    ? randomPlant.commonName
                    : (randomPlant.scientificName.isNotEmpty ? randomPlant.scientificName[0] : 'Nama Tanaman Tidak Diketahui'),
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ) ?? TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup', style: TextStyle(color: AppColors.secondaryTextColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Flag _isDialogShowing akan direset di .then()
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Lihat Detail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.primaryColor, // Warna teks tombol
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog saat ini dulu
                // Flag _isDialogShowing akan direset di .then()
                
                // Gunakan context dari _PlantListScreenState untuk navigasi
                Navigator.pushNamed(
                  context,
                  '/plant-detail', // Pastikan route ini terdefinisi
                  arguments: randomPlant,
                );
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Ini akan dieksekusi setelah dialog ditutup (baik via tombol atau back button sistem jika barrierDismissible true)
      print("[PlantListScreen] Dialog closed.");
      if (mounted) {
        setState(() {
          _isDialogShowing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    print("[PlantListScreen] dispose: Called");
    _searchController.removeListener(_updateSearchUI); // Hapus listener jika dibuat spesifik
    _searchController.dispose();
    _scrollController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
  // Tambahkan fungsi ini jika Anda menggunakan _searchController.addListener(_updateSearchUI);
  void _updateSearchUI() {
    if (mounted) {
      setState(() {});
    }
  }


  void _performSearch() {
    final query = _searchController.text.trim();
    print("[PlantListScreen] _performSearch: Query = '$query'");
    // Memberitahu presenter untuk memuat tanaman berdasarkan query.
    // Presenter harus menangani reset halaman/daftar jika ini pencarian baru.
    Provider.of<PlantPresenter>(context, listen: false).loadPlants(query: query, isLoadMore: false);
    FocusScope.of(context).unfocus(); // Tutup keyboard
  }

  void _loadMorePlants() {
    final plantPresenter = Provider.of<PlantPresenter>(context, listen: false);
    if (!plantPresenter.isLoading && plantPresenter.hasMorePlants) {
      print("[PlantListScreen] _loadMorePlants: Loading more...");
      plantPresenter.loadPlants(query: _searchController.text.trim(), isLoadMore: true);
    } else {
      print("[PlantListScreen] _loadMorePlants: Cannot load more. isLoading: ${plantPresenter.isLoading}, hasMorePlants: ${plantPresenter.hasMorePlants}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.mediumPadding),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textColor, fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: AppConstants.searchHint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.hintColor, size: 20.0),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.softGrey),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.softGrey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryColor,
                    focusColor: AppColors.primaryColor,
                    hoverColor: AppColors.primaryColor,
                    labelStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                    hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.hintColor, size: 20.0),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: AppPadding.smallPadding),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: AppColors.textColor,
                    padding: const EdgeInsets.symmetric(horizontal: AppPadding.mediumPadding, vertical: AppPadding.mediumPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppPadding.tinyPadding),
                    ),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<PlantPresenter>(
            builder: (context, plantPresenter, child) {
              if (plantPresenter.plantList.isEmpty && plantPresenter.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
              } else if (plantPresenter.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.mediumPadding),
                    child: Text(
                      '${AppConstants.genericErrorMessage}\n${plantPresenter.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.dangerColor),
                    ),
                  ),
                );
              } else if (plantPresenter.plantList.isEmpty) {
                return Center(
                  child: Text(
                    AppConstants.noNewsFound.replaceFirst('berita', 'tanaman'),
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                );
              } else {
                return ListView.builder(
                  controller: _scrollController, 
                  itemCount: plantPresenter.plantList.length + (plantPresenter.hasMorePlants ? 1 : 0), 
                  itemBuilder: (context, index) {
                    if (index == plantPresenter.plantList.length) {
                      return plantPresenter.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppPadding.mediumPadding),
                                child: CircularProgressIndicator(color: AppColors.accentColor),
                              ),
                            )
                          : const SizedBox.shrink(); 
                    }
                    final plant = plantPresenter.plantList[index];
                    return PlantCard(plant: plant);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}