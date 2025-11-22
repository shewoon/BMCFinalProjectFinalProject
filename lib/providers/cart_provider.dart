import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // Convert object → Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Convert Map → object (from Firestore)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ --- GETTERS SECTION ---
  List<CartItem> get items => [..._items];

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // 1. Subtotal (before VAT)
  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // 2. VAT (12%)
  double get vat {
    return subtotal * 0.12;
  }

  // 3. Total with VAT
  double get totalPriceWithVat {
    return subtotal + vat;
  }

  // --- CONSTRUCTOR ---
  CartProvider() {
    print('CartProvider created.');
  }

  // --- AUTH LISTENER ---
  void initializeAuthListener() {
    print('CartProvider auth listener initialized');

    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  // ✅ PLACE ORDER (updated for VAT)
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // --- VAT logic here ---
      final double sub = subtotal;
      final double v = vat;
      final double total = totalPriceWithVat;
      final int count = itemCount;

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': sub,
        'vat': v,
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  // ✅ Clear Cart
  Future<void> clearCart() async {
    _items = [];
    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }
    notifyListeners();
  }

  // ✅ Fetch Cart
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // ✅ Save Cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });

      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // ✅ Add Item
  void addItem(String id, String name, double price, [int quantity = 1]) {
    var index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(id: id, name: name, price: price, quantity: quantity));
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
