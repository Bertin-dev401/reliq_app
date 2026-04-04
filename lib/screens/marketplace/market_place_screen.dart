import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reliq Market'),
        actions: [
          Consumer<MarketplaceProvider>(
            builder: (_, mp, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {},
                ),
                // Cart badge — shows number of items in cart
                if (mp.cartItemsCount > 0)
                  Positioned(
                    right: 6, top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${mp.cartItemsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, mp, _) {
          if (mp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (mp.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(mp.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: mp.loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = mp.getCategories();

          return Column(
            children: [
              // Category filter chips
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final selected = mp.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: primary.withOpacity(0.15),
                      onSelected: (_) => mp.setCategoryFilter(cat),
                    );
                  },
                ),
              ),

              // Product grid
              Expanded(
                child: mp.products.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: mp.products.length,
                        itemBuilder: (_, i) {
                          final p = mp.products[i];
                          return GestureDetector(
                            onTap: () => Get.toNamed('/product-detail', arguments: p),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image placeholder
                                  Container(
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.08),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.shopping_bag_outlined, size: 48, color: primary.withOpacity(0.4)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'RWF ${p.price.toStringAsFixed(0)}',
                                          style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 13, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text('${p.rating}', style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 4),
                                            Text('(${p.reviewsCount})', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 32,
                                          child: ElevatedButton(
                                            onPressed: () => mp.addToCart(p),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mp.isInCart(p.id) ? Colors.grey[300] : primary,
                                              foregroundColor: mp.isInCart(p.id) ? Colors.grey[700] : Colors.white,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Text(
                                              mp.isInCart(p.id) ? 'In Cart' : 'Add to Cart',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
