import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../../../core/utils/helpers.dart';
import 'dart:io';

class MarketplaceController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // État observable
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<CartModel> cart = CartModel().obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ProductCategory?> selectedCategory = Rx<ProductCategory?>(null);
  final Rx<ProductType?> selectedType = Rx<ProductType?>(null);
  final RxString error = ''.obs;
  
  // Filtres observables
  final RxList<String> categories = <String>['Tous'].obs;
  final RxList<String> types = <String>['Tous', 'Produits agricoles', 'Intrants'].obs;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Getter pour les éléments du panier
  List<CartItemModel> get cartItems => cart.value.items;

  @override
  void onInit() {
    super.onInit();
    _initCart();
    fetchProducts();
    fetchOrders();
  }

  // Initialiser le panier
  Future<void> _initCart() async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId);
      
      if (response != null && response.isNotEmpty) {
        final cartItems = response.map<CartItemModel>((item) => CartItemModel(
          productId: item['product_id'],
          productName: item['product_name'],
          quantity: item['quantity'],
          unit: item['unit'],
          unitPrice: item['unit_price'].toDouble(),
          sellerId: item['seller_id'],
          imageUrl: item['image_url'],
        )).toList();
        
        cart.value = CartModel();
        for (var item in cartItems) {
          cart.value.addItem(item);
        }
      }
    } catch (e) {
      print('Error initializing cart: $e');
    }
  }

  // Récupérer tous les produits
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _supabase
          .from('products')
          .select()
          .eq('status', ProductStatus.available.toString().split('.').last)
          .order('created_at', ascending: false);
      
      final List<ProductModel> productsList = response
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
      
      products.value = productsList;
      
      // Mettre à jour les catégories disponibles
      _updateCategories();
      
    } catch (e) {
      print('Error fetching products: $e');
      error.value = 'Erreur lors du chargement des produits: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de charger les produits');
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les commandes de l'utilisateur
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('orders')
          .select()
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('created_at', ascending: false);
      
      orders.value = response
          .map<OrderModel>((json) => OrderModel.fromJson(json))
          .toList();
      
    } catch (e) {
      print('Error fetching orders: $e');
      error.value = 'Erreur lors du chargement des commandes: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de charger les commandes');
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un produit
  Future<void> addProduct(ProductModel product) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('products')
          .insert(product.toJson());
      
      await fetchProducts();
      Get.back();
      showSuccessSnackbar('Succès', 'Produit ajouté avec succès');
      
    } catch (e) {
      print('Error adding product: $e');
      error.value = 'Erreur lors de l\'ajout du produit: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible d\'ajouter le produit');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un produit
  Future<void> updateProduct(ProductModel product) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
      
      await fetchProducts();
      Get.back();
      showSuccessSnackbar('Succès', 'Produit mis à jour avec succès');
      
    } catch (e) {
      print('Error updating product: $e');
      error.value = 'Erreur lors de la mise à jour du produit: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour le produit');
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('products')
          .delete()
          .eq('id', id);
      
      await fetchProducts();
      showSuccessSnackbar('Succès', 'Produit supprimé avec succès');
      
    } catch (e) {
      print('Error deleting product: $e');
      error.value = 'Erreur lors de la suppression du produit: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de supprimer le produit');
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter au panier avec quantité spécifique
  Future<void> addToCart(ProductModel product, double quantity) async {
    try {
      final cartItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        quantity: quantity.toInt(),
        unit: product.unit,
        unitPrice: product.price,
        sellerId: product.sellerId,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null,
      );

      cart.value.addItem(cartItem);
      await updateCartInDatabase();
      
      showSuccessSnackbar('Succès', 'Produit ajouté au panier');
    } catch (e) {
      print('Error adding to cart: $e');
      showErrorSnackbar('Erreur', 'Impossible d\'ajouter au panier');
    }
  }

  // Ajouter au panier avec quantité par défaut de 1
  void addProductToCart(ProductModel product) {
    final existingItem = cart.value.items.firstWhereOrNull(
      (item) => item.productId == product.id,
    );

    if (existingItem != null) {
      final index = cart.value.items.indexOf(existingItem);
      cart.value.items[index] = CartItemModel(
        productId: existingItem.productId,
        productName: existingItem.productName,
        quantity: existingItem.quantity + 1,
        unit: existingItem.unit,
        unitPrice: existingItem.unitPrice,
        sellerId: existingItem.sellerId,
        imageUrl: existingItem.imageUrl,
      );
    } else {
      cart.value.addItem(CartItemModel(
        productId: product.id,
        productName: product.name,
        quantity: 1,
        unit: product.unit,
        unitPrice: product.price,
        sellerId: product.sellerId,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null,
      ));
    }
  }

  // Mettre à jour le panier dans la base de données
  Future<void> _updateCartInDatabase() async {
    try {
      await _supabase
          .from('carts')
          .upsert(cart.value.toJson());
    } catch (e) {
      print('Error updating cart in database: $e');
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour le panier');
    }
  }

  // Passer une commande avec adresse et méthode de paiement
  Future<void> placeOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Grouper les articles par vendeur
      final itemsBySeller = cart.value.itemsBySeller;
      
      // Créer une commande pour chaque vendeur
      for (final entry in itemsBySeller.entries) {
        final sellerId = entry.key;
        final items = entry.value;
        final orderId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final order = OrderModel(
          id: orderId,
          userId: currentUserId!,
          sellerId: sellerId,
          items: items.map((item) => OrderItemModel(
            imageUrl: item.imageUrl,
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
        
            price: item.unitPrice,
          )).toList(),
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
          total: items.fold(0, (sum, item) => sum + item.totalPrice),
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
          paymentStatus: 'pending',
        );

        await _supabase
            .from('orders')
            .insert(order.toJson());
      }

      // Vider le panier
      cart.value.clear();
      await _updateCartInDatabase();
      
      await fetchOrders();
      Get.toNamed('/marketplace/orders');
      showSuccessSnackbar('Succès', 'Commande passée avec succès');
      
    } catch (e) {
      print('Error placing order: $e');
      error.value = 'Erreur lors de la commande: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de passer la commande');
    } finally {
      isLoading.value = false;
    }
  }

  // Passer une commande simple
  Future<void> submitOrder() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        error.value = 'Utilisateur non connecté';
        return;
      }

      if (cart.value.items.isEmpty) {
        error.value = 'Le panier est vide';
        return;
      }

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create order
      await _supabase.from('orders').insert({
        'id': orderId,
        'user_id': userId,
        'status': 'en attente',
        'total': cartTotal,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create order items
      final orderItems = cart.value.items.map((item) {
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'order_id': orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.unitPrice,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      // Clear cart
      cart.value.clear();

      // Refresh orders
      await fetchOrders();

      Get.snackbar(
        'Succès',
        'Votre commande a été placée avec succès',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Erreur lors de la création de la commande';
      print('Error placing order: $e');

      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création de la commande',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('orders')
          .update({'status': newStatus.toString().split('.').last})
          .eq('id', orderId);
      
      await fetchOrders();
      showSuccessSnackbar('Succès', 'Statut de la commande mis à jour');
      
    } catch (e) {
      print('Error updating order status: $e');
      error.value = 'Erreur lors de la mise à jour du statut: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour le statut');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les produits
  List<ProductModel> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          product.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == null || product.category == selectedCategory.value;
      final matchesType = selectedType.value == null || product.type == selectedType.value;
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  Future<void> updateCartInDatabase() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Delete existing cart items for the user
      await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id);
      
      // Insert new cart items
      if (cart.value.items.isNotEmpty) {
        final cartItems = cart.value.items.map((item) {
          return {
            'user_id': supabase.auth.currentUser!.id,
            'product_id': item.productId,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
        }).toList();

        await supabase.from('cart_items').insert(cartItems);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la mise à jour du panier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error updating cart in database: $e');
    }
  }

  void setCategory(String categoryValue) {
    if (categoryValue == 'Tous') {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = ProductCategory.values.firstWhere(
        (cat) => cat.value == categoryValue,
        orElse: () => ProductCategory.other,
      );
    }
  }

  void setType(String typeValue) {
    if (typeValue == 'Tous') {
      selectedType.value = null;
    } else {
      selectedType.value = ProductType.values.firstWhere(
        (type) => type.value == typeValue,
        orElse: () => ProductType.agricultural,
      );
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void resetFilters() {
    selectedCategory.value = null;
    selectedType.value = null;
    searchQuery.value = '';
  }

  void removeFromCart(String productId) {
    cart.value.items.removeWhere((item) => item.productId == productId);
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final index = cart.value.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        cart.value.items.removeAt(index);
      } else {
        cart.value.items[index] = CartItemModel(
          productId: cart.value.items[index].productId,
          productName: cart.value.items[index].productName,
          quantity: quantity,
          unit: cart.value.items[index].unit,
          unitPrice: cart.value.items[index].unitPrice,
          sellerId: cart.value.items[index].sellerId,
          imageUrl: cart.value.items[index].imageUrl,
        );
      }
    }
  }

  double get cartTotal {
    return cart.value.items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Mettre à jour les catégories disponibles
  void _updateCategories() {
    final uniqueCategories = products
        .map((product) => product.category)
        .toSet()
        .toList();
    categories.value = ['Tous', ...uniqueCategories.map((cat) => cat.value)];
  }

  // Upload d'une image de produit
  Future<String> uploadProductImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final storageResponse = await _supabase.storage
          .from('product_images')
          .upload(fileName, imageFile);
      
      final imageUrl = _supabase.storage
          .from('product_images')
          .getPublicUrl(fileName);
      
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }
} 