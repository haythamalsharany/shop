import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final child;
  final value;
  final  Color? color;

  const Badge({Key? key,  required this.value,  this.color, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:color==null?Theme.of(context).colorScheme.secondary:color
              ),
              constraints: BoxConstraints(
                minHeight: 16,
                minWidth: 16
              ),
              child: Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:10,
              ),),
            ))
      ],
    );
  }
}
