import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProdcutItem extends StatelessWidget {
  const ProdcutItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: Icon(
              product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border_outlined,
              color: Colors.deepOrange,
            ),
            onPressed: () => product.toggleFavStatus(
                Provider.of<Auth>(context, listen: false).token.toString(),
                Provider.of<Auth>(context, listen: false).userId),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              Provider.of<Cart>(context, listen: false)
                  .addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  "Added item to cart!",
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () => Provider.of<Cart>(context, listen: false)
                        .removeSingleItem(product.id)),
              ));
            },
          ),
        ),
      ),
    );
  }
}
