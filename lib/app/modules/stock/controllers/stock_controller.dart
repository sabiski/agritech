import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/stock_model.dart';
import '../../../core/utils/helpers.dart';

class StockController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // État observable
  final RxList<StockModel> stocks = <StockModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Tous'.obs;
  final RxString error = ''.obs;
  
  // Filtres observables
  final RxList<String> categories = <String>['Tous'].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchStocks();
  }

  // Récupérer tous les stocks
  Future<void> fetchStocks() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Fetching stocks...');
      final response = await _supabase
          .from('stocks')
          .select()
          .order('created_at', ascending: false);
      
      print('Response received: $response');
      
      final List<StockModel> stocksList = response
          .map<StockModel>((json) => StockModel.fromJson(json))
          .toList();
      
      stocks.value = stocksList;
      
      // Mettre à jour les catégories disponibles
      final uniqueCategories = stocksList
          .map((stock) => stock.category)
          .toSet()
          .toList();
      categories.value = ['Tous', ...uniqueCategories];
      
    } catch (e, stackTrace) {
      print('Error fetching stocks: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors du chargement des stocks: ${e.toString()}';
      showErrorSnackbar('Erreur lors du chargement des stocks', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un nouveau stock
  Future<void> addStock(StockModel stock) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Adding stock: ${stock.toJson()}');
      
      await _supabase
          .from('stocks')
          .insert(stock.toJson());
      
      await fetchStocks();
      Get.back();
      showSuccessSnackbar('Succès', 'Stock ajouté avec succès');
      
    } catch (e, stackTrace) {
      print('Error adding stock: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de l\'ajout du stock: ${e.toString()}';
      showErrorSnackbar('Erreur lors de l\'ajout du stock', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un stock
  Future<void> updateStock(StockModel stock) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Updating stock: ${stock.toJson()}');
      
      await _supabase
          .from('stocks')
          .update(stock.toJson())
          .eq('id', stock.id);
      
      await fetchStocks();
      Get.back();
      showSuccessSnackbar('Succès', 'Stock mis à jour avec succès');
      
    } catch (e, stackTrace) {
      print('Error updating stock: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la mise à jour du stock: ${e.toString()}';
      showErrorSnackbar('Erreur lors de la mise à jour du stock', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un stock
  Future<void> deleteStock(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Deleting stock: $id');
      
      await _supabase
          .from('stocks')
          .delete()
          .eq('id', id);
      
      await fetchStocks();
      showSuccessSnackbar('Succès', 'Stock supprimé avec succès');
      
    } catch (e, stackTrace) {
      print('Error deleting stock: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la suppression du stock: ${e.toString()}';
      showErrorSnackbar('Erreur lors de la suppression du stock', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les stocks
  List<StockModel> get filteredStocks {
    return stocks.where((stock) {
      final matchesSearch = stock.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          stock.category.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'Tous' || stock.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Obtenir les stocks périmés
  List<StockModel> get expiredStocks {
    return filteredStocks.where((stock) => stock.isExpired).toList();
  }

  // Obtenir les stocks bientôt périmés
  List<StockModel> get nearExpirationStocks {
    return filteredStocks.where((stock) => stock.isNearExpiration).toList();
  }

  // Obtenir les stocks bas
  List<StockModel> get lowStocks {
    return filteredStocks.where((stock) => stock.isLowStock).toList();
  }

  // Mettre à jour la recherche
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Mettre à jour la catégorie sélectionnée
  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
  }
} 