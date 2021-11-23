import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/widgets/products_grid.dart';

enum FilterOption { ONLYFAVORITE, ALL }

class ProductOverviewScreen extends StatefulWidget {
  static const routName = '/';
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isLoading = false;
  bool _ShowOnlyFav = false;
  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchData()
        .then((value) => setState(
              () => _isLoading = false,
            ))
        .catchError((error) => setState(
              () => _isLoading = false,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Shop'), actions: [
        PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.ONLYFAVORITE) {
                  _ShowOnlyFav = true;
                } else {
                  _ShowOnlyFav = false;
                }
              });
            },
            itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text('Only Favorite'),
                    value: FilterOption.ONLYFAVORITE,
                  ),
                  PopupMenuItem(
                    child: Text('Show All'),
                    value: FilterOption.ALL,
                  ),
                ]),
        Consumer<Cart>(
          child: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(CartScreen.routName),
          ),
          builder: (_, cart, ch) =>
              Badge(value: cart.itemCount.toString(), child: ch),
        )
      ]),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(
              isFav: _ShowOnlyFav,
            ),
      drawer: AppDrawer(),
    );
  }
}
