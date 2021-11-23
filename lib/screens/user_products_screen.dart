import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routName = '/UserProductsScreen';

  Future<void> _refReshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yuor Products'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProduct.routName),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
          future: _refReshProducts(context),
          builder: (ctx, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircleAvatar(),
                )
              : RefreshIndicator(
                  child: Consumer<Products>(
                    builder: (ctx, productsData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (_, int index) => Column(
                                children: [
                                  UserProductItem(
                                      id: productsData.items[index].id,
                                      title: productsData.items[index].title,
                                      imageUrl:
                                          productsData.items[index].imageUrl),
                                  Divider()
                                ],
                              )),
                    ),
                  ),
                  onRefresh: () => _refReshProducts(context))),
      drawer: AppDrawer(),
    );
  }
}
