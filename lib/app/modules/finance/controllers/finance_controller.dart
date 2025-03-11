import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/utils/helpers.dart';
import 'package:uuid/uuid.dart';

class FinanceController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // État observable
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Tous'.obs;
  final RxString selectedType = 'Tous'.obs;
  final RxString error = ''.obs;
  
  // Filtres observables
  final RxList<String> categories = <String>['Tous'].obs;
  final RxList<String> types = <String>['Tous', 'Revenus', 'Dépenses'].obs;

  // Statistiques observables
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  // Récupérer toutes les transactions
  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Fetching transactions...');
      final response = await _supabase
          .from('transactions')
          .select()
          .order('date', ascending: false);
      
      print('Response received: $response');
      
      final List<TransactionModel> transactionsList = response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
      
      transactions.value = transactionsList;
      
      // Mettre à jour les catégories disponibles
      final uniqueCategories = transactionsList
          .map((transaction) => transaction.category)
          .toSet()
          .toList();
      categories.value = ['Tous', ...uniqueCategories];

      // Calculer les totaux
      _updateTotals();
      
    } catch (e, stackTrace) {
      print('Error fetching transactions: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors du chargement des transactions: ${e.toString()}';
      showErrorSnackbar('Erreur lors du chargement des transactions', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter une nouvelle transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Adding transaction: ${transaction.toJson()}');
      
      await _supabase
          .from('transactions')
          .insert(transaction.toJson());
      
      await fetchTransactions();
      Get.back();
      showSuccessSnackbar('Succès', 'Transaction ajoutée avec succès');
      
    } catch (e, stackTrace) {
      print('Error adding transaction: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de l\'ajout de la transaction: ${e.toString()}';
      showErrorSnackbar('Erreur lors de l\'ajout de la transaction', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Updating transaction: ${transaction.toJson()}');
      
      await _supabase
          .from('transactions')
          .update(transaction.toJson())
          .eq('id', transaction.id);
      
      await fetchTransactions();
      Get.back();
      showSuccessSnackbar('Succès', 'Transaction mise à jour avec succès');
      
    } catch (e, stackTrace) {
      print('Error updating transaction: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la mise à jour de la transaction: ${e.toString()}';
      showErrorSnackbar('Erreur lors de la mise à jour de la transaction', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Deleting transaction: $id');
      
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id);
      
      await fetchTransactions();
      showSuccessSnackbar('Succès', 'Transaction supprimée avec succès');
      
    } catch (e, stackTrace) {
      print('Error deleting transaction: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la suppression de la transaction: ${e.toString()}';
      showErrorSnackbar('Erreur lors de la suppression de la transaction', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les transactions
  List<TransactionModel> get filteredTransactions {
    return transactions.where((transaction) {
      final matchesSearch = transaction.category.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          (transaction.description != null && transaction.description!.toLowerCase().contains(searchQuery.value.toLowerCase()));
      final matchesCategory = selectedCategory.value == 'Tous' || transaction.category == selectedCategory.value;
      final matchesType = selectedType.value == 'Tous' ||
                         (selectedType.value == 'Revenus' && transaction.type == TransactionType.income) ||
                         (selectedType.value == 'Dépenses' && transaction.type == TransactionType.expense);
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  // Mettre à jour les totaux
  void _updateTotals() {
    double incomeSum = 0;
    double expenseSum = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        incomeSum += transaction.amount;
      } else {
        expenseSum += transaction.amount;
      }
    }

    totalIncome.value = incomeSum;
    totalExpense.value = expenseSum;
    balance.value = incomeSum - expenseSum;
  }

  // Mettre à jour la recherche
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Mettre à jour la catégorie sélectionnée
  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  // Mettre à jour le type sélectionné
  void updateSelectedType(String type) {
    selectedType.value = type;
  }

  // Créer une nouvelle transaction
  Future<void> createTransaction({
    required double amount,
    required String type,
    required String category,
    required String description,
    required String farmerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        amount: amount,
        type: type == 'income' ? TransactionType.income : TransactionType.expense,
        category: category,
        description: description,
        date: DateTime.now(),
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        farmerId: farmerId,
      );
      
      print('Creating transaction: ${transaction.toJson()}');
      
      await _supabase
          .from('transactions')
          .insert(transaction.toJson());
      
      await fetchTransactions();
      showSuccessSnackbar('Succès', 'Transaction créée avec succès');
      
    } catch (e, stackTrace) {
      print('Error creating transaction: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la création de la transaction: ${e.toString()}';
      showErrorSnackbar('Erreur lors de la création de la transaction', e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Obtenir les transactions par catégorie et période
  Future<List<TransactionModel>> getTransactionsByCategory({
    required String category,
    String? period,
  }) async {
    try {
      var query = _supabase
          .from('transactions')
          .select()
          .eq('category', category);
      
      if (period != null) {
        // Format de period: "YYYY-MM"
        final year = int.parse(period.split('-')[0]);
        final month = int.parse(period.split('-')[1]);
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0);
        
        query = query
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
      }
      
      final response = await query.order('date', ascending: false);
      
      return response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
          
    } catch (e, stackTrace) {
      print('Error fetching transactions by category: $e');
      print('Stack trace: $stackTrace');
      error.value = 'Erreur lors de la récupération des transactions: ${e.toString()}';
      return [];
    }
  }
} 