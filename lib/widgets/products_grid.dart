import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/product_item.dart';
class ProductsGrid extends StatelessWidget {
  final bool isFav;

  const ProductsGrid({Key? key, required this.isFav}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final productData=Provider.of<Products>(context);
    final products=isFav?productData.favoriteItems:productData.items;
    return products.isEmpty?Center(
      child: Text('There is no product yet'),
    )
        :GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3/2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10
        ),
        itemBuilder:(ctx,index)=>
            ChangeNotifierProvider.value(value: products[index],child: ProductItem(),),);
  }
}
