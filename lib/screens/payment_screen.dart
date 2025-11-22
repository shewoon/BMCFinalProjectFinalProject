import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _selectedMethod;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Gcash',
    'Credit/Debit Card',
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- PAYMENT METHOD OPTIONS ---
            ..._paymentMethods.map((method) {
              return RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  setState(() => _selectedMethod = value);
                },
              );
            }),

            const SizedBox(height: 20),
            const Divider(),

            // --- PRICE SUMMARY ---
            _buildRow('Subtotal:', cart.subtotal),
            _buildRow('VAT (12%):', cart.vat),
            const Divider(height: 20, thickness: 1),
            _buildRow('Total:', cart.totalPriceWithVat, isTotal: true),
            const Spacer(),

            // --- CONFIRM PAYMENT BUTTON ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: (_isProcessing || _selectedMethod == null)
                  ? null
                  : () async {
                setState(() => _isProcessing = true);
                try {
                  await cart.placeOrder();
                  await cart.clearCart();

                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                          const OrderSuccessScreen()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment failed: $e')),
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                  }
                }
              },
              child: _isProcessing
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}
