import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(cartItem.name[0]),
                  ),
                  title: Text(cartItem.name),
                  subtitle: Text('Qty: ${cartItem.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => cart.removeItem(cartItem.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- PRICE SUMMARY CARD ---
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRow('Subtotal:', cart.subtotal),
                  const SizedBox(height: 8),
                  _buildRow('VAT (12%):', cart.vat),
                  const Divider(height: 20, thickness: 1),
                  _buildRow('Total:', cart.totalPriceWithVat,
                      isTotal: true),
                ],
              ),
            ),
          ),

          // --- PROCEED TO PAYMENT BUTTON ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
                  ),
                );
              },
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.deepPurple : null,
          ),
        ),
      ],
    );
  }
}
