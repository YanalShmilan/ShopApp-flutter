import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = '/user-products';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<ProductsProvider>(context).fetchAndSetProducts(true),
        builder: (ctx, snapshot) => RefreshIndicator(
          onRefresh: () async =>
              await Provider.of<ProductsProvider>(context, listen: false)
                  .fetchAndSetProducts(true),
          child: Consumer<ProductsProvider>(
            builder: (context, products, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: products.items.length,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    UserProductItem(
                      id: products.items[i].id,
                      title: products.items[i].title,
                      imageUrl: products.items[i].imageUrl,
                    ),
                    const Divider()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
