import 'package:flutter/material.dart';

class SellerShopScreen extends StatelessWidget {
  const SellerShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Faith Crafts'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5B52D6)],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.store, size: 40),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '4.8 ⭐ • 120 products',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              'Product Name',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'RWF 25,000',
                              style: TextStyle(color: Color(0xFF6C63FF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                childCount: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
