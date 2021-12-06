import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget(
      {Key? key,
      required this.id,
      required this.price,
      required this.quantity,
      required this.productId,
      required this.title})
      : super(key: key);
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (dir) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Are you sure?"),
                  content: const Text(
                      "Do you want to remove the item from the cart?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("No")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Yes")),
                  ],
                ));
      },
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text("\$$price")),
            ),
            title: Text(title),
            subtitle: Text("Total: \$${price * quantity}"),
            trailing: Text(quantity.toString()),
          ),
        ),
      ),
    );
  }
}
