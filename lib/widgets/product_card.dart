import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  // 1. Data we need
  final String productName;
  final double price;
  final String imageUrl;
  final VoidCallback onTap; // Tap callback

  // 2. Constructor
  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Wrap Card in InkWell for tap effect
    return InkWell(
      onTap: onTap,
      child: Card(
        // 4. Card style comes from global cardTheme if set
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 5. Product image
            Expanded(
              flex: 3, // Image takes 3 parts of space
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),

            // 6. Product info (name + price)
            Expanded(
              flex: 2, // Text takes 2 parts of space
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(), // Push price to bottom

                    // Price
                    Text(
                      '₱${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
