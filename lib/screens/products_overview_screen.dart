import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class PrdouctOverViewScreen extends StatefulWidget {
  const PrdouctOverViewScreen({Key? key}) : super(key: key);
  static const routeName = '/products-overview';

  @override
  State<PrdouctOverViewScreen> createState() => _PrdouctOverViewScreenState();
}

class _PrdouctOverViewScreenState extends State<PrdouctOverViewScreen> {
  @override
  var _isInit = true;
  var _isLoading = false;
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context)
          .fetchAndSetProducts()
          .then((value) => setState(() {
                _isLoading = false;
              }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.Favorites) {
                Provider.of<ProductsProvider>(context, listen: false)
                    .showFavOnlyMethod();
              } else {
                Provider.of<ProductsProvider>(context, listen: false).showAll();
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              )
            ],
          ),
          Badge(
              child: IconButton(
                icon: const Icon(Icons.shopping_basket),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
              value: Provider.of<Cart>(context).itemsCount.toString(),
              color: Colors.red)
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const ProductsGrid(),
    );
  }
}
