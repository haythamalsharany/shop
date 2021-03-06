import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(
      {Key? key,
      required this.id,
      required this.productId,
      required this.price,
      required this.quantity,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        onDismissed: (_) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
          return;
        },
        direction: DismissDirection.endToStart,
        confirmDismiss: (dir) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Are you sure ?'),
                    content: Text('Do you want to remove item fromnthe cart ?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Yes')),
                    ],
                  ));
        },
        background: Container(
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          color: Theme.of(context).errorColor,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        key: ValueKey(id),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: FittedBox(
                  child: Text('\$${price}'),
                ),
              ),
            ),
            title: Text('${title}'),
            subtitle: Text('Total \$${price * quantity}'),
            trailing: Text('${quantity} x'),
          ),
        ));
  }
}
