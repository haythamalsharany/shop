import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/screens/product_details_screen.dart';
class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product=Provider.of<Product>(context,listen: false);
    final cart=Provider.of<Cart>(context,listen: false);
    final authData=Provider.of<Auth>(context,listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(

          child:GestureDetector(
            onTap: ()=>Navigator.of(context)
                .pushNamed(ProductDetailsScreen.routName,arguments: product.id),
            child: Hero(
              tag:product.id ,
              child:FadeInImage(
                fit: BoxFit.cover,
                placeholder:AssetImage('assets/images/product-placeholder.png') ,
                image: NetworkImage(product.imageUrl),
              ) ,
            ),
          ),
         footer: GridTileBar(
           backgroundColor: Colors.black87,
           leading:Consumer<Product>(
             builder:(ctx,product,_)=>IconButton(
               color: Theme.of(ctx).colorScheme.secondary,
                 onPressed:(){
                 product.toggleFavoriteStatus(authData.userId!,authData.token!);
                 },
                 icon: Icon(product.isFavorite?Icons.favorite:Icons.favorite_border)) ,

           ) ,
           title: Text(product.title,textAlign: TextAlign.center,),
           trailing: IconButton(onPressed:(){
             cart.addCartItem(product.id, product.price, product.title);
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds:3 ),
                  content: Text(' addedd to cart ! '),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: (){
                  cart.removeSingleItem(product.id);
                },
              ),)
             );
           } ,
             icon: Icon(Icons.shopping_cart),
             color: Theme.of(context).colorScheme.secondary,),
         ),

       ),
    );
  }
}
