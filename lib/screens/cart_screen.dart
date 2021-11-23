import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart' show Cart;
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routName = '/CartScreen';

  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6!
                                .color),
                      ),
                    ),
                    OrderButton(
                      cart: cart,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: cart.itemCount.bitLength,
              itemBuilder: (ctx, index) => CartItem(
                id: cart.cartItems.values.toList()[index].id,
                price: cart.cartItems.values.toList()[index].price,
                title: cart.cartItems.values.toList()[index].title,
                quantity: cart.cartItems.values.toList()[index].quantity,
                productId: cart.cartItems.keys.toList()[index],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;

  OrderButton({Key? key, required this.cart}) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || isloading)
          ? null
          : () async {
              setState(() {
                isloading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.cartItems.values.toList(),
                  widget.cart.totalAmount);
              setState(() {
                isloading = false;
              });
              widget.cart.clearCart();
            },
      child: isloading ? CircularProgressIndicator() : Text('ORDER NOW'),
    );
  }
}
