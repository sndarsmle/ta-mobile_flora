import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/network/plant_api_service.dart'; 

class PlantPresenter extends ChangeNotifier { 
  final PlantApi plantApi; 
  List<Plant> _plantList = []; 
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1; 
  final int _pageSize = 30; 
  bool _hasMorePlants = true; 
  String _currentQuery = ''; 

  PlantPresenter(this.plantApi); 

  List<Plant> get plantList => _plantList; 
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMorePlants => _hasMorePlants; 

  void _resetPagination() {
    _currentPage = 1;
    _hasMorePlants = true;
    _plantList = []; 
    _errorMessage = null;
  }

  Future<void> loadPlants({String? query, bool isLoadMore = false}) async { 
    if (_isLoading) return; 

    if (!isLoadMore) {
      _resetPagination();
      _currentQuery = query ?? ''; 
    } else if (!_hasMorePlants) {
      return; 
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newPlants = await plantApi.getSpeciesList(query: _currentQuery, page: _currentPage, pageSize: _pageSize);

      if (newPlants.isEmpty || newPlants.length < _pageSize) {
        _hasMorePlants = false; 
      } else {
        _currentPage++; 
      }
      _plantList.addAll(newPlants); 
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load plants: $e';
      if (!isLoadMore) { 
        _plantList = []; 
      }
      _hasMorePlants = false; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Plant?> getPlantDetails(int id) async {
    try {
      return await plantApi.getSpeciesDetails(id);
    } catch (e) {
      _errorMessage = 'Failed to load plant details: $e';
      notifyListeners();
      return null;
    }
  }
}