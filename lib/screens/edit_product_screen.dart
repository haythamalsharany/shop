import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/app_drawer.dart';

class EditProduct extends StatefulWidget {
  static const routName = '/EditProduct';

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _editProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var initialValue = {
    'id': '',
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var isInit = true;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editProduct = Provider.of<Products>(context, listen: false)
            .findProductById(productId);
        initialValue = {
          'id': _editProduct.id,
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
      isInit = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) return;
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context).add(_editProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error occurred !'),
                content: Text('Something Went wronge'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('OK'))
                ],
              );
            });
      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initialValue['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: value!,
                          description: _editProduct.description,
                          price: _editProduct.price,
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initialValue['price'],
                      focusNode: _priceFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid price';
                        }
                        if (double.tryParse(value)! <= 0) {
                          return 'The price must be grater than zero ';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: _editProduct.description,
                          price: double.parse(value!),
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initialValue['description'],
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'should be at list 10 characters';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: value!,
                          price: _editProduct.price,
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(top: 5, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  )),
                        Expanded(
                          child: TextFormField(
                            initialValue: initialValue['imageUrl'],
                            keyboardType: TextInputType.multiline,
                            focusNode: _imageUrlFocusNode,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'ImageUrl',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a image Url';
                              }
                              if (value.length < 10) {
                                return 'should be at list 10 characters';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid Url';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jpeg')) {
                                return 'Please enter a valid Image';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                description: _editProduct.description,
                                price: _editProduct.price,
                                imageUrl: value!,
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
      drawer: AppDrawer(),
    );
  }
}
